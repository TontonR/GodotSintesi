#!/usr/bin/env python3
"""Editor local del catalogo de objetos (`vault/items`).

Solo libreria estandar. Arranque:

    python3 vault/items-editor/server.py [--port 8765] [--root <repo>]

`--root` existe para probar sobre una copia del repo (por defecto, dos niveles
por encima de este fichero).

El editor NO toca los `.tres`: escribe en la ficha `.md` y en su fila de
`vault/items.md`, y deja el objeto en estado pendiente (`en proceso`) para que
se sepa que el cambio aun no se refleja en el juego.
"""
from __future__ import annotations

import argparse
import json
import re
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import unquote, urlparse

ROOT = Path(__file__).resolve().parents[2]
HERE = Path(__file__).resolve().parent
ITEMS_DIR = "vault/items"
CATALOG = "vault/items.md"
PENDING = "Aplicar los cambios de esta ficha en el `.tres` y en el juego."
PENDING_STATE = "en proceso"


def _field(text: str, label: str) -> str:
    m = re.search(rf"^\| {re.escape(label)} \| (.*?) \|$", text, re.M)
    return m.group(1) if m else ""


def _cells(line: str) -> list[str]:
    return [c.strip() for c in line.strip().strip("|").split("|")]


def catalog_states(text: str) -> list[dict]:
    block = text.split("## Estados", 1)[1].split("\n## ", 1)[0]
    states = []
    for line in block.splitlines():
        m = re.match(r"^\| `([^`]+)` \| (.+?) \|$", line)
        if m:
            states.append({"id": m.group(1), "meaning": m.group(2)})
    return states


def catalog_rows(text: str) -> list[dict]:
    rows = []
    for line in text.splitlines():
        if not line.startswith("| **"):
            continue
        cells = _cells(line)
        if len(cells) < 7:
            continue
        link = re.search(r"\]\(items/([^)]+)\.md\)", cells[6])
        if not link:
            continue
        rows.append(
            {
                "slug": link.group(1),
                "name": cells[0].strip("*"),
                "type": cells[1],
                "quality": cells[2].strip("`"),
                "drops": cells[3],
                "icon": cells[4].strip("`"),
                "state": cells[5].strip("`"),
            }
        )
    return rows


def catalog_summary(text: str) -> list[dict]:
    """Reparto por enemigo: solo lectura en el editor."""
    block = text.split("## Reparto por enemigo", 1)[1].split("\n## ", 1)[0]
    out = []
    for line in block.splitlines():
        cells = _cells(line) if line.startswith("| [") else []
        if len(cells) == 3:
            out.append({"enemy": cells[0], "items": cells[1], "chance": cells[2]})
    return out


def parse_page(slug: str) -> dict | None:
    path = HERE_ROOT / ITEMS_DIR / f"{slug}.md"
    if not path.exists():
        return None
    text = path.read_text(encoding="utf-8")
    icon = re.search(r"`(res://[^`]+)`", _field(text, "Textura en el juego"))
    values = []
    if "## Valores del recurso" in text:
        block = text.split("## Valores del recurso", 1)[1].split("\n## ", 1)[0]
        for line in block.splitlines():
            m = re.match(r"^\| `([^`]+)` \| `(.*)` \|$", line)
            if m:
                values.append({"key": m.group(1), "value": m.group(2)})
    desc = ""
    m = re.search(r"## Qué hace\n\n> (.*)", text)
    if m:
        desc = m.group(1).strip()
    return {
        "slug": slug,
        "name": _field(text, "Nombre en el juego").strip("*"),
        "type": _field(text, "Tipo").split("—")[0].strip(),
        "quality": _field(text, "Calidad").strip("`"),
        "state": _field(text, "Estado").strip("`"),
        "icon": icon.group(1) if icon else "",
        "description": desc,
        "values": values,
        "resource": _field(text, "Recurso").strip("`"),
        "drops": _field(text, "Lo suelta"),
    }


def save_page(slug: str, data: dict) -> dict:
    path = HERE_ROOT / ITEMS_DIR / f"{slug}.md"
    text = path.read_text(encoding="utf-8")

    name = data["name"].strip()
    state = data["state"].strip()
    icon = data["icon"].strip()
    if icon.startswith("assets/"):
        icon = "res://" + icon
    description = data["description"].strip()

    text = re.sub(r"^# .*$", f"# {name}", text, count=1, flags=re.M)
    text = re.sub(r"^\| Nombre en el juego \| .*$", f"| Nombre en el juego | **{name}** |", text, flags=re.M)
    text = re.sub(r"^\| Estado \| .*$", f"| Estado | `{state}` |", text, flags=re.M)
    if icon:
        text = re.sub(
            r"^\| Textura en el juego \| .*$",
            f"| Textura en el juego | `{icon}` — aplicada, puede cambiar el arte |",
            text,
            flags=re.M,
        )
    text = re.sub(r"(## Qué hace\n\n> ).*", lambda m: m.group(1) + description, text, count=1)

    rows = "\n".join(f"| `{v['key']}` | `{v['value']}` |" for v in data.get("values", []) if v["key"].strip())
    table = "| Campo | Valor |\n|---|---|"
    if rows:
        table += "\n" + rows
    text = re.sub(
        r"## Valores del recurso\n\n\| Campo \| Valor \|\n\|---\|---\|\n(?:\|.*\|\n)*",
        "## Valores del recurso\n\n" + table + "\n",
        text,
    )

    if PENDING not in text:
        pending = f"## Pendiente\n\n- [ ] {PENDING}\n"
        if "## Pendiente\n\n" in text:
            text = text.replace("## Pendiente\n\n", pending, 1)
        elif "## Pendiente\n" in text:
            text = text.replace("## Pendiente\n", pending, 1)
        else:
            text = text.rstrip() + "\n\n" + pending
    path.write_text(text, encoding="utf-8")

    # Fila del catalogo
    cat_path = HERE_ROOT / CATALOG
    cat = cat_path.read_text(encoding="utf-8")
    icon_short = icon.removeprefix("res://assets/")
    lines = []
    for line in cat.splitlines():
        if f"](items/{slug}.md)" in line and line.startswith("| **"):
            cells = _cells(line)
            cells[0] = f"**{name}**"
            cells[4] = f"`{icon_short}`"
            cells[5] = f"`{state}`"
            line = "| " + " | ".join(cells) + " |"
        lines.append(line)
    cat_path.write_text("\n".join(lines) + "\n", encoding="utf-8")

    return parse_page(slug)


class Handler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(HERE_ROOT), **kwargs)

    def log_message(self, fmt, *args):
        print("%s - %s" % (self.address_string(), fmt % args))

    def _json(self, payload, code=200):
        body = json.dumps(payload, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        path = urlparse(self.path).path
        if path == "/":
            return self._static("index.html", "text/html")
        if path.startswith("/assets/"):
            return self._file(HERE_ROOT / unquote(path.lstrip("/")), "image/png")
        if path.startswith("/editor/"):
            name = unquote(path.split("/editor/", 1)[1])
            return self._static(name)
        if path == "/api/items":
            cat = (HERE_ROOT / CATALOG).read_text(encoding="utf-8")
            items = []
            for row in catalog_rows(cat):
                page = parse_page(row["slug"]) or {}
                row.update(
                    {
                        "description": page.get("description", ""),
                        "resource": page.get("resource", ""),
                        "values": page.get("values", []),
                    }
                )
                items.append(row)
            return self._json(
                {"states": catalog_states(cat), "items": items, "drops": catalog_summary(cat)}
            )
        if path.startswith("/api/items/"):
            item = parse_page(path.rsplit("/", 1)[1])
            return self._json(item or {"error": "not found"}, 200 if item else 404)
        return self._json({"error": "not found"}, 404)

    def do_POST(self):
        path = urlparse(self.path).path
        if not path.startswith("/api/items/"):
            return self._json({"error": "not found"}, 404)
        slug = path.rsplit("/", 1)[1]
        length = int(self.headers.get("Content-Length", 0))
        try:
            data = json.loads(self.rfile.read(length) or b"{}")
        except json.JSONDecodeError:
            return self._json({"error": "bad json"}, 400)
        if not data.get("name", "").strip():
            return self._json({"error": "name required"}, 400)
        if not data.get("state"):
            data["state"] = PENDING_STATE
        item = save_page(slug, data)
        if item is None:
            return self._json({"error": "not found"}, 404)
        return self._json(item)

    def _static(self, name: str, ctype: str = "text/plain"):
        path = HERE / name
        if not path.exists():
            return self._json({"error": "not found"}, 404)
        body = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _file(self, path: Path, ctype: str):
        try:
            path.resolve().relative_to(HERE_ROOT)
        except ValueError:
            return self._json({"error": "forbidden"}, 403)
        if not path.is_file():
            return self._json({"error": "not found"}, 404)
        suffix = path.suffix.lower()
        if suffix == ".svg":
            ctype = "image/svg+xml"
        elif suffix in (".jpg", ".jpeg"):
            ctype = "image/jpeg"
        body = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", ctype)
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


HERE_ROOT = ROOT


def main() -> None:
    global ROOT, HERE_ROOT
    parser = argparse.ArgumentParser(description="Editor de vault/items")
    parser.add_argument("--port", type=int, default=8765)
    parser.add_argument("--root", default=str(ROOT))
    args = parser.parse_args()
    ROOT = Path(args.root).resolve()
    HERE_ROOT = ROOT
    server = ThreadingHTTPServer(("127.0.0.1", args.port), Handler)
    print(f"Editor de objetos en http://127.0.0.1:{args.port}  (root: {ROOT})")
    server.serve_forever()


if __name__ == "__main__":
    main()
