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
from datetime import date
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
    # Las tablas del vault pueden venir alineadas con espacios (formateador de markdown).
    m = re.search(rf"^\|\s*{re.escape(label)}\s*\|\s*(.*?)\s*\|\s*$", text, re.M)
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


def icon_res(path: str) -> str:
    """Acepta `items/x.png` o `assets/items/x.png` y devuelve la ruta del juego."""
    path = path.strip().strip("`")
    if not path or path in ("—", "-"):
        return ""
    return path if path.startswith("res://") else "res://assets/" + path.removeprefix("assets/")


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
            m = re.match(r"^\|\s*`([^`]+)`\s*\|\s*`(.*)`\s*\|\s*$", line)
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


def _replace_section_table(text: str, heading: str, table: str) -> str:
    """Sustituye la tabla que hay justo debajo de un encabezado `##`."""
    start = text.find(heading)
    if start < 0:
        return text
    body = text.find("\n", start) + 1
    nxt = text.find("\n## ", body)
    end = nxt if nxt >= 0 else len(text)
    return text[:body] + "\n" + table + "\n" + text[end:]


def save_page(slug: str, data: dict) -> dict:
    path = HERE_ROOT / ITEMS_DIR / f"{slug}.md"
    text = path.read_text(encoding="utf-8")

    name = data["name"].strip()
    state = data["state"].strip()
    icon = data["icon"].strip()
    if icon.startswith("assets/"):
        icon = "res://assets/" + icon.removeprefix("assets/")
    description = data["description"].strip()

    text = re.sub(r"^# .*$", lambda m: f"# {name}", text, count=1, flags=re.M)
    text = re.sub(
        r"^\|\s*Nombre en el juego\s*\|.*$",
        lambda m: f"| Nombre en el juego | **{name}** |",
        text,
        count=1,
        flags=re.M,
    )
    text = re.sub(
        r"^\|\s*Estado\s*\|.*$",
        lambda m: f"| Estado | `{state}` |",
        text,
        count=1,
        flags=re.M,
    )
    if icon:
        text = re.sub(
            r"^\|\s*Textura en el juego\s*\|.*$",
            lambda m: f"| Textura en el juego | `{icon}` — aplicada, puede cambiar el arte |",
            text,
            count=1,
            flags=re.M,
        )
    text = re.sub(r"(## Qué hace\n\n> ).*", lambda m: m.group(1) + description, text, count=1)

    rows = "\n".join(f"| `{v['key']}` | `{v['value']}` |" for v in data.get("values", []) if v["key"].strip())
    table = "| Campo | Valor |\n|---|---|"
    if rows:
        table += "\n" + rows
    text = _replace_section_table(text, "## Valores del recurso", table)

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
    cat_path.write_text(
        _rewrite_catalog(cat, slug, name, icon_short, state), encoding="utf-8"
    )

    return parse_page(slug)


def _rewrite_catalog(cat: str, slug: str, name: str, icon_short: str, state: str) -> str:
    lines = []
    for line in cat.splitlines():
        if f"](items/{slug}.md)" in line and line.startswith("| **"):
            cells = _cells(line)
            cells[0] = f"**{name}**"
            cells[4] = f"`{icon_short}`" if icon_short else "—"
            cells[5] = f"`{state}`"
            line = "| " + " | ".join(cells) + " |"
        lines.append(line)
    return "\n".join(lines) + "\n"


TYPE_TEXT = {
    "Consumible": (
        "Consumible — ocupa uno de los 3 slots y se gasta al usarlo",
        "items",
    ),
    "Pasiva": ("Pasiva — no ocupa slot, se equipa al tocarla", "passives"),
}


def create_page(data: dict) -> dict | None:
    """Crea ficha + fila de catalogo. Devuelve None si el slug ya existe."""
    name = data["name"].strip()
    slug = (data.get("slug") or "").strip().lower()
    slug = re.sub(r"[^a-z0-9_]+", "_", slug).strip("_")
    if not slug or (HERE_ROOT / ITEMS_DIR / f"{slug}.md").exists():
        return None
    type_name = data.get("type") if data.get("type") in TYPE_TEXT else "Pasiva"
    type_text, doc = TYPE_TEXT[type_name]
    quality = (data.get("quality") or "Normal").strip() or "Normal"
    icon = icon_res(data.get("icon", ""))
    icon_cell = f"`{icon}` — aplicada, puede cambiar el arte" if icon else "— (sin asignar)"
    description = (data.get("description") or "").strip() or "TODO: describir el efecto."

    page = f"""# {name}

_Item · {type_name.lower()} · `{quality}` · {date.today().isoformat()}_

| Campo | Valor |
|---|---|
| Nombre en el juego | **{name}** |
| Tipo | {type_text} |
| Calidad | `{quality}` |
| Estado | `{PENDING_STATE}` |
| Textura en el juego | {icon_cell} |
| Recurso | `res://resources/{slug}.tres` |
| Lo suelta | — (sin drop) |
| Doc técnica | [`docs/{doc}.md`](../../docs/{doc}.md) |

## Qué hace

> {description}

## Valores del recurso

| Campo | Valor |
|---|---|

## Cómo conseguirlo

- **Drop**: — (sin drop)
- Catálogo: [items.md](../items.md) · enemigos: [enemies.md](../enemies.md)

## Pendiente

- [ ] Crear el `.tres`, engancharlo al juego y pasar F5.
"""
    (HERE_ROOT / ITEMS_DIR / f"{slug}.md").write_text(page, encoding="utf-8")

    cat_path = HERE_ROOT / CATALOG
    cat = cat_path.read_text(encoding="utf-8")
    icon_short = icon.removeprefix("res://assets/")
    row = f"| **{name}** | {type_name} | `{quality}` | — (sin drop) | {f'`{icon_short}`' if icon_short else '—'} | `{PENDING_STATE}` | [{slug}](items/{slug}.md) |"
    lines = cat.splitlines()
    header = next(
        (i for i, ln in enumerate(lines) if ln.startswith("| Objeto |")), len(lines) - 1
    )
    insert_at = header + 2
    for i in range(header + 2, len(lines)):
        if not lines[i].startswith("| **"):
            break
        if _cells(lines[i])[0].strip("*").casefold() > name.casefold():
            insert_at = i
            break
        insert_at = i + 1
    lines.insert(insert_at, row)
    cat_path.write_text("\n".join(lines) + "\n", encoding="utf-8")
    return parse_page(slug)


def delete_page(slug: str) -> bool:
    path = HERE_ROOT / ITEMS_DIR / f"{slug}.md"
    if not path.exists():
        return False
    path.unlink()
    cat_path = HERE_ROOT / CATALOG
    cat = cat_path.read_text(encoding="utf-8")
    kept = [
        ln
        for ln in cat.splitlines()
        if not (ln.startswith("| **") and f"](items/{slug}.md)" in ln)
    ]
    cat_path.write_text("\n".join(kept) + "\n", encoding="utf-8")
    return True


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
        if path in ("/", "/index.html"):
            return self._static("index.html")
        if path.startswith("/assets/"):
            return self._file(HERE_ROOT / unquote(path.lstrip("/")))
        if path.startswith("/editor/"):
            return self._static(unquote(path.split("/editor/", 1)[1]))
        if path in ("/style.css", "/app.js"):
            return self._static(path.lstrip("/"))
        if path.startswith("/api/items/"):
            slug = path.rsplit("/", 1)[1]
            item = parse_page(slug)
            if item is None:
                return self._json({"error": "not found"}, 404)
            md = HERE_ROOT / ITEMS_DIR / f"{slug}.md"
            item["raw"] = md.read_text(encoding="utf-8")
            return self._json(item)
        if path == "/api/items":
            cat = (HERE_ROOT / CATALOG).read_text(encoding="utf-8")
            # Las fichas `vault/items/*.md` son la fuente; el catalogo solo aporta el orden
            # y las filas que aun no tienen ficha.
            rows = {r["slug"]: r for r in catalog_rows(cat)}
            items = []
            for md in sorted((HERE_ROOT / ITEMS_DIR).glob("*.md")):
                page = parse_page(md.stem)
                if page is None:
                    continue
                page = dict(rows.pop(md.stem, {}), **page)
                page["icon"] = icon_res(page.get("icon", ""))
                items.append(page)
            items.extend(rows.values())
            items.sort(key=lambda i: i.get("name", "").casefold())
            return self._json(
                {"states": catalog_states(cat), "items": items, "drops": catalog_summary(cat)}
            )
        return self._json({"error": "not found"}, 404)

    def _body(self) -> dict | None:
        length = int(self.headers.get("Content-Length", 0))
        try:
            return json.loads(self.rfile.read(length) or b"{}")
        except json.JSONDecodeError:
            return None

    def do_DELETE(self):
        path = urlparse(self.path).path
        if not path.startswith("/api/items/"):
            return self._json({"error": "not found"}, 404)
        slug = path.rsplit("/", 1)[1]
        if not delete_page(slug):
            return self._json({"error": "not found"}, 404)
        return self._json({"deleted": slug})

    def do_POST(self):
        path = urlparse(self.path).path
        if not path.startswith("/api/items"):
            return self._json({"error": "not found"}, 404)
        data = self._body()
        if data is None:
            return self._json({"error": "bad json"}, 400)
        if not data.get("name", "").strip():
            return self._json({"error": "name required"}, 400)
        if path.rstrip("/") == "/api/items":
            item = create_page(data)
            if item is None:
                return self._json({"error": "slug vacio o ya existe"}, 400)
            item["raw"] = (HERE_ROOT / ITEMS_DIR / f"{item['slug']}.md").read_text(
                encoding="utf-8"
            )
            return self._json(item)
        slug = path.rsplit("/", 1)[1]
        if not data.get("state"):
            data["state"] = PENDING_STATE
        item = save_page(slug, data)
        if item is None:
            return self._json({"error": "not found"}, 404)
        item["raw"] = (HERE_ROOT / ITEMS_DIR / f"{slug}.md").read_text(encoding="utf-8")
        return self._json(item)

    MIME = {
        ".html": "text/html; charset=utf-8",
        ".css": "text/css; charset=utf-8",
        ".js": "text/javascript; charset=utf-8",
        ".svg": "image/svg+xml",
    }

    def _static(self, name: str):
        path = HERE / name
        if not path.is_file():
            return self._json({"error": "not found"}, 404)
        body = path.read_bytes()
        self.send_response(200)
        self.send_header("Content-Type", self.MIME.get(path.suffix.lower(), "application/octet-stream"))
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _file(self, path: Path):
        try:
            path.resolve().relative_to(HERE_ROOT)
        except ValueError:
            return self._json({"error": "forbidden"}, 403)
        if not path.is_file():
            return self._json({"error": "not found"}, 404)
        ctype = {
            ".svg": "image/svg+xml",
            ".jpg": "image/jpeg",
            ".jpeg": "image/jpeg",
        }.get(path.suffix.lower(), "image/png")
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
