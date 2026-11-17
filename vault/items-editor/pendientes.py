#!/usr/bin/env python3
"""Objetos pendientes de aplicar al juego: qué hay que tocar en Godot, campo a campo.

    python3 vault/items-editor/pendientes.py
    python3 vault/items-editor/pendientes.py --slug colgante_hierro
    python3 vault/items-editor/pendientes.py --root /ruta/a/una/copia

Lee las fichas `vault/items/*.md` con estado `en proceso` y las compara con su
`.tres`: imprime solo las diferencias (nombre, descripción, icono y valores).

Reglas para el que aplique los cambios:
- Se editan los `.tres` (y el loot/escenas si la ficha lo pide), **nunca** la ficha
  `.md`: el estado de la ficha lo cambia el editor web.
- Al terminar, pasar la ficha a `por revisar` y pedir F5.
"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

import server  # parseo de fichas (mismo directorio)


def load_tres(path: Path) -> dict:
    text = path.read_text(encoding="utf-8")
    ext = {
        m.group(2): m.group(1)
        for m in re.finditer(
            r'^\[ext_resource type="[^"]+"[^\]]*path="([^"]+)"[^\]]*id="([^"]+)"', text, re.M
        )
    }
    # el id puede ir antes que el path
    for m in re.finditer(r"^\[ext_resource [^\]]*id=\"([^\"]+)\"[^\]]*path=\"([^\"]+)\"", text, re.M):
        ext.setdefault(m.group(1), m.group(2))
    props = {}
    body = text.split("[resource]", 1)[1] if "[resource]" in text else ""
    for line in body.splitlines():
        m = re.match(r"^([a-z_0-9]+) = (.*)$", line.strip())
        if m:
            key, value = m.group(1), m.group(2).strip()
            link = re.match(r'ExtResource\("([^"]+)"\)', value)
            props[key] = ext.get(link.group(1), value) if link else value
    return props


def norm(value: str) -> str:
    value = str(value).strip()
    if len(value) >= 2 and value[0] == value[-1] and value[0] in "\"'":
        value = value[1:-1]
    return value


def render(slug: str, page: dict) -> int:
    root = Path(server.HERE_ROOT)
    tres_rel = page["resource"].removeprefix("res://")
    tres = root / tres_rel if tres_rel else None
    print(f"· {page['name'] or slug}  —  {server.ITEMS_DIR}/{slug}.md")
    if tres is None:
        print("  sin recurso declarado en la ficha: añadir `Recurso` antes de aplicar nada.")
        return 0
    if not tres.is_file():
        print(f"  FALTA el .tres: {tres_rel}")
        print("  crear el recurso y engancharlo al juego (script y valores de la ficha).")
        return 0

    props = load_tres(tres)
    print(f"  {tres_rel}")
    changes = []
    expected = [
        ("item_name", page["name"], props.get("item_name", "")),
        ("description", page["description"], props.get("description", "")),
        ("icon", page["icon"], props.get("icon", "")),
    ]
    for field, want, have in expected:
        if want and norm(want) != norm(have):
            changes.append((field, norm(have), norm(want)))
    for row in page["values"]:
        have = props.get(row["key"], "")
        if norm(have) != norm(row["value"]):
            changes.append((row["key"], norm(have), norm(row["value"])))

    if not changes:
        print("  sin diferencias: el .tres ya coincide → falta F5 y pasar la ficha a `por revisar`.")
        return 0
    print("  cambios a aplicar en el .tres:")
    for field, have, want in changes:
        print(f"    - {field}: {have or '—'}  ->  {want or '—'}")
    return 1


def main() -> int:
    parser = argparse.ArgumentParser(description="Objetos pendientes de aplicar en Godot")
    parser.add_argument("--slug", help="solo una ficha")
    parser.add_argument("--root", default=str(server.ROOT), help="repo o copia del repo")
    args = parser.parse_args()

    server.HERE_ROOT = Path(args.root).resolve()
    print("OBJETIVO: aplicar en Godot las fichas en `en proceso`.")
    print("Se editan los .tres (y loot/escenas si hace falta); las fichas .md no se tocan.")
    print()

    pages = [Path(args.slug)] if args.slug else sorted(Path(server.HERE_ROOT, server.ITEMS_DIR).glob("*.md"))
    pending = [p for p in pages if p.is_file() and (server.parse_page(p.stem) or {}).get("state") == "en proceso"]
    if not pending:
        print("No hay fichas en `en proceso`. Nada que aplicar.")
        return 0

    with_changes = 0
    for p in pending:
        with_changes += render(p.stem, server.parse_page(p.stem))
        print()

    print(f"Resumen: {len(pending)} ficha(s) en proceso · {with_changes} con cambios por aplicar.")
    return 0


if __name__ == "__main__":
    sys.exit(main())
