# GodotSintesi

Roguelike 2D de acción en pixel-art, hecho con **Godot 4.7**. El jugador explora zonas generadas, lucha contra enemigos, recoge consumibles y equipa pasivas que modifican el combate.

## Ejecutar

1. Abre `project.godot` con Godot 4.7.
2. Pulsa **F5**. La escena principal es `scenes/game.tscn`.

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

Los objetos se añaden directamente al inventario o a las pasivas activas. El código está en `scripts/inventory.gd` (`DEBUG_TOOLS`) y está pensado para borrarse cuando termine la fase de pruebas.

## Estructura

- `scenes/`: escenas del juego (`game.tscn`, `player.tscn`, enemigos, inventario).
- `scripts/`: lógica en GDScript (jugador, enemigos, mundo, UI, inventario y coleccionables).
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
