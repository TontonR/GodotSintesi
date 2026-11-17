# Editor de objetos (`vault/items`)

Editor local para ver y corregir los 44 objetos sin abrir 44 ficheros. Lee
`vault/items.md` (catálogo) y `vault/items/<slug>.md` (fichas) y escribe en los
mismos `.md`. **No toca los `.tres`**: al guardar, deja el objeto en `en proceso`
y añade un pendiente en la ficha, para que se sepa que el cambio todavía no se
refleja en el juego.

## Arrancar

```bash
python3 vault/items-editor/server.py          # http://127.0.0.1:8765
python3 vault/items-editor/server.py --port 9000
python3 vault/items-editor/server.py --root /ruta/a/una/copia   # pruebas
```

Solo librería estándar de Python (3.10+) y un navegador. No hace falta Godot ni
Node.

## Qué se puede hacer

- **Landing**: los 44 objetos con su icono, tipo, calidad y estado.
- **Filtros**: por estado (los mismos ids de `vault/items.md`) y buscador por
  nombre, tipo, calidad o drop.
- **Editor**: nombre en el juego, ruta de la textura y la descripción (`## Qué hace`,
  la habilidad del objeto). El estado se muestra como etiqueta de solo lectura.
- **Opciones avanzadas** (desplegable, cerrado): los valores del recurso copiados en la
  ficha (`## Valores del recurso`). El editor no lee ni escribe el `.tres`.
- **Guardar**: reescribe la ficha y su fila en `vault/items.md`; el estado pasa siempre a
  `en proceso` y se añade `- [ ] Aplicar los cambios de esta ficha en el .tres y en
  el juego.` si no estaba.

## Detalles

- La fuente de datos son los `.md`: la lista sale de `vault/items/*.md` (no solo de las
  filas del catálogo) y el `.tres` solo se muestra como texto informativo.
- `?slug=<slug>` abre un objeto directamente (enlace compartible).
- Debajo del formulario, «Ver el .md tal cual» muestra la ficha recién guardada.

## Límites

- Abrir `index.html` con doble clic (`file://`) enseña la página pero **no** puede leer el
  vault: hay que entrar por `http://127.0.0.1:8765`. Si no, sale un aviso rojo arriba.

- Ver el cambio **en el juego** exige editar el `.tres` y pasar F5: el editor no
  lo hace a propósito (una ficha no debe tocar recursos).
- Los iconos se sirven desde `assets/`, así que el servidor tiene que arrancarse
  desde el repo (o con `--root` apuntando a una copia completa).
- Solo escucha en `127.0.0.1`.
