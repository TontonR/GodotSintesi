# Bitácora — sesiones y acuerdos

_Append-only. Se añade al final, con fecha, firma y qué se tocó._

Formato de entrada:

```
## AAAA-MM-DD · `<firma>` · <título corto>
- Qué se ha hecho / qué se va a hacer.
- Ficheros o tickets afectados.
- Acuerdos, dudas o bloqueos.
```

---

## 2026-11-03 · `buffy` · Montaje del vault

- Creada la infraestructura `vault/` (contrato, estado, roadmap, changelog, bitácora, tickets).
- Traído al vault el trabajo del compañero desde `origin/feat/enemigos-demon-toad-werewolf` (`685bc30`, 2026-10-27): demonio volador, sapo mutante y lobo, con su `player.gd` (knockback/knockup) y `world_generator.gd` (zonas).
- **No se ha mergeado ni modificado código**: su rama sale de `58c4a0f`, antes del mundo por chunks y de los arreglos de cámara/escala. La integración queda como T-0001 con plan de port.
- Abiertos T-0001…T-0008 y registrados los cierres recientes en T-0009…T-0013.
- Añadido el vault al índice de `AGENTS.md` para que ambos agentes lo vean al arrancar.
- Pendiente de confirmar por `opencode-jorge`: qué está tocando ahora y si su rama es la definitiva de los tres enemigos.

## 2026-11-03 · `buffy` · Ciclo día/noche (T-0014)

- Nuevo `scripts/world/day_night.gd` (`DayNightCycle`) y nodo `day_night` en `scenes/game.tscn`: día 300 s, noche 180 s, fundido de 12 s.
- La noche solo cambia el color del cielo vía `RenderingServer.set_default_clear_color`; **no** se oscurece el juego.
- Afectados: `scenes/game.tscn`, `docs/world.md`. Ticket T-0014, cerrado el mismo día. Sin commit.

## 2026-11-03 · `buffy` · Debug de velocidad y viaje rápido (T-0015)

- Nuevo `scripts/debug_tools.gd` (`DebugTools`, nodo `debug_tools` en `game.tscn`): KP7/KP8/KP9 = x1/x2/x4 (`Engine.time_scale`), KP4/KP6 = viaje de 64 tiles con 10 de subida.
- `player.debug_teleport()` nuevo: corta inercia, limpia desfase de escalón y reinicia la cámara.
- Los ítems de prueba KP0-KP3 siguen en `scenes/inventory/inventory.gd`, sin tocar.
- Afectados: `scenes/game.tscn`, `scripts/player.gd`, `README.md`, `docs/player.md`. Ticket T-0015. Sin commit.

## 2026-11-03 · `buffy` · Noche con estrellas, montañas oscuras y velo (T-0016)

- `day_night.gd`: `_night_factor_at()` da el 0→1 de la noche con el mismo fundido de 12 s que el cielo; de ese factor cuelgan los tres efectos.
- Estrellas: `StarField` interno en `CanvasLayer` `layer = -1` (detrás del parallax), 110 puntos de 2 px con semilla fija.
- Montañas: `modulate` de `../mountains` de blanco a `Color(0.33, 0.36, 0.52)`.
- Velo: `ColorRect` negro al 10% en `layer = 11`, encima del HUD, con `mouse_filter = IGNORE`.
- Sigue sin `CanvasModulate`: tiles y sprites no se oscurecen.
- Afectados: `docs/world.md`. Ticket T-0016. Sin commit.

## 2026-11-03 · `buffy` · Velocidades de debug x5 y x20 (T-0015)

- Ajuste del debug de T-0015: `SPEEDS` pasa a `[1.0, 5.0, 20.0]` y las etiquetas a `x1/x5/x20`; KP7/KP8/KP9 igual.
- Afectados: `scripts/debug_tools.gd`, `README.md`, `docs/player.md`. Ticket T-0015. Sin commit.

## 2026-11-03 · `buffy` · Pasivas de ogro y lobo (T-0017)

- Jorge pasó la tabla de 9 pasivas (5 de ogro, 4 de lobo) con efecto, enemigo y calidad; queda copiada en el ticket T-0017.
- Cuatro scripts nuevos: `StatBonusPassive`, `CoinDropBonusPassive`, `LowHealthAttackPassive`, `NightBonusPassive`; un `.tres` por objeto.
- `player.gd`: `add_max_health`, `add_max_stamina`, `add_attack_bonus`, `add_speed_bonus`. `day_night.gd`: `is_night()`. `Items`: campo `quality`. `EnemyBase._drop_loot()`: bonus de moneda de las pasivas.
- Iconos provisionales buscados en `assets/19+ icons` y `assets/coins` (la tabla no traía rutas). Los 9 añadidos a `_DEBUG_PASSIVES` (KP2). Drops por enemigo pendientes.
- Afectados: `docs/items.md`. Ticket T-0017 (en curso). Sin commit.

## 2026-11-03 · `buffy` · Errores de parse al abrir el proyecto (T-0017)
- `day_night.gd`: una edición previa había comido dos saltos de línea, así que `func _night_factor_at` y `func _apply_state` quedaron pegados a la línea anterior (el primero dentro de un `##`, de ahí el `cycle` duplicado). Rehechas las dos líneas.
- `_apply_state`: el local `is_night` pasa a `show_night` para no tapar el método público `is_night()`.
- `NightBonusPassive._refresh()`: `bool(_night.call("is_night"))` con `is_instance_valid`, en vez de encadenar `and` sobre Variant.
- `scenes/enemies/ghost_projectile.tscn`: fuera el `uid` del PNG del proyectil (apuntaba a uno viejo); se resuelve por ruta de texto. Cero UIDs desajustados en el resto de escenas.
- El aviso de `NaN` en `JSON.stringify()` no sale de código del proyecto (no hay ninguna llamada); es del editor.

## 2026-11-03 · `buffy` · Menú principal y caída inicial (T-0018)

- Juego renombrado a **OffBeaten Path** (`config/name`) y `run/main_scene` pasa a `scenes/main_menu.tscn`.
- Menú: mismo parallax que la partida (nubes con autoscroll, montañas, dos capas de pinos) + título 44 px y botón Jugar; fundido a negro antes de `change_scene_to_file`.
- `scripts/world/fall_intro.gd`: al entrar en la partida sube al jugador 2800 px, lo deja caer a 700 px/s sin control, aparca la cámara (entra por arriba), la engancha a los 340 px y devuelve el control al aterrizar. Negro inicial que se funde en 1.2 s.
- `player.gd` gana `control_enabled`, `camera_follow_enabled` y `fall_speed_cap` (por defecto = comportamiento normal). `WorldGenerator.is_ready_at(x)` evita aterrizar sin mundo cargado.
- Afectados: `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `scenes/game.tscn`, `scripts/player.gd`, `scripts/world_generator.gd`, `project.godot`, `README.md`, `docs/ui.md`, `docs/player.md`, `docs/world.md`. Ticket T-0018. Sin commit.

## 2026-11-03 · `buffy` · Enemigos del compañero y loot por enemigo (T-0019)

- Traídos con `git checkout` (sin merge): demonio, sapo mutante, lobo, slime, esqueleto y arquero (9 scripts, 9 escenas, 3 `SpriteFrames`, 18 assets) y 11 objetos del compañero con sus 10 scripts + `player_projectile`.
- API nueva para que esos scripts funcionen: `take_damage_from` con knockback/knockup/bloqueo, `is_guarding()`, `multiply_move_speed()`, hooks `on_player_attack_started` / `on_player_blocked` / `on_enemy_killed` / `on_player_take_damage(amount, attacker)`, `EnemyBase.apply_slow()` y `WorldGenerator.add_to_group("world_generator")`.
- Loot: `loot_preset` en la escena (`Ogro`, `Lobo`, `Rana`, `Slime`) + `PRESET_POOLS` en `EnemyBase`; los `Raro` pesan 0.35. El arquero se queda con el pool genérico porque su tabla venía vacía.
- 8 objetos nuevos: saliva, lengua, burbuja y túberculos (rana); moco, poción de mocos, moco compacto y corazón mucosil (slime), con `MocoEmitter` de partículas generadas por código y nube de veneno dibujada por código.
- Sección nueva `vault/pasivas/`: `README.md` + `ogro.md`, `lobo.md`, `rana.md`, `arquero.md` y `slime.md`.
- Afectados: `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/world_generator.gd`, `scripts/collectables/*`, `resources/*.tres`, `scenes/inventory/inventory.gd`, `docs/items.md`, `docs/enemies.md`. Sin commit.

## 2026-11-03 · `buffy` · Seis arreglos de la primera prueba (T-0018/T-0019)

- Menú: `MountainBase`, `ColorRect` hijo de `mountains` con el color base de `mountain2.png` (`#2D5052`), para tapar el cielo por debajo de la cordillera.
- Fuera el negro de transición: borrados el `CanvasLayer` `Fade` del menú y el `ColorRect` de `FallIntro`; Jugar hace `change_scene_to_file` directo.
- Caída: 2800 → 2200 px de altura y 700 → 300 px/s (~7 s), cámara enganchando a los 200 px.
- Enemigos del compañero al doble: `scale = Vector2(2, 2)` en la raíz de demon, mutant_toad, werewolf, slime, skeleton y archer.
- Objetos enormes: los iconos eran de 380×380; recortados los 15 usados a 16×16 en `assets/items/iconos/` y los 16 `.tres` reapuntados (también los 9 de T-0017).
- Spawn: `enemy_safe_gap_tiles` 20 y el chunk 0 ya genera enemigos a partir de `safe_start_tiles + 20` (antes el chunk entero era zona segura).
- Afectados: `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `scripts/world_generator.gd`, `scenes/enemies/*.tscn`, `resources/*.tres`, `docs/ui.md`, `docs/world.md`, `docs/items.md`, `docs/enemies.md`. Sin commit.

## 2026-11-03 · `buffy` · Arranque, drops raros y dificultad (T-0020)

- Caída: el "bugeo" era la cámara. `_park_camera()` movía la `Camera2D`, pero es **hija del jugador**: el parqueo viajaba con él (el jugador se quedaba clavado cerca del borde superior) y al activar `camera_follow_enabled` a los 200 px la vista saltaba ~270 px, que es lo que se veía como tirón. Fuera parqueo, fuera `follow_after_px`: la cámara sigue desde el primer frame. Altura 2200 → 520 px (~1,7 s) porque eran 7 s de cielo vacío; `max_seconds` 6 s evita dejar el control bloqueado.
- Drops: `coin_drop_chance` 45 % (1 moneda), `item_drop_chance` 30 %, `rare_loot_weight` 0.25 y `coins_per_chunk` 2. `loot_table` se construye entera en `_build_loot_table()` (moneda + pool del preset si lo hay).
- Objetos originales: `DROP_ITEMS` eliminado (era lo único que los usaba en el loot), fuera del debug de `inventory.gd` y borrados los nodos `drop_pocion_cura`/`drop_pocion_stamina` de `game.tscn` con sus `ext_resource`. Los `.tres` siguen en `resources/`, sin referencias.
- Dificultad: `health_multiplier` 1.35 y `attack_multiplier` 1.25 en `EnemyBase._ready()`, después de que los hijos y las escenas hayan fijado sus stats. Cubre también proyectiles porque usan `base_attack`.
- Densidad: base `[3, 2, 2, 1, 1, 1, 1, 1]` × `_enemy_count_multiplier()` (chunks 0–1 al 50 %, +20 %/chunk, tope ×1.8). `floori` por tipo: 3 en los primeros, hasta 16 en los maduros.
- Slime a ×1.2 (el resto de los nuevos sigue a ×2).
- Bug encontrado por el barrido de rutas: los 11 `.tres` del compañero cargaban iconos de `res://assets/icons/`, que no existe en el repo; reapuntados a los recortes de 16×16 de `assets/items/iconos/` (moneda_oro para `codicia`). Ahora `grep assets/icons` en `resources/` da 0.
- Afectados: `scripts/world/fall_intro.gd`, `scripts/world_generator.gd`, `scripts/enemies/enemy_base.gd`, `scenes/enemies/slime.tscn`, `scenes/game.tscn`, `scenes/inventory/inventory.gd`, `resources/*.tres`, `docs/world.md`, `docs/enemies.md`, `docs/items.md`.

## 2026-11-03 · `buffy` · Voladores fuera, reparto y banda bajo montañas (T-0021)

- Fantasma y demonio fuera de `enemy_scenes` (escenas y scripts intactos) y anotados en `WorldGenerator.DISABLED_ENEMY_SCENES` para que la vuelta sea copiar dos líneas. Recuento base a `[4, 2, 1, 2, 2, 2]`: 13 por chunk, 6 en los chunks 0–1 y 16 con el tope ×1.8.
- Reparto: `_generate_chunk` ya no tira un `randi_range(min_x, max_x)` por enemigo. Monta `spawn_scenes` (un tipo por enemigo), calcula `slot_width = (max_x - min_x + 1) / total` y coloca al enésimo en el centro de su hueco ±25 %. El RNG se sigue consumiendo una vez por enemigo (aunque esté muerto), así que la semilla da las mismas posiciones.
- `MountainBase` en `scenes/game.tscn` (hijo de `mountains`, local y 62→400, `mouse_filter` IGNORE) con `#283D43` (`Color(0.157, 0.239, 0.263)`), y el del menú cambia de `#2D5052` a ese mismo color: la banda es la misma en menú y partida y `day_night.gd` la oscurece con el resto del nodo `mountains`.
- Documentados T-0020 y T-0021 en `docs/` y en el vault, y commit de toda la tanda (día/noche, menú, caída, 27 objetos, enemigos y ajustes de balance) sin push.
- Afectados: `scripts/world_generator.gd`, `scenes/main_menu.tscn`, `scenes/game.tscn`, `docs/ui.md`, `docs/world.md`, `docs/enemies.md`, `vault/`.
