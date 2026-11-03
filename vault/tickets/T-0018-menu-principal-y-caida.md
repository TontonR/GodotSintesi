# T-0018 · Menú principal y caída inicial (OffBeaten Path)

| Campo | Valor |
|---|---|
| Estado | `hecho` (pendiente de probar en F5) |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | UI / arranque / mundo |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Ficheros | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `scenes/game.tscn`, `scripts/player.gd`, `scripts/world_generator.gd`, `project.godot` |

## Pedido

- Menú principal con fondo de montañas, nubes y cielo.
- Título del juego **OffBeaten Path**, también como nombre del proyecto.
- Al darle a Jugar, el jugador cae desde arriba del todo hacia el mundo generado debajo; la cámara le sigue la caída a partir de cierto punto. La caída puede ser infinita: es una pantalla de carga simulada.

## Qué se hizo

- `project.godot`: `config/name="OffBeaten Path"` y `run/main_scene="res://scenes/main_menu.tscn"`.
- `scenes/main_menu.tscn`: parallax idéntico al de la partida (nubes con autoscroll, montañas, dos capas de pinos) + `Camera2D` con el mismo `offset` que la del jugador; `VBoxContainer` centrado con título (44 px, con sombra) y botón **Jugar**; `CanvasLayer` 20 con `ColorRect` negro para los fundidos.
- `scripts/ui/main_menu.gd`: foco en Jugar al arrancar, fundido desde negro (0.4 s), y al pulsar fundido a negro (`fade_out_seconds` 0.35 s) → `change_scene_to_file`.
- `scripts/world/fall_intro.gd` (`FallIntro`), nodo `fall_intro` al final de `game.tscn`: sube al jugador 2800 px sobre su spawn, lo deja caer a 700 px/s sin control, aparca la cámara para que entre por arriba, activa el seguimiento a los 340 px y devuelve el control al aterrizar. Un negro inicial se funde en 1.2 s.
- `WorldGenerator.is_ready_at(x)`: si el chunk bajo el jugador no existiera, la caída no aterriza (pantalla de carga real, no solo simulada).
- `player.gd`: `control_enabled`, `camera_follow_enabled` y `fall_speed_cap` (por defecto `true`, `true`, `0`, así que el juego normal no cambia) + rama de caída sin input en `_physics_process`.

## Decisiones

- El menú **reutiliza** el parallax de `game.tscn` en vez de un fondo nuevo: se ve igual que el cielo en juego y no hay assets extra.
- La caída es la transición: fundido corto a negro entre escenas y negro que se abre mientras se cae, sin escena de carga aparte.
- La cámara se aparca con el jugador 12 px por encima del borde superior; el enganche lo hace el suavizado propio de la `Camera2D` (no hay tween de cámara).
- El HUD se oculta durante la caída y aparece al aterrizar.

## Ajustes posteriores (2026-11-03, pedidos tras probarlo)

- Relleno del color de la montaña por debajo de la cordillera: `MountainBase`
  (`ColorRect` hijo de `mountains`, `#2D5052`, del propio `mountain2.png`).
- Fuera el negro de transición: ni fundido en el menú ni `ColorRect` en `FallIntro`;
  Jugar carga la partida directamente y se entra viendo el cielo.
- Caída más lenta: `fall_height_px` 2800 → 2200 y `fall_speed` 700 → 300 px/s (~7 s),
  con la cámara enganchando a los 200 px.

## Pendiente

- Probar en F5 (no se ha ejecutado Godot): encuadre del fondo del menú, duración de la caída y que el aterrizaje devuelva el control.
- Si el fondo del menú queda descolocado, mover los `scroll_offset` del parallax del menú (son independientes de `game.tscn`).
