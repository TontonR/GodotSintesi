# Interfaz — HUD, grid de pasivas y pantalla de inventario

_2026-10-15 · 2026-10-22 · rama `feat/skills-and-complex-passives`_

## Grid de pasivas (`PassiveUI` · `UILayer/PassiveBar`)

- `GridContainer` de **6 columnas** anclado arriba-derecha (bajo vida/stamina), `grow_horizontal = 0` (al añadir filas se ensancha hacia la izquierda) y `columns = 6`.
- **Orden**: lo más nuevo **arriba a la izquierda** (se itera `active_passives` al revés dentro de la página visible); filas creciendo hacia abajo.
- **Paginación (2026-10-20)**: solo **10 filas por página** (60 iconos); **← / →** (`ui_left`/`ui_right`) pasan de página con vuelta circular. El contador `Pág. X/Y` (`UILayer/PassivePageLabel`) está **encima del grid** y solo se ve si hay más de una página. Las flechas ya no mueven al jugador (solo A/D + Espacio/W).
- Iconos 12×12 con alpha 0.55, `h/v_separation` 2. Refresco por `PlayerPassives.passives_changed` → `_refresh` (patrón bind existente).

## Panel de estadísticas (2026-11-05)

- `UILayer/StatsPanel`: `GridContainer` de **2 columnas** anclado arriba-izquierda en `position (5, 82)`, por debajo de la línea de monedas (y≈63) para no taparla. Lo crea `player.gd::_ensure_stats_ui()` si no existe, igual que las barras de vida/stamina.
- **Siempre visible**, fuente 9 con sombra y `modulate` alpha **0,6** para que no tape el juego. Seis filas: `Daño`, `Vel. ataque`, `Daño crítico`, `Prob. crítico`, `Velocidad`, `Suerte`; valores en dorado claro alineados a la derecha.
- Solo se refresca cuando cambia algo (`_stats_dirty`): no reescribe etiquetas cada frame. Los valores salen de `attack_speed`, `crit_damage`, `crit_chance`, `move_speed` y `luck` del jugador.

## Pantalla de inventario (`scenes/inventory/inventory_screen.tscn` · `scenes/inventory/inventory_screen.gd`)

- **Apertura**: acción `inventory` = **Tab** o **I** (nueva en `project.godot`); **Esc** o **I** cierra. Con la pantalla abierta, **Tab alterna entre la columna 1 y la 2** (no cierra). **Pausa el juego** (`get_tree().paused = true`; la pantalla vive con `process_mode = ALWAYS` y `_exit_tree` se asegura de no dejar pausado el árbol).
- **Layout de 3 columnas (2026-10-20)**: izquierda = retrato del jugador (copia de `SpritePivot/AnimatedSprite2D`, animación `idle`) + **Habilidades** (slots 1-2) + **Consumibles** (slots 3-5); centro = **Coleccionables**; derecha = detalle/preview. Cada columna es un `PanelContainer` con **ancho fijo** (84/136/116 px) y contorno propio, así que no se redimensiona con el contenido. Ventana 372×190 centrada + fondo atenuado.
- **Coleccionables = las pasivas activas** (`PlayerPassives.active_passives`, simples o complejas, las mismas del HUD). **Paginados**: `GridContainer` de 6 columnas × **6 filas por página** (36/página, botones 16×16); la cabecera muestra **"Coleccionables"**, el contador **X/Y** y las flechas **← / →** justo al lado.
- **Derecha** (panel derecho): icono 64 px, **nombre**, línea de **estadísticas** y **descripción** del elemento seleccionado. Estadísticas: vida/stamina de consumibles; bonus de `Skills`; de las pasivas se leen propiedades dinámicas (`bonus`, `reduction`, `heal_per_tick`+`interval`) con `"prop" in item` + `item.get()`.
- **GUI**: la estructura (paneles, labels y grids) vive en el `.tscn`; el código solo instancia/rellena los huecos dinámicos (`InventorySlot`) y enlaza los datos del `Inventory`/`PlayerPassives`.
- **Slots**: `InventorySlot` (`scenes/inventory/inventory_slot.tscn`) es un `Button` reutilizable con estilos en `resources/inventory/`; `InventoryScreen` lo instancia vía `@export var slot_scene` y `_refresh()` solo rellena icono/selección. **HUD**: `InventoryUI` instancia el mismo slot con `preload` (18×18) para skills/consumibles, sin crear botones a mano en `game.tscn`.
- **Selección (2026-10-20)**: ratón (clic en el hueco), **A/D** anterior/siguiente dentro de la columna activa y **W/S** suben/bajan dentro de la columna activa (izquierda: skills ↔ consumibles; centro: filas del grid). **Tab** alterna entre columna 1 y 2; la columna 3 (preview) nunca se selecciona. Resaltado = borde azul 1 px, mismo ancho que el normal (el hueco no cambia de tamaño) y **conserva el azul al pasar el ratón**. **Páginas**: **← / →** y **Q** (anterior/izquierda) / **E** (siguiente/derecha) cambian de página y seleccionan el primer coleccionable; los botones **← / →** están en la cabecera, al lado de "Coleccionables". Huecos vacíos = botones deshabilitados con el mismo fondo; `focus_mode = NONE` (Tab se gestiona a mano para alternar columnas).
- **Sin** botones de usar/equipar (no pedidos). Teclas 1-5 no responden mientras está abierta (la pausa lo bloquea). Se re-monta con `slots_changed`/`passives_changed` solo si está visible.

## Menú principal (2026-11-03)

- `scenes/main_menu.tscn` + `scripts/ui/main_menu.gd`, ahora `run/main_scene` de `project.godot`. El juego se llama **OffBeaten Path** (`config/name`).
- Fondo: el mismo parallax de la partida (nubes, montañas y dos capas de pinos, `z_index` -100) sobre el cielo, que es el `default_clear_color` del proyecto. `Camera2D` con el mismo `offset (60,-70)` que la del jugador para que las capas caigan en el mismo sitio que en juego.
- UI en `CanvasLayer` 10: `VBoxContainer` centrado con el título (Label 44 px, sombra) y el botón `Jugar` (con foco al arrancar, así que Enter/Espacio también sirven).
- Sin fundidos: Jugar llama directo a `change_scene_to_file("res://scenes/game.tscn")` (el negro de transición se quitó el 2026-11-03).
- `MountainBase`: `ColorRect` hijo de `mountains` (local y 62 → 400, 2064 px de ancho) con `#283D43` (`Color(0.157, 0.239, 0.263)`), para que no se vea cielo por debajo de la cordillera. Desde el 2026-11-03 está **también** en `game.tscn` con el mismo color: la banda plana se ve siempre, en el menú y en partida, y el ciclo día/noche la oscurece junto al resto del nodo `mountains`.
- La partida empieza con la caída desde el cielo (`FallIntro`, ver `docs/world.md`).

## Convención de idioma (2026-10-15)

- **En inglés**: identificadores (funciones/vars/constantes/enum), `@export`, títulos de `@export_group` y doc `##` (lo que muestra el inspector).
- **En español**: comentarios `#` normales, textos de UI (labels, `.tres`) y `docs/`.
- Alcance del refactor: sistemas de objetos/inventario/UI/pasivas/loot — `item_pickup.gd`, `scenes/inventory/inventory.gd`, `scenes/inventory/inventory_ui.gd`, `passive_ui.gd`, `scenes/inventory/inventory_screen.gd`, `player_passive.gd`, `collectables/*`, `loot_drop_item.gd`. **Sin tocar**: `player.gd`, `enemy_base.gd`, `world_generator.gd`, `ghost*.gd`.
