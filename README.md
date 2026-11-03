# GodotSintesi

**OffBeaten Path**: roguelike 2D de acción en pixel-art, hecho con **Godot 4.7**. El jugador explora zonas generadas, lucha contra enemigos, recoge consumibles y equipa pasivas que modifican el combate.

## Ejecutar

1. Abre `project.godot` con Godot 4.7.
2. Pulsa **F5**. La escena principal es `scenes/main_menu.tscn`: **Jugar** (clic o Enter) carga `scenes/game.tscn`, donde el jugador cae desde el cielo hasta el mundo generado.

## Controles

| Acción | Tecla |
|---|---|
| Moverse | `A` / `D` |
| Saltar | `Espacio` / `W` |
| Correr | `Shift` |
| Atacar | Clic izquierdo |
| Defender | Clic derecho / `E` |
| Abrir inventario | `Tab` / `I` |
| Cerrar inventario | `Esc` / `I` |
| Alternar columna del inventario | `Tab` (columna 1 ↔ 2; la preview no se selecciona) |
| Usar hueco 1-2 (skills) | `1` / `2` |
| Usar hueco 3-5 (consumibles) | `3` / `4` / `5` |
| Pasar página de pasivas (HUD) | `←` / `→` |
| Mover selección del inventario | `A` / `D` (anterior/siguiente), `W` / `S` (subir/bajar) dentro de la columna activa |
| Pasar página del inventario | `←` / `→`, `Q` (anterior) / `E` (siguiente) o botones `←` / `→` junto a "Coleccionables" |

El inventario tiene 3 columnas de ancho fijo con contorno: personaje/skills/consumibles, coleccionables y preview. `Tab` alterna entre las dos primeras; la preview nunca se selecciona.

## Debug temporal

Con el teclado numérico (numpad), mientras el juego no está pausado:

| Tecla | Efecto |
|---|---|
| `KP 0` | Vacía el inventario y las pasivas activas |
| `KP 1` | Genera un consumible aleatorio |
| `KP 2` | Genera una pasiva/coleccionable aleatoria |
| `KP 3` | Reservado para skills (todavía no hay objetos) |
| `KP 4` / `KP 6` | Viaje rápido a la izquierda / derecha (64 tiles) y 10 tiles hacia arriba |
| `KP 7` / `KP 8` / `KP 9` | Velocidad del juego x1 / x5 / x20 (`Engine.time_scale`) |

Los objetos se añaden directamente al inventario o a las pasivas activas. El código de los ítems está en `scenes/inventory/inventory.gd` (`DEBUG_TOOLS`) y el de velocidad/viaje en `scripts/debug_tools.gd`; ambos están pensados para borrarse cuando termine la fase de pruebas. La velocidad actual y las teclas se muestran en una etiqueta abajo a la izquierda (`DebugHint`).

## Estructura

- `scenes/`: escenas del juego (`game.tscn`, `player.tscn`, enemigos).
- `scenes/inventory/`: todo el inventario (pantalla, slots, lógica y HUD de consumibles).
- `scripts/`: lógica en GDScript (jugador, enemigos, mundo, UI y coleccionables).
- `resources/inventory/`: estilos de los huecos del inventario.
- `resources/`: objetos de datos (`.tres`) del catálogo.
- `assets/`: sprites, tiles, monedas y efectos.
- `docs/`: documentación viva por sistema.
- `AGENTS.md`: reglas de trabajo y índice de la documentación.

`documentation.md` y los `player.tscn` / `item_pickup.*` de la raíz son material histórico; el juego usa los de `scenes/` y `scripts/`.

## Documentación

Empieza por `AGENTS.md`; los detalles por sistema están en `docs/`:

- `docs/items.md`: inventario, catálogo, drops y debug.
- `docs/ui.md`: HUD, pasivas e inventario.
- `docs/player.md`: movimiento, combate, vida y stamina.
- `docs/enemies.md`: enemigos y loot.
- `docs/world.md`: generación del mundo.
