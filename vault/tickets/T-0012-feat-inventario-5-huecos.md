# T-0012 · Inventario de 5 huecos, pasivas paginadas y slots reutilizables

| Campo | Valor |
|---|---|
| Estado | `cerrado` (2026-10-22) |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `humano-ruben` |
| Sistema | inventory / ui |
| Creado | 2026-11-03 (registro retroactivo) |
| Actualizado | 2026-10-22 |
| Ficheros | `scenes/inventory/*`, `scripts/collectables/*`, `passive_ui.gd`, `resources/` |

## Qué se hizo

- Inventario de **5 huecos**: 1-2 skills (no se gastan) y 3-5 consumibles (se gastan). `add_item` enruta por tipo; `PlayerPassives` recibe las pasivas.
- Catálogo de 6 objetos: 3 consumibles (cura 30, stamina 40, cura 60) y 3 pasivas (+6 daño, −25 % daño recibido, +1 vida/s).
- Recogida automática al tocar; drop físico con gravedad, rebote y vaivén (T-0011).
- HUD de pasivas con `GridContainer` de 6 columnas y **10 filas por página** (60 iconos), `←`/`→` con vuelta circular y contador `Pág. X/Y`.
- Pantalla de inventario (Tab/I) en 3 columnas de ancho fijo: personaje + skills + consumibles, coleccionables y preview. Pausa el árbol (`process_mode = ALWAYS` en la pantalla).
- Coleccionables = pasivas activas, paginadas 6×6 (36/página) con `←`/`→` y `Q`/`E`; selección con ratón, `A/D` y `W/S`; `Tab` alterna columna.
- `InventorySlot` reutilizable (estilos en `resources/inventory/`) usado por HUD (18×18) y pantalla de inventario, sin botones creados a mano en `game.tscn`.
- Sin botones de usar/equipar (no se pidieron).

## Trampas registradas

- El giro del sprite va por `sprite_pivot.scale.x`, nunca `flip_h`.
- Los iconos del grid van en orden inverso (lo más nuevo arriba-izquierda) y las filas crecen hacia abajo.
- `focus_mode = NONE` en los slots: `Tab` se gestiona a mano para alternar columnas.

Commits: `2530489`, `8e52811`, `4c7f595`, `58c4a0f`, `37fd815`, `7dfdd41`, `dbff31f`. Docs: `docs/items.md`, `docs/ui.md`.

## Resultado

Sistema de objetos cerrado y documentado. Quedan skills (T-0002), barra llena (T-0003) y el debug (T-0005).
