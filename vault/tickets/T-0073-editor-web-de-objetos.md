# T-0073 · Editor web local de los objetos (`vault/items`)

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `opencode-jorge` |
| Sistema | docs / vault |
| Creado | 2026-11-17 |
| Actualizado | 2026-11-17 |
| Relacionado | T-0065, T-0072 |

## Problema

Corregir un objeto obliga a abrir `vault/items.md` y su ficha `.md`, y no hay forma de
ver los 44 de un vistazo ni de saber qué está pendiente de pasar al juego.

## Plan

1. Servidor local en Python (solo stdlib) que sirve una página y lee/escribe los `.md`.
2. Landing con los 44 objetos, buscador y filtros por estado.
3. Panel de edición: nombre, textura, estado, habilidad (`## Qué hace`) y valores del
   recurso; guarda en la ficha **y** en su fila del catálogo.
4. Al guardar, el objeto pasa a `en proceso` y la ficha gana el pendiente
   "Aplicar los cambios de esta ficha en el `.tres` y en el juego": el editor **no** toca
   el `.tres`, así no se puede dar por hecho que el cambio está en el juego.

## Criterios de aceptación

- [x] `python3 vault/items-editor/server.py` abre el editor en `127.0.0.1:8765`.
- [x] Lista los 44 objetos con icono y estado; filtro por estado y buscador.
- [x] Guardar cambia ficha y catálogo y deja el objeto `en proceso` con el pendiente.
- [x] Probado sobre una copia del vault (`--root`): alta de valores, cambio de nombre,
  textura y estado, y pendiente añadido sin duplicarse.
- [ ] Revisión de `humano-ruben` en el navegador.

## Resultado

- `vault/items-editor/`: `server.py` (HTTP + API JSON, stdlib), `index.html`, `app.js`,
  `style.css` y `README.md`.
- Rutas: `/api/items` (catálogo + estados + reparto), `/api/items/<slug>` (GET/POST),
  `/assets/...` para los iconos.
- Sin dependencias nuevas ni cambios en el juego.
- **Corregido tras la revisión de Ruben (2026-11-17)**: el CSS y el JS se servían como
  `text/plain` y el navegador no los aplicaba (había que servir el MIME correcto); los
  iconos de la lista pedían `/items/x.png` en vez de `/assets/items/x.png` (404). La
  fuente de la lista pasa a ser `vault/items/*.md` (catálogo solo como respaldo), se añade
  `?slug=` y un visor del `.md` guardado, y el `estado` del formulario arranca en
  `en proceso` para que guardar marque pendiente sin querer.
- UI revisada con Chrome headless: 44 objetos, 44 iconos en 200, CSS `text/css`.
