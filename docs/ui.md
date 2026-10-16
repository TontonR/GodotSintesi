# Interfaz — HUD, grid de pasivas y pantalla de inventario

_2026-10-15 · rama `feat/skills-and-complex-passives`_

## Grid de pasivas (`PassiveUI` · `UILayer/PassiveBar`)

- `GridContainer` de **6 columnas** anclado arriba-derecha (bajo vida/stamina), `grow_horizontal = 0` (al añadir filas se ensancha hacia la izquierda) y `columns = 6`.
- **Orden**: lo más nuevo **arriba a la izquierda** (se itera `active_passives` al revés dentro de la página visible); filas creciendo hacia abajo.
- **Paginación (2026-10-15)**: solo **10 filas por página** (60 iconos); **← / →** (`ui_left`/`ui_right`) pasan de página con vuelta circular, y solo si hay más de una. ⚠️ Las mismas flechas también **caminan/saltan** al jugador (`player.gd` lee `KEY_LEFT/RIGHT/UP` en crudo): si molesta, hay que quitarle las flechas al movimiento (pendiente de decidir).
- Iconos 12×12 con alpha 0.55, `h/v_separation` 2. Refresco por `PlayerPassives.passives_changed` → `_refresh` (patrón bind existente).

## Pantalla de inventario (`scenes/inventory_screen.tscn` · `scripts/inventory_screen.gd`)

- **Apertura**: acción `inventory` = **Tab** o **I** (nueva en `project.godot`); **Esc** cierra. **Pausa el juego** (`get_tree().paused = true`; la pantalla vive con `process_mode = ALWAYS` y `_exit_tree` se asegura de no dejar pausado el árbol).
- **Layout de 3 columnas (2026-10-15)**: izquierda = retrato del jugador (copia de `SpritePivot/AnimatedSprite2D`, animación `idle`) + **Habilidades** (slots 1-2) + **Consumibles** (slots 3-5); centro = **Coleccionables**; derecha = detalle. Ventana 372×190 centrada + fondo atenuado.
- **Coleccionables = las pasivas activas** (`PlayerPassives.active_passives`, simples o complejas, las mismas del HUD). **Paginados**: `GridContainer` de 6 columnas × **6 filas por página** (36/página, botones 16×16); la cabecera añade el indicador **"Coleccionables · 1/3"** cuando hay varias páginas.
- **Derecha** (panel derecho): icono 64 px, **nombre**, línea de **estadísticas** y **descripción** del elemento seleccionado. Estadísticas: vida/stamina de consumibles; bonus de `Skills`; de las pasivas se leen propiedades dinámicas (`bonus`, `reduction`, `heal_per_tick`+`interval`) con `"prop" in item` + `item.get()`.
- **Selección**: ratón (clic en el hueco) y teclado (flechas con `ui_*`, wrapping); resaltado = borde azul 2 px. **Navegación = páginas**: al salir del borde visible de los coleccionables (→ en el último / ← en el primero de la página) **se cambia de página** y la selección salta al otro extremo; así se recorre todo caminando con las flechas. Huecos vacíos = botones deshabilitados con el mismo fondo; `focus_mode = NONE` para que Tab no mueva foco.
- **Sin** botones de usar/equipar (no pedidos). Teclas 1-5 no responden mientras está abierta (la pausa lo bloquea). Se re-monta con `slots_changed`/`passives_changed` solo si está visible.

## Convención de idioma (2026-10-15)

- **En inglés**: identificadores (funciones/vars/constantes/enum), `@export`, títulos de `@export_group` y doc `##` (lo que muestra el inspector).
- **En español**: comentarios `#` normales, textos de UI (labels, `.tres`) y `docs/`.
- Alcance del refactor: sistemas de objetos/inventario/UI/pasivas/loot — `item_pickup.gd`, `inventory.gd`, `inventory_ui.gd`, `passive_ui.gd`, `inventory_screen.gd`, `player_passive.gd`, `collectables/*`, `loot_drop_item.gd`. **Sin tocar**: `player.gd`, `enemy_base.gd`, `world_generator.gd`, `ghost*.gd`.
