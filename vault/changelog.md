# Changelog — lo que ya está hecho

_Append-only: se añade arriba lo nuevo, no se reescribe lo viejo._

## 2026-11-10 · `main` — fuera skills, 3 consumibles

| Qué | Dónde | Ticket |
|---|---|---|
| Inventario de 3 consumibles con teclas 1-3; `Skills` eliminado y `docs/items.md` convertido en catálogo completo | `scenes/inventory/inventory.gd`, `inventory_ui.gd`, `inventory_screen.gd`, `inventory_screen.tscn`, `scripts/collectables/Skills.gd`, `project.godot`, `docs/items.md` | [T-0038](tickets/T-0038-quitar-skills-3-consumibles.md) |

## 2026-11-09 · `main` — loot por enemigo, sin presets

| Qué | Dónde | Ticket |
|---|---|---|
| `item_drops` por escena con `LootEntry`; una sola tirada de objetos que suma probabilidades y elige ponderado, y monedas en tirada aparte (varias posibles) | `scripts/enemies/enemy_base.gd`, `scripts/resources/loot_entry.gd`, `scenes/enemies/{orc,werewolf,mutant_toad,slime}.tscn` | [T-0037](tickets/T-0037-loot-por-enemigo-sin-presets.md) |

## 2026-11-09 · `main` — slimes en el bosque y menos lobos

| Qué | Dónde | Ticket |
|---|---|---|
| Bosque rojo: 2 slimes nuevos y lobos de 2 a 1 por chunk | `resources/world/biomes/bosque_rojo.tres` | [T-0036](tickets/T-0036-slime-y-lobo-en-bosque.md) |

## 2026-11-09 · `main` — lobo menos agresivo

| Qué | Dónde | Ticket |
|---|---|---|
| Embestida a 150 px/s, 40 % del diámetro de detección y 1,5 s parado en el destino antes de repetir | `scripts/enemies/werewolf.gd` | [T-0035](tickets/T-0035-lobo-menos-agresivo.md) |

## 2026-11-06 · `main` — inventario al doble

| Qué | Dónde | Ticket |
|---|---|---|
| Ventana 744×380, paneles 168/272/232, fuentes 16-20, huecos 40×40 y coleccionables 32×32 con el icono expandido; el HUD no cambia | `scenes/inventory/inventory_screen.tscn`, `scenes/inventory/inventory_screen.gd` | [T-0034](tickets/T-0034-inventario-al-doble.md) |

## 2026-11-06 · `main` — la sacudida respeta el encuadre de cámara

| Qué | Dónde | Ticket |
|---|---|---|
| La sacudida se suma al `offset` base de la `Camera2D` (60, −70) y lo restaura al terminar, en vez de dejarlo a cero y recentrar la vista para siempre | `scripts/fx.gd` | [T-0033](tickets/T-0033-sacudida-camara-offset-base.md) |

## 2026-11-05 · `main` — daño en el panel y ambiente más ancho

| Qué | Dónde | Ticket |
|---|---|---|
| Fila `Daño` en el panel de stats y panel bajado a (5, 82) para no pisar las monedas | `scripts/player.gd` | [T-0032](tickets/T-0032-panel-dano-y-ambiente-horizontal.md) |
| Emisión de hojas/copos al doble de ancho (extents X ×1,2) y al doble de cantidad (56 hojas, 440 copos) | `scripts/world/biome_particles.gd` | [T-0032](tickets/T-0032-panel-dano-y-ambiente-horizontal.md) |

## 2026-11-05 · `main` — parry retocado y estadísticas del jugador

| Qué | Dónde | Ticket |
|---|---|---|
| Parry de 0,2 s con enfriamiento de 0,3 s, aviso dorado al abrir la ventana y +30 stamina al acertar; la guardia ya no empuja | `scripts/player.gd`, `scripts/fx.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| Estadísticas base: `attack_speed`, `crit_chance`, `crit_damage`, `luck` (la velocidad es `move_speed`); crítico con FX propio | `scripts/player.gd`, `scripts/fx.gd`, `scripts/enemies/enemy_base.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| Panel `UILayer/StatsPanel` a la izquierda, siempre visible y alpha 0,6 | `scripts/player.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |
| La suerte suma `luck × 0,01` a todas las probabilidades de drop | `scripts/enemies/enemy_base.gd` | [T-0031](tickets/T-0031-parry-stamina-y-estadisticas.md) |

## 2026-11-05 · `main` — polvo del bioma, parry y física de pickups

| Qué | Dónde | Ticket |
|---|---|---|
| Polvo teñido con el `grass_color` del bioma (verde en pradera) | `scripts/fx.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Ventana de parry de 0,18 s con chispas, `¡PARRY!`, destello y sacudida | `scripts/player.gd`, `scripts/fx.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Monedas con gravedad, rebote y vaivén; nacen 40 px sobre el suelo | `scripts/collectables/coin.gd`, `scripts/world_generator.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |
| Objetos con salto inicial al dropearse (`drop_hop` 150 px/s) | `item_pickup.gd` | [T-0030](tickets/T-0030-polvo-bioma-parry-y-fisica-de-pickups.md) |

## 2026-11-05 · `main` — polvo a los pies, sangre grande y moco por la hitbox

| Qué | Dónde | Ticket |
|---|---|---|
| El polvo de saltar/aterrizar/correr nace a ras de suelo (`_feet_offset()`) | `scripts/player.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |
| Muerte de enemigo con reventón de sangre en 4 capas y sacudida leve | `scripts/fx.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |
| Moco emitido en caja por toda la hitbox, no desde el centro | `scripts/collectables/moco_emitter.gd` | [T-0029](tickets/T-0029-polvo-pies-sangre-y-moco.md) |

## 2026-11-05 · `main` — efectos de combate y feedback de HUD

| Qué | Dónde | Ticket |
|---|---|---|
| Nodo `fx`: chispas, estallidos, polvo, chispas de pickups, números de daño, sacudida y flash rojo | `scripts/fx.gd`, `scenes/game.tscn` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Enganches de VFX en jugador, enemigos, monedas y pickups | `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/collectables/coin.gd`, `item_pickup.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Pop del contador de monedas y latido de la barra de vida con poca vida | `scripts/player.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |
| Fundido y viento en hojas/copos | `scripts/world/biome_particles.gd` | [T-0028](tickets/T-0028-fx-de-combate-y-feedback-de-hud.md) |

## 2026-11-05 · `main` — nieve separada, bioma de nieve y ambiente

| Qué | Dónde | Ticket |
|---|---|---|
| Overlay del bosque corregido (ya no incluye piedra ni nieve) y nieve extraída a `mountain2_snow.png`, dibujada encima y sin teñir | `assets/map/background/mountain2_gray.png`, `mountain2_snow.png`, `scenes/game.tscn` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| `Biome.rock_color` para la piedra; bioma de nieve con sus colores y enemigos; pesos 0.55/0.3/0.2 | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/*.tres` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| Bosque rojo 1.35/1.1 y pradera 0.95 de amplitud | `resources/world/biomes/*.tres` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |
| Hojas rojas y copos de nieve por bioma (`Biome.ambient`) | `scripts/world/biome_particles.gd`, `scenes/game.tscn` | [T-0027](tickets/T-0027-biooma-nieve-nieve-separada-y-ambiente.md) |

## 2026-11-05 · `main` — un tono por capa de fondo

| Qué | Dónde | Ticket |
|---|---|---|
| Gris calibrado por capa (cercano 92, lejano 116, montaña 172/211) para que los tres fondos no queden del mismo color | `assets/map/background/{pine1,pine2,mountain2}_gray.png` | [T-0026](tickets/T-0026-fondos-con-tono-propio-por-capa.md) |
| El tinte de cada bioma conserva los tres escalones de profundidad en pradera y bosque rojo | `resources/world/biomes/*.tres`, `docs/world.md` | [T-0026](tickets/T-0026-fondos-con-tono-propio-por-capa.md) |

## 2026-11-05 · `main` — gris medio y verde original en la pradera

| Qué | Dónde | Ticket |
|---|---|---|
| Fondos de vegetación con gris medio (~113–129) en vez del gris claro (~165) | `assets/map/background/pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png` | [T-0025](tickets/T-0025-gris-medio-y-verde-original-pradera.md) |
| `Biome.forest_color` separa el tinte de los fondos del césped; la pradera recupera `(27,45,45)` y el bosque rojo usa un rojo saturado | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/*.tres` | [T-0025](tickets/T-0025-gris-medio-y-verde-original-pradera.md) |

## 2026-11-05 · `main` — fondos tintables y terreno por bioma

| Qué | Dónde | Ticket |
|---|---|---|
| Pinos y bosque de la montaña en gris claro; solo los píxeles verdes/teal se convierten y la punta de la montaña queda sin teñir | `assets/map/background/pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png`, `scenes/game.tscn` | [T-0024](tickets/T-0024-fondos-tintables-y-terreno-por-bioma.md) |
| Bosque rojo con relieve más marcado: amplitud ×1.7 y frecuencia ×1.25, mezcladas en la transición de 256 bloques | `scripts/world/biome.gd`, `scripts/world_generator.gd`, `resources/world/biomes/bosque_rojo.tres` | [T-0024](tickets/T-0024-fondos-tintables-y-terreno-por-bioma.md) |

## 2026-11-05 · `main` — biomas por bloque y más bosque rojo

| Qué | Dónde | Ticket |
|---|---|---|
| Bioma y césped decididos por bloque, con transición de 256 bloques (1 chunk) en vez de por chunks | `scripts/world_generator.gd`, `scripts/world/chunk.gd`, `scenes/world/chunk.tscn` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |
| Bosques de fondo teñidos al cambiar de bloque | `scripts/world_generator.gd` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |
| Más bosque rojo: pesos 0.6/0.4 y biomas de ~8 chunks (`biome_frequency` 0.12) | `resources/world/biomes/*.tres`, `scripts/world_generator.gd` | [T-0023](tickets/T-0023-biomas-por-bloque-y-bosque-rojo.md) |

## 2026-11-05 · `main` — KP5 inmortal, pasivas sin stack y caducidad de pickups

| Qué | Dónde | Ticket |
|---|---|---|
| KP5 alterna la inmortalidad del jugador y el aviso de debug lo muestra | `scripts/debug_tools.gd`, `scripts/player.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |
| Las pasivas equipadas no vuelven a recogerse ni a dropearse (`has_passive`/`add_passive` + pool filtrado) | `scripts/collectables/player_passive.gd`, `scripts/collectables/passive_items.gd`, `scripts/enemies/enemy_base.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |
| Pickups: borrado a los 60 s desde el spawn; parpadeo a los 25 s y desaparición a los 30 s desde que se ven; monedas excluidas | `item_pickup.gd` | [T-0022](tickets/T-0022-inmortal-kp5-pasivas-sin-stack-y-caducidad.md) |

## 2026-11-03 · `main` — voladores fuera, reparto y banda plana

| Qué | Dónde | Ticket |
|---|---|---|
| Fantasma y demonio desactivados (`DISABLED_ENEMY_SCENES`) y recuento base a `[4, 2, 1, 2, 2, 2]` | `scripts/world_generator.gd` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Enemigos repartidos en huecos iguales a lo ancho del chunk (±25 % de ruido) | `scripts/world_generator.gd` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Banda plana `#283D43` bajo las montañas en menú y partida | `scenes/main_menu.tscn`, `scenes/game.tscn` | [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |
| Docs de todo el trabajo acumulado y primer commit de la tanda | `docs/`, `vault/` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) / [T-0021](tickets/T-0021-voladores-reparto-y-banda.md) |

## 2026-11-03 · `main` (local, sin commit) — arranque, drops y dificultad

| Qué | Dónde | Ticket |
|---|---|---|
| Caída inicial arreglada: sin parqueo de cámara (saltaba ~270 px al enganchar) y de 2200 → 520 px (~1,7 s) | `scripts/world/fall_intro.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Drops bastante más raros: moneda al 45 %, objeto al 30 %, `Raro` 0.25 y 2 monedas por chunk (antes 8) | `scripts/enemies/enemy_base.gd`, `scripts/world_generator.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Desactivados los 6 objetos originales (loot, debug y los dos pickups de prueba de `game.tscn`) | `scripts/enemies/enemy_base.gd`, `scenes/inventory/inventory.gd`, `scenes/game.tscn` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Balance: `maza` +2, `colmillo_lobo` +3, `pies_ligeros` 10 %, `piedra_oro` 10 % | `resources/*.tres` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Enemigos algo más fuertes (vida ×1.35, daño ×1.25) y slime más pequeño (×1.2) | `scripts/enemies/enemy_base.gd`, `scenes/enemies/slime.tscn` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Más enemigos por chunk con escalada: 3 en los chunks 0–1 y hasta 16 más adelante | `scripts/world_generator.gd` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |
| Fix: los 11 objetos del compañero apuntaban a `assets/icons/`, que no existe | `resources/*.tres` | [T-0020](tickets/T-0020-arranque-drops-y-dificultad.md) |

## 2026-11-03 · `main` (local, sin commit)

| Qué | Dónde | Ticket |
|---|---|---|
| Fixes de prueba: relleno bajo las montañas, sin negro de transición, caída lenta (~7 s), enemigos al doble, iconos a 16 px y enemigos más cerca del spawn | `scenes/main_menu.tscn`, `scripts/world/fall_intro.gd`, `scenes/enemies/*.tscn`, `resources/*.tres`, `scripts/world_generator.gd` | [T-0018](tickets/T-0018-menu-principal-y-caida.md) / [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| Todo lo del compañero (demonio, sapo, lobo, slime, esqueleto, arquero + 11 objetos) y loot por enemigo según su tabla | `scenes/enemies/*.tscn`, `scripts/enemies/*.gd`, `scripts/collectables/*`, `resources/*.tres`, `scripts/player.gd`, `scripts/world_generator.gd` | [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| 8 pasivas nuevas de rana y slime + sección `vault/pasivas/` con un `.md` por enemigo | `resources/*.tres`, `scripts/collectables/`, `vault/pasivas/` | [T-0019](tickets/T-0019-enemigos-y-loot-por-enemigo.md) |
| Nombre del juego **OffBeaten Path** + menú principal (cielo, nubes y montañas) y caída desde el cielo al empezar, como pantalla de carga | `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `project.godot`, `scenes/game.tscn` | [T-0018](tickets/T-0018-menu-principal-y-caida.md) |
| Ciclo día/noche: día 5 min, noche 3 min; la noche solo cambia el color del cielo | `scripts/world/day_night.gd`, `scenes/game.tscn` | [T-0014](tickets/T-0014-ciclo-dia-noche.md) |
| Debug: velocidad x1/x2/x4 (KP7/8/9) y viaje rápido KP4/KP6 | `scripts/debug_tools.gd`, `scripts/player.gd`, `scenes/game.tscn` | [T-0015](tickets/T-0015-debug-velocidad-y-viaje.md) |
| Noche: estrellas, montañas más oscuras y velo negro del 10% | `scripts/world/day_night.gd` | [T-0016](tickets/T-0016-noche-estrellas-y-velo.md) |
| Debug: las velocidades x2/x4 pasan a x5/x20 | `scripts/debug_tools.gd` | [T-0015](tickets/T-0015-debug-velocidad-y-viaje.md) |
| Pasivas de ogro y lobo (9): recursos, efectos y calidad | `resources/*.tres`, `scripts/collectables/*Passive.gd`, `scripts/enemies/enemy_base.gd` | [T-0017](tickets/T-0017-pasivas-ogro-y-lobo.md) |
| Fix: `day_night.gd` no parseaba (dos líneas comidas) y `NightBonusPassive` no infería `night_now`; UID obsoleto en `ghost_projectile.tscn` | `scripts/world/day_night.gd`, `scripts/collectables/NightBonusPassive.gd`, `scenes/enemies/ghost_projectile.tscn` | [T-0017](tickets/T-0017-pasivas-ogro-y-lobo.md) |

## 2026-10-29 · `main`

| Commit | Qué | Ticket |
|---|---|---|
| `a914593` | Loot de enemigos: parentar antes de `global_position` (el offset del chunk se sumaba dos veces) | [T-0011](tickets/T-0011-fix-loot-drops.md) |
| `47647cb` | Cámara: seguimiento sobre `player.global_position` (el lag era permanente) | [T-0009](tickets/T-0009-fix-camara.md) |
| `0e92787` | `stretch/scale_mode="integer"`: fullscreen a 2× exactos | [T-0010](tickets/T-0010-fix-escala-entera.md) |
| `09d1679` | Saltos de 1 tile repartidos en 3 frames (máx. 6 px/frame) | [T-0009](tickets/T-0009-fix-camara.md) |
| `932d79b` | Cámara redondeada a píxel entero; 2 chunks extra cargados | T-0009 / T-0013 |
| `6f79135` | Escala 2× entera, subida de escalón sin frenar, primer chunk seguro | T-0009 / T-0010 |

## 2026-10-25 → 2026-10-27 · `main`

| Commit | Qué | Ticket |
|---|---|---|
| `30b45de` | Más holgura de spawn (el fantasma atacaba al aparecer); cámara en física | T-0009 |
| `b9204c9` | Subida de escalones sin tirones; montañas más suaves | T-0009 |
| `bea8591` | Costuras de chunk, chunks de 256 tiles y menos enemigos | T-0013 |
| `e201ecd` | BIG REFACTOR de escala de pantalla | T-0010 |
| `19d7363` | Mundo procedural con montañas, chunks dinámicos y persistencia | T-0013 |

## 2026-10-22 → 2026-10-23 · `main`

- Pasivas paginadas en HUD (10 filas) e inventario (6 filas): `37fd815`.
- Inventario movido a `scenes/inventory/`, `InventorySlot` reutilizable en HUD: `7dfdd41`, `dbff31f` (T-0012).

## 2026-10-14 → 2026-10-15 · `main`

- Sistema de objetos: inventario de 5 huecos, consumibles, pasivas y loot enemigo (`2530489`, `8e52811`, `4c7f595`, `58c4a0f`) (T-0012).
- Recogida automática al tocar y física de drops (T-0011).

## 2026-09-17 → 2026-10-13 · base

- Movimiento, suelo y tilemaps; parallax y assets (Jorge: `7dd0e62`, `317c66a`, `60f4808`).
- Enemigo base, fantasma con TP y proyectil; orcos 2.0 (Jorge: `9aac4dc`, `1dba7bd`).
- Monedas, stamina y barra de vida.

## Rama del compañero (NO integrada)


**`origin/feat/enemigos-demon-toad-werewolf`** · `685bc30` (2026-10-27, Jorge) · base `58c4a0f` (2026-10-15) · 1 commit sobre su base.

Aporta tres enemigos completos (escena + script + doc) y assets:

| Enemigo | Scripts | Escenas | Doc de la rama |
|---|---|---|---|
| Demonio volador | `demon.gd`, `demon_fire.gd` | `demon.tscn`, `demon_fire.tscn` | `docs/enemigo_demon.md` |
| Sapo mutante | `mutant_toad.gd`, `toad_projectile.gd` | `mutant_toad.tscn`, `toad_projectile.tscn` | `docs/enemigo_mutant_toad.md` |
| Lobo | `werewolf.gd` | `werewolf.tscn` (+ `werewolf.tscn` y `plantilla_enemy.tscn` en la raíz) | `docs/enemigo_werewolf.md` |

También toca `scripts/player.gd` (knockback/knockup/`is_guarding`) y `scripts/world_generator.gd` (zonas). Detalle y plan de integración: [T-0001](tickets/T-0001-integrar-enemigos-companero.md).
