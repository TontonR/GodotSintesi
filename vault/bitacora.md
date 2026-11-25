# BitÃ¡cora â€” sesiones y acuerdos

_Append-only. Se aÃ±ade al final, con fecha, firma y quÃ© se tocÃ³._

Formato de entrada:

```
## AAAA-MM-DD Â· `<firma>` Â· <tÃ­tulo corto>
- QuÃ© se ha hecho / quÃ© se va a hacer.
- Ficheros o tickets afectados.
- Acuerdos, dudas o bloqueos.
```

---

## 2026-11-03 Â· `buffy` Â· Montaje del vault

- Creada la infraestructura `vault/` (contrato, estado, roadmap, changelog, bitÃ¡cora, tickets).
- TraÃ­do al vault el trabajo del compaÃ±ero desde `origin/feat/enemigos-demon-toad-werewolf` (`685bc30`, 2026-10-27): demonio volador, sapo mutante y lobo, con su `player.gd` (knockback/knockup) y `world_generator.gd` (zonas).
- **No se ha mergeado ni modificado cÃ³digo**: su rama sale de `58c4a0f`, antes del mundo por chunks y de los arreglos de cÃ¡mara/escala. La integraciÃ³n queda como T-0001 con plan de port.
- Abiertos T-0001â€¦T-0008 y registrados los cierres recientes en T-0009â€¦T-0013.
- AÃ±adido el vault al Ã­ndice de `AGENTS.md` para que ambos agentes lo vean al arrancar.
- Pendiente de confirmar por `opencode-jorge`: quÃ© estÃ¡ tocando ahora y si su rama es la definitiva de los tres enemigos.

## 2026-11-03 Â· `buffy` Â· Ciclo dÃ­a/noche (T-0014)

- Nuevo `scripts/world/day_night.gd` (`DayNightCycle`) y nodo `day_night` en `scenes/game.tscn`: dÃ­a 300 s, noche 180 s, fundido de 12 s.
- La noche solo cambia el color del cielo vÃ­a `RenderingServer.set_default_clear_color`; **no** se oscurece el juego.
- Afectados: `scenes/game.tscn`, `docs/world.md`. Ticket T-0014, cerrado el mismo dÃ­a. Sin commit.

## 2026-11-03 Â· `buffy` Â· Debug de velocidad y viaje rÃ¡pido (T-0015)

- Nuevo `scripts/debug_tools.gd` (`DebugTools`, nodo `debug_tools` en `game.tscn`): KP7/KP8/KP9 = x1/x2/x4 (`Engine.time_scale`), KP4/KP6 = viaje de 64 tiles con 10 de subida.
- `player.debug_teleport()` nuevo: corta inercia, limpia desfase de escalÃ³n y reinicia la cÃ¡mara.
- Los Ã­tems de prueba KP0-KP3 siguen en `scenes/inventory/inventory.gd`, sin tocar.
- Afectados: `scenes/game.tscn`, `scripts/player.gd`, `README.md`, `docs/player.md`. Ticket T-0015. Sin commit.

## 2026-11-03 Â· `buffy` Â· Noche con estrellas, montaÃ±as oscuras y velo (T-0016)

- `day_night.gd`: `_night_factor_at()` da el 0â†’1 de la noche con el mismo fundido de 12 s que el cielo; de ese factor cuelgan los tres efectos.
- Estrellas: `StarField` interno en `CanvasLayer` `layer = -1` (detrÃ¡s del parallax), 110 puntos de 2 px con semilla fija.
- MontaÃ±as: `modulate` de `../mountains` de blanco a `Color(0.33, 0.36, 0.52)`.
- Velo: `ColorRect` negro al 10% en `layer = 11`, encima del HUD, con `mouse_filter = IGNORE`.
- Sigue sin `CanvasModulate`: tiles y sprites no se oscurecen.
- Afectados: `docs/world.md`. Ticket T-0016. Sin commit.

## 2026-11-03 Â· `buffy` Â· Velocidades de debug x5 y x20 (T-0015)

- Ajuste del debug de T-0015: `SPEEDS` pasa a `[1.0, 5.0, 20.0]` y las etiquetas a `x1/x5/x20`; KP7/KP8/KP9 igual.
- Afectados: `scripts/debug_tools.gd`, `README.md`, `docs/player.md`. Ticket T-0015. Sin commit.

## 2026-11-03 Â· `buffy` Â· Pasivas de ogro y lobo (T-0017)

- Jorge pasÃ³ la tabla de 9 pasivas (5 de ogro, 4 de lobo) con efecto, enemigo y calidad; queda copiada en el ticket T-0017.
- Cuatro scripts nuevos: `StatBonusPassive`, `CoinDropBonusPassive`, `LowHealthAttackPassive`, `NightBonusPassive`; un `.tres` por objeto.
- `player.gd`: `add_max_health`, `add_max_stamina`, `add_attack_bonus`, `add_speed_bonus`. `day_night.gd`: `is_night()`. `Items`: campo `quality`. `EnemyBase._drop_loot()`: bonus de moneda de las pasivas.
- Iconos provisionales buscados en `assets/19+ icons` y `assets/coins` (la tabla no traÃ­a rutas). Los 9 aÃ±adidos a `_DEBUG_PASSIVES` (KP2). Drops por enemigo pendientes.
- Afectados: `docs/items.md`. Ticket T-0017 (en curso). Sin commit.

## 2026-11-03 Â· `buffy` Â· Errores de parse al abrir el proyecto (T-0017)
- `day_night.gd`: una ediciÃ³n previa habÃ­a comido dos saltos de lÃ­nea, asÃ­ que `func _night_factor_at` y `func _apply_state` quedaron pegados a la lÃ­nea anterior (el primero dentro de un `##`, de ahÃ­ el `cycle` duplicado). Rehechas las dos lÃ­neas.
- `_apply_state`: el local `is_night` pasa a `show_night` para no tapar el mÃ©todo pÃºblico `is_night()`.
- `NightBonusPassive._refresh()`: `bool(_night.call("is_night"))` con `is_instance_valid`, en vez de encadenar `and` sobre Variant.
- `scenes/enemies/ghost_projectile.tscn`: fuera el `uid` del PNG del proyectil (apuntaba a uno viejo); se resuelve por ruta de texto. Cero UIDs desajustados en el resto de escenas.
- El aviso de `NaN` en `JSON.stringify()` no sale de cÃ³digo del proyecto (no hay ninguna llamada); es del editor.

## 2026-11-03 Â· `buffy` Â· MenÃº principal y caÃ­da inicial (T-0018)

- Juego renombrado a **OffBeaten Path** (`config/name`) y `run/main_scene` pasa a `scenes/main_menu.tscn`.
- MenÃº: mismo parallax que la partida (nubes con autoscroll, montaÃ±as, dos capas de pinos) + tÃ­tulo 44 px y botÃ³n Jugar; fundido a negro antes de `change_scene_to_file`.
- `scripts/world/fall_intro.gd`: al entrar en la partida sube al jugador 2800 px, lo deja caer a 700 px/s sin control, aparca la cÃ¡mara (entra por arriba), la engancha a los 340 px y devuelve el control al aterrizar. Negro inicial que se funde en 1.2 s.
- `player.gd` gana `control_enabled`, `camera_follow_enabled` y `fall_speed_cap` (por defecto = comportamiento normal). `WorldGenerator.is_ready_at(x)` evita aterrizar sin mundo cargado.
- Afectados: `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `scenes/game.tscn`, `scripts/player.gd`, `scripts/world_generator.gd`, `project.godot`, `README.md`, `docs/ui.md`, `docs/player.md`, `docs/world.md`. Ticket T-0018. Sin commit.

## 2026-11-03 Â· `buffy` Â· Enemigos del compaÃ±ero y loot por enemigo (T-0019)

- TraÃ­dos con `git checkout` (sin merge): demonio, sapo mutante, lobo, slime, esqueleto y arquero (9 scripts, 9 escenas, 3 `SpriteFrames`, 18 assets) y 11 objetos del compaÃ±ero con sus 10 scripts + `player_projectile`.
- API nueva para que esos scripts funcionen: `take_damage_from` con knockback/knockup/bloqueo, `is_guarding()`, `multiply_move_speed()`, hooks `on_player_attack_started` / `on_player_blocked` / `on_enemy_killed` / `on_player_take_damage(amount, attacker)`, `EnemyBase.apply_slow()` y `WorldGenerator.add_to_group("world_generator")`.
- Loot: `loot_preset` en la escena (`Ogro`, `Lobo`, `Rana`, `Slime`) + `PRESET_POOLS` en `EnemyBase`; los `Raro` pesan 0.35. El arquero se queda con el pool genÃ©rico porque su tabla venÃ­a vacÃ­a.
- 8 objetos nuevos: saliva, lengua, burbuja y tÃºberculos (rana); moco, pociÃ³n de mocos, moco compacto y corazÃ³n mucosil (slime), con `MocoEmitter` de partÃ­culas generadas por cÃ³digo y nube de veneno dibujada por cÃ³digo.
- SecciÃ³n nueva `vault/pasivas/`: `README.md` + `ogro.md`, `lobo.md`, `rana.md`, `arquero.md` y `slime.md`.
- Afectados: `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `scripts/world_generator.gd`, `scripts/collectables/*`, `resources/*.tres`, `scenes/inventory/inventory.gd`, `docs/items.md`, `docs/enemies.md`. Sin commit.

## 2026-11-03 Â· `buffy` Â· Seis arreglos de la primera prueba (T-0018/T-0019)

- MenÃº: `MountainBase`, `ColorRect` hijo de `mountains` con el color base de `mountain2.png` (`#2D5052`), para tapar el cielo por debajo de la cordillera.
- Fuera el negro de transiciÃ³n: borrados el `CanvasLayer` `Fade` del menÃº y el `ColorRect` de `FallIntro`; Jugar hace `change_scene_to_file` directo.
- CaÃ­da: 2800 â†’ 2200 px de altura y 700 â†’ 300 px/s (~7 s), cÃ¡mara enganchando a los 200 px.
- Enemigos del compaÃ±ero al doble: `scale = Vector2(2, 2)` en la raÃ­z de demon, mutant_toad, werewolf, slime, skeleton y archer.
- Objetos enormes: los iconos eran de 380Ã—380; recortados los 15 usados a 16Ã—16 en `assets/items/iconos/` y los 16 `.tres` reapuntados (tambiÃ©n los 9 de T-0017).
- Spawn: `enemy_safe_gap_tiles` 20 y el chunk 0 ya genera enemigos a partir de `safe_start_tiles + 20` (antes el chunk entero era zona segura).
- Afectados: `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/world/fall_intro.gd`, `scripts/world_generator.gd`, `scenes/enemies/*.tscn`, `resources/*.tres`, `docs/ui.md`, `docs/world.md`, `docs/items.md`, `docs/enemies.md`. Sin commit.

## 2026-11-03 Â· `buffy` Â· Arranque, drops raros y dificultad (T-0020)

- CaÃ­da: el "bugeo" era la cÃ¡mara. `_park_camera()` movÃ­a la `Camera2D`, pero es **hija del jugador**: el parqueo viajaba con Ã©l (el jugador se quedaba clavado cerca del borde superior) y al activar `camera_follow_enabled` a los 200 px la vista saltaba ~270 px, que es lo que se veÃ­a como tirÃ³n. Fuera parqueo, fuera `follow_after_px`: la cÃ¡mara sigue desde el primer frame. Altura 2200 â†’ 520 px (~1,7 s) porque eran 7 s de cielo vacÃ­o; `max_seconds` 6 s evita dejar el control bloqueado.
- Drops: `coin_drop_chance` 45 % (1 moneda), `item_drop_chance` 30 %, `rare_loot_weight` 0.25 y `coins_per_chunk` 2. `loot_table` se construye entera en `_build_loot_table()` (moneda + pool del preset si lo hay).
- Objetos originales: `DROP_ITEMS` eliminado (era lo Ãºnico que los usaba en el loot), fuera del debug de `inventory.gd` y borrados los nodos `drop_pocion_cura`/`drop_pocion_stamina` de `game.tscn` con sus `ext_resource`. Los `.tres` siguen en `resources/`, sin referencias.
- Dificultad: `health_multiplier` 1.35 y `attack_multiplier` 1.25 en `EnemyBase._ready()`, despuÃ©s de que los hijos y las escenas hayan fijado sus stats. Cubre tambiÃ©n proyectiles porque usan `base_attack`.
- Densidad: base `[3, 2, 2, 1, 1, 1, 1, 1]` Ã— `_enemy_count_multiplier()` (chunks 0â€“1 al 50 %, +20 %/chunk, tope Ã—1.8). `floori` por tipo: 3 en los primeros, hasta 16 en los maduros.
- Slime a Ã—1.2 (el resto de los nuevos sigue a Ã—2).
- Bug encontrado por el barrido de rutas: los 11 `.tres` del compaÃ±ero cargaban iconos de `res://assets/icons/`, que no existe en el repo; reapuntados a los recortes de 16Ã—16 de `assets/items/iconos/` (moneda_oro para `codicia`). Ahora `grep assets/icons` en `resources/` da 0.
- Afectados: `scripts/world/fall_intro.gd`, `scripts/world_generator.gd`, `scripts/enemies/enemy_base.gd`, `scenes/enemies/slime.tscn`, `scenes/game.tscn`, `scenes/inventory/inventory.gd`, `resources/*.tres`, `docs/world.md`, `docs/enemies.md`, `docs/items.md`.

## 2026-11-03 Â· `buffy` Â· Voladores fuera, reparto y banda bajo montaÃ±as (T-0021)

- Fantasma y demonio fuera de `enemy_scenes` (escenas y scripts intactos) y anotados en `WorldGenerator.DISABLED_ENEMY_SCENES` para que la vuelta sea copiar dos lÃ­neas. Recuento base a `[4, 2, 1, 2, 2, 2]`: 13 por chunk, 6 en los chunks 0â€“1 y 16 con el tope Ã—1.8.
- Reparto: `_generate_chunk` ya no tira un `randi_range(min_x, max_x)` por enemigo. Monta `spawn_scenes` (un tipo por enemigo), calcula `slot_width = (max_x - min_x + 1) / total` y coloca al enÃ©simo en el centro de su hueco Â±25 %. El RNG se sigue consumiendo una vez por enemigo (aunque estÃ© muerto), asÃ­ que la semilla da las mismas posiciones.
- `MountainBase` en `scenes/game.tscn` (hijo de `mountains`, local y 62â†’400, `mouse_filter` IGNORE) con `#283D43` (`Color(0.157, 0.239, 0.263)`), y el del menÃº cambia de `#2D5052` a ese mismo color: la banda es la misma en menÃº y partida y `day_night.gd` la oscurece con el resto del nodo `mountains`.
- Documentados T-0020 y T-0021 en `docs/` y en el vault, y commit de toda la tanda (dÃ­a/noche, menÃº, caÃ­da, 27 objetos, enemigos y ajustes de balance) sin push.
- Afectados: `scripts/world_generator.gd`, `scenes/main_menu.tscn`, `scenes/game.tscn`, `docs/ui.md`, `docs/world.md`, `docs/enemies.md`, `vault/`.

## 2026-11-05 Â· `buffy` Â· KP5 inmortal, pasivas sin stack y caducidad de pickups (T-0022)

- Pedido por `humano-ruben`: KP5 alterna inmortalidad; pasivas que no se apilen ni se
  vuelvan a soltar una vez equipadas; pickups que parpadean a los 25 s vistos y se van
  a los 30 s, con borrado de seguridad a los 60 s desde el spawn; monedas excluidas.
- Afectados: `scripts/debug_tools.gd`, `scripts/player.gd`,
  `scripts/collectables/player_passive.gd`, `scripts/collectables/passive_items.gd`,
  `scripts/enemies/enemy_base.gd`, `item_pickup.gd`, `docs/items.md`, `docs/player.md`.
- Sin commit y sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente en el editor.

## 2026-11-05 Â· `buffy` Â· Biomas por bloque y mÃ¡s bosque rojo (T-0023)

- Pedido por `humano-ruben`: la transiciÃ³n de biomas pasa de chunks a bloques, con la
  transiciÃ³n tan ancha como un chunk; hay muy poco bosque rojo.
- `world_generator.gd`: bioma por bloque, ventana deslizante de 256 bloques para el
  color, bosques de fondo teÃ±idos al cambiar de bloque, `biome_frequency` 0.12 y
  `biome_transition_tiles` (0 = un chunk). Pesos 0.6/0.4 en los `.tres`.
- `chunk.gd`/`chunk.tscn`: el cÃ©sped ya no es un `TileMapLayer` teÃ±ido entero; se
  dibuja columna a columna con `GrassPaint`.
- Afectados: `scripts/world_generator.gd`, `scripts/world/chunk.gd`,
  `scenes/world/chunk.tscn`, `resources/world/biomes/pradera.tres`,
  `resources/world/biomes/bosque_rojo.tres`, `docs/world.md`.
- Sin commit y sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente en el editor.

## 2026-11-05 Â· `buffy` Â· Fondos tintables y terreno por bioma (T-0024)

- Pedido por `humano-ruben`: el bosque rojo se veÃ­a negro de fondo; regenerar pinos y
  montaÃ±a con solo la vegetaciÃ³n en gris claro y la punta de la montaÃ±a sin pintar; y
  que el bioma module el ruido Perlin (bosque rojo con alturas mÃ¡s marcadas).
- Assets: `pine1_gray.png`/`pine2_gray.png` regenerados y `mountain2_gray.png` nuevo
  (solo bosque teal, transparente en piedra/punta). Script de Python temporal, sin
  ficheros extra en el repo.
- `game.tscn`: pinos grises y `mountains/Sprite2DGreen`; `forest_tint_paths` incluye ese
  overlay. La piedra de la montaÃ±a sigue sin teÃ±irse por bioma.
- `world_generator.gd`/`biome.gd`: modificadores de amplitud y frecuencia por bioma
  (bosque rojo 1.7/1.25) mezclados en la ventana de 256 bloques, con alturas float64
  deterministas en las costuras.
- Afectados: `assets/map/background/`, `scenes/game.tscn`, `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/biomes/bosque_rojo.tres`, `docs/world.md`.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit de la tanda al cerrar.

## 2026-11-05 Â· `buffy` Â· Gris medio y verde original en la pradera (T-0025)

- `humano-ruben`: el gris claro de T-0024 fue un error; bajarlo y que el bosque
  normal (pradera) recupere el verde de antes.
- Assets regenerados con gris `100 + 0.35 Ã— max(R,G,B)` (~113â€“129).
- Nuevo `Biome.forest_color` (solo fondos): pradera `(0.233,0.388,0.388)` = verde
  original `(27,45,45)` sobre el gris 116; bosque rojo `(1,0.32,0.28)`.
- `_biome_tint_at_tile()` usa `forest_color`; el cÃ©sped sigue con `grass_color`.
- Afectados: `assets/map/background/*_gray.png`, `scripts/world/biome.gd`,
  `scripts/world_generator.gd`, `resources/world/biomes/*.tres`, `docs/world.md`.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit al cerrar.

## 2026-11-05 Â· `buffy` Â· Un tono por capa de fondo (T-0026)

- `humano-ruben`: los tres fondos salÃ­an del mismo color con T-0025; antes cada
  capa era mÃ¡s oscura que la siguiente. Que se diferencien en todos los colores.
- Gris calibrado por capa: pino cercano 92, pino lejano 116, montaÃ±a 172/211.
  Con `forest_color` de pradera devuelven los tonos originales de cada capa.
- Bosque rojo: mismos escalones, `(92,29,26)` < `(116,37,32)` < `(172,55,48)` <
  `(211,68,59)`.
- Sin cambios de cÃ³digo: solo assets y `docs/world.md`.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit al cerrar.

## 2026-11-05 Â· `buffy` Â· Nieve separada, bioma de nieve y ambiente (T-0027)

- `humano-ruben`: la punta de nieve salÃ­a teÃ±ida; separarla y ponerla encima,
  aÃ±adir bioma de nieve, suavizar el relieve rojo, aplanar un poco la pradera y
  meter hojas rojas / copos de nieve.
- Causa: `mountain2_gray.png` se regenerÃ³ con toda la montaÃ±a; el overlay estÃ¡
  en `forest_tint_paths` y teÃ±Ã­a piedra y nieve. Ahora solo el bosque.
- `mountain2_snow.png` + `Sprite2DSnow` encima; `Biome.rock_color` +
  `rock_tint_paths` para la piedra (gris solo en nieve).
- `nieve.tres`: cÃ©sped (0.93,0.96,1), bosque (0.82,0.88,0.96), 2 esqueletos +
  2 arqueros + 1 lobo, peso 0.2. Pesos 0.55/0.3/0.2.
- Terreno: rojo 1.35/1.1; pradera 0.95.
- `biome_particles.gd`: hojas (28) y copos (220) con texturas generadas en cÃ³digo.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit al cerrar.

## 2026-11-05 Â· `buffy` Â· FX de combate y feedback de HUD (T-0028)

- `humano-ruben`: aÃ±adir muchas mejoras de partÃ­culas y UX.
- `scripts/fx.gd` + nodo `fx` (grupo `fx`): chispas de golpe, estallido de
  muerte, polvo al saltar/aterrizar/correr, chispas de moneda/objeto/curaciÃ³n,
  nÃºmeros flotantes, sacudida de cÃ¡mara y flash rojo.
- HUD: pop del contador de monedas y latido de la barra bajo el 30 % de vida.
- Biome particles: fundido de 0,4 s al entrar/salir y viento lateral.
- Enganches en player, enemy_base, coin, item_pickup y biome_particles.
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-05 Â· `buffy` Â· Polvo a los pies, sangre y moco (T-0029)

- `humano-ruben`: el polvo de correr/saltar salÃ­a del ombligo, el moco solo del
  centro y la muerte de los enemigos se quedaba corta.
- `scripts/player.gd`: `_feet_offset()` toma la mitad inferior de
  `CollisionShape2D` (16Ã—54 px) y las tres llamadas de polvo emiten a ras de
  suelo; `dust()` baja a gravedad 240 y radio 4.
- `scripts/collectables/moco_emitter.gd`: emisiÃ³n en caja de 14Ã—48 px que cubre
  la hitbox, en vez de esfera de radio 8 en el centro.
- `scripts/fx.gd`: `_burst()` acepta gravedad, radio, spread y alineaciÃ³n a la
  velocidad; `enemy_death()` lanza 4 capas de sangre (32+26+14+8 partÃ­culas,
  gota 2Ã—5 con estela) y `shake(1.4, 0.12)`.
- F5 pendiente; commit al cerrar.

## 2026-11-05 Â· `buffy` Â· Polvo del bioma, parry y fÃ­sica de pickups (T-0030)

- `humano-ruben`: el polvo no reflejaba el color del cÃ©sped, faltaban efectos al
  parrear y las monedas/objetos no tenÃ­an fÃ­sica visible.
- `scripts/fx.gd`: `dust()` consulta `WorldGenerator.biome_at_world_x()` y usa
  `grass_color.lightened(0.35)`; nuevo `parry()` con chispas blancas/doradas,
  `Â¡PARRY!`, `shake(1.2, 0.1)` y `damage_flash()` con color/alfa opcionales.
- `scripts/player.gd`: `parry_window` 0,18 s al levantar la guardia; el golpe
  frontal dentro de la ventana se para con `fx.parry()` y consume la ventana.
- `scripts/collectables/coin.gd`: gravedad 900, raycast al suelo con reintentos,
  rebote 0,4 y vaivÃ©n de 1 px. `world_generator`: `coin_spawn_height` 40 px.
- `item_pickup.gd`: `drop_hop` 150 px/s al aparecer.
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-05 Â· `buffy` Â· Parry retocado y estadÃ­sticas (T-0031)

- `humano-ruben`: el parry iba raro, habÃ­a que cambiar su stamina y faltaban
  stats (velocidad de ataque, daÃ±o/prob. crÃ­tico, velocidad, suerte) que se
  vieran siempre a la izquierda sin molestar.
- `scripts/player.gd`: `parry_window` 0,2 s + `parry_cooldown` 0,3 s (no se
  rearma spameando), `parry_stamina_refund` 30 al acertar, `fx.parry_ready()`
  al abrir la ventana y `_apply_damage()` devuelve si el golpe llegÃ³ para no
  empujar nunca con la guardia puesta.
- Stats nuevas: `attack_speed` (escala la animaciÃ³n de ataque), `crit_chance`
  0,05, `crit_damage` 2.0 y `luck` 0, con mÃ©todos `add_*` y crÃ­tico base en
  `_deal_damage()`. `enemy_base.take_damage()` reenvÃ­a `critical` a
  `fx.enemy_hit()` y `_luck_drop_bonus()` mete la suerte en el loot.
- Panel `UILayer/StatsPanel`: `GridContainer` de 2 columnas en (5, 26), fuente 9,
  alpha 0,6, refresco por `_stats_dirty` (no cada frame).
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-05 Â· `buffy` Â· DaÃ±o en el panel y ambiente horizontal (T-0032)

- `humano-ruben`: faltaba la stat de daÃ±o, el panel chocaba con las monedas y
  las partÃ­culas de ambiente dejaban huecos al derivar de lado.
- `scripts/player.gd`: fila `DaÃ±o` (`hitbox_damage`) y panel movido a (5, 82),
  por debajo de la lÃ­nea de monedas (yâ‰ˆ63); 6 filas y refresco por `_stats_dirty`.
- `scripts/world/biome_particles.gd`: `emission_rect_extents.x` de `view.x Ã— 0,6`
  a `Ã— 1,2` y cantidad al doble (56 hojas, 440 copos) para mantener densidad.
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-06 Â· `buffy` Â· BÃ³veda de ideas

- Creado `vault/ideas.md` a partir de las notas de `humano-ruben`: personaje,
  enemigos, DOT/estados, objetos, tienda y biomas, con estado
  (`hecho`/`parcial`/`idea`/`por definir`) y las dudas abiertas agrupadas.
- 17 pasivas ya estÃ¡n implementadas y en `EnemyBase.PRESET_POOLS`; los biomas
  existentes son pradera, bosque rojo y nieve; no hay tienda ni sistema de efectos.
- Detectado que `DISABLED_ENEMY_SCENES` no se usa y los biomas aÃºn listan fantasma
  y demonio: conviene comprobarlo en F5.
- Registrado en el Ã­ndice de `vault/README.md` y enlazado desde `roadmap.md`.
  Sin cambios de cÃ³digo ni tickets nuevos.

## 2026-11-06 Â· `buffy` Â· Entrega 2

- Creado `vault/entrega-2.md` (catalÃ¡n, para Google Docs): resumen, cambios
  desde la entrega 1, explicaciÃ³n del cambio de herramientas (OpenCode â†’
  FreeBuff y Gemini Chat â†’ OpenCode) y funcionamiento del vault entre IAs.
- Recalca los tres prÃ³ximos objetivos (texturas de objetos, estructuras y
  boses, objetos y mecÃ¡nicas) y justifica la reestructuraciÃ³n como causa del
  menor progreso visible. Sin cambios de cÃ³digo.

## 2026-11-06 Â· `buffy` Â· Sacudida de cÃ¡mara y encuadre (T-0033)

- `humano-ruben`: tras el primer golpe la cÃ¡mara se centraba en el jugador y no
  volvÃ­a al encuadre del arranque.
- Causa: `scripts/fx.gd` escribÃ­a `camera.offset` para la sacudida y al acabar
  lo ponÃ­a a `Vector2.ZERO`, borrando el `(60, -70)` de `scenes/player.tscn`.
- `scripts/fx.gd`: `_camera_base_offset` se captura al iniciar la sacudida (solo
  si no hay otra activa) y se restaura al expirar; el temblor va sumado encima.
- `docs/fx.md` actualizado. F5 pendiente (regla de `AGENTS.md`).

## 2026-11-06 Â· `buffy` Â· Inventario al doble (T-0034)

- `humano-ruben`: la GUI del inventario quedÃ³ pequeÃ±a tras el gran cambio de
  tamaÃ±os; pide el doble solo en el inventario.
- Causa: el viewport pasÃ³ a 768Ã—432 (T-0010) y la pantalla conservÃ³ las medidas
  de 384Ã—216.
- `scenes/inventory/inventory_screen.tscn`: todo duplicado (ventana 744Ã—380,
  mÃ¡rgenes, radios, bordes, separaciones, paneles, retrato, preview y fuentes).
- `scenes/inventory/inventory_screen.gd`: huecos 40Ã—40, coleccionables 32Ã—32 y
  `expand_icon`; el HUD sigue a 18Ã—18.
- `docs/ui.md` actualizado. F5 pendiente.

## 2026-11-09 Â· `opencode-jorge` Â· Lobo menos agresivo (T-0035)
- PeticiÃ³n de Ruben: el lobo corre demasiado y no deja pelear.
- `scripts/enemies/werewolf.gd`: `charge_speed` 150, `charge_distance_scale` 0.4, `attack_recovery` 1.5 y recuperaciÃ³n quieto (sin persecuciÃ³n).
- F5 pendiente; ticket en `revision`.

## 2026-11-09 Â· `opencode-jorge` Â· Slime y lobo en el bosque (T-0036)
- PeticiÃ³n de Ruben: slime en el bosque y menos lobos.
- `resources/world/biomes/bosque_rojo.tres`: `enemy_counts` [1 lobo, 1 sapo, 1 demonio, 2 slimes].
- F5 pendiente; ticket en `revision`.

## 2026-11-09 Â· `opencode-jorge` Â· Loot por enemigo (T-0037)
- Ruben rechaza los presets compartidos: quiere tabla y probabilidad por objeto en cada enemigo.
- `LootEntry` nuevo y `item_drops` en `EnemyBase`; fuera `PRESET_POOLS`, `loot_preset`, `item_drop_chance` y `rare_loot_weight`.
- Cuatro escenas migradas (ogro, lobo, rana y slime). F5 pendiente; ticket en `revision`.

## 2026-11-09 Â· `opencode-jorge` Â· CorrecciÃ³n del loot (T-0037)
- Ruben aclara: una sola tirada para todos los coleccionables (probabilidades sumadas) y monedas siempre aparte, pudiendo soltar varias.
- `_drop_loot` separado en `_drop_coins` y `_drop_item`; elecciÃ³n del objeto ponderada por `drop_chance`.
- Docs y ticket actualizados. F5 pendiente.

## 2026-11-10 Â· `opencode-jorge` Â· Fuera skills (T-0038)
- Ruben quita las skills: el inventario queda con 3 consumibles y teclas 1/2/3.
- `Skills.gd` borrado; `SKILL_SLOTS`, `SkillsFlow` y `use_slot_4/5` fuera.
- `docs/items.md` pasa a catÃ¡logo completo (9 consumibles + 35 pasivas), todas en `falta textura`.
- F5 pendiente; ticket en `revision`.

## 2026-11-12 Â· `opencode-jorge` Â· Tope de pendiente en el terreno (T-0049)
- Reclamo T-0049 (peticiÃ³n de Ruben): paredes de 4 tiles en la seed 775344231 (tile 28227).
- `max_step_tiles` (1) en `world_generator.gd`: cada columna a Â±1 fila de la anterior, cadena cacheada por chunk; la columna compartida se hereda del vecino para no romper la costura. Fuera `_terrain_at_tile()`.
- Verificado con script headless desechable (seed 775344231, 28k tiles): escalÃ³n mÃ¡ximo 1 y costuras exactas; `game.tscn` arranca sin errores.
- `docs/world.md` y `changelog.md` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-12 Â· `buffy` Â· Terreno redondeado en vez de escalera (T-0050)
- PeticiÃ³n de `humano-ruben`: el tope de Â±1 de T-0049 convirtiÃ³ las laderas en una escalera
  antinatural (diagonales de un escalÃ³n por columna, tramos de hasta 51 columnas). Que se
  vean redondeadas, con paredes de 2 tiles y de 3 muy de vez en cuando.
- `scripts/world_generator.gd`: fuera `clampi(h, prev Â± max_step_tiles)`.
  `_build_shaped_heights()` + `_shaped_step()` sostienen la losa con
  `tread_hold_chance` (0.65, mitad a 2 tiles de desvÃ­o) y pegan pared de
  `max_step_tiles` (ahora 2), con 3 cuando sale `rare_step_chance` (0.06). La tirada es
  `_terrain_roll()` (hash de seed + columna), sin RNG que arrastrar entre chunks.
  `_clamped_*` renombrados a `_shaped_*`.
- Verificado con script headless desechable (seeds 12345 y 775344231, 28 200 tiles):
  mÃ¡ximo 3, 74â€“76 % de columnas planas, 14 % de 1 tile, 10â€“11 % de 2 y 0.2 % de 3;
  costuras exactas en 110 chunks y spawn plano. `game.tscn` arranca sin errores.
- `docs/world.md`, `changelog.md` y `estado.md` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-12 Â· `buffy` Â· Elevaciones exageradas del bosque rojo (T-0051)
- `humano-ruben`: prefiere la generaciÃ³n anterior a la de T-0050 (demasiados suelos de 2
  tiles) y siguen saliendo elevaciones exageradas en algunos sitios.
- `scripts/world_generator.gd` revertido a T-0049 (`git checkout`): vuelve el tope de Â±1,
  sin `_shaped_step()`. T-0050 queda `cerrado` como revertido.
- Causa de las zonas raras: no era el ruido ni las costuras, sino los modificadores del
  bosque rojo (`terrain_amplitude_multiplier` 1.35 y `terrain_frequency_multiplier` 1.1).
  Con el tope de Â±1 el suelo no puede seguir al ruido y fabrica rampas de un escalÃ³n por
  columna: 30â€“40 tiles de montaÃ±a y hasta 123 escalones seguidos.
- Medido en el generador real (40 000 tiles, seeds 12345/775344231/777): la frecuencia era
  la de las rampas (123 â†’ 21â€“22 al bajarla) y la amplitud la de las montaÃ±as (relieve
  37â€“39 â†’ 28â€“29). Con el bosque rojo en 0.95/1.0: peor ventana de 300 tiles 26 y tramos
  de 11â€“14 escalones.
- `bosque_rojo.tres` a 0.95/1.0 y `docs/world.md` actualizado con la regla "un bioma solo
  aplana". F5 pendiente; ticket en `revision`.

## 2026-11-12 Â· `buffy` Â· Barrera izquierda como montaÃ±a y debug de velocidad (T-0052, T-0053)
- `humano-ruben`: a la izquierda se veÃ­a el vacÃ­o; querÃ­a una gran montaÃ±a, escalable un
  poco al principio pero imposible de subir, para camuflar la barrera. Y el numpad
  cambia: KP7 mitad, KP9 doble sin lÃ­mite y KP8 reset.
- `scripts/world/chunk.gd`: `paint()` acepta `left_heights` y pinta columnas en X local
  negativo (el `TileMapLayer` no tiene lÃ­mites), con el tono de hierba de la columna 0.
- `scripts/world_generator.gd`: grupo `Left wall` (`left_wall_tiles` 56,
  `left_wall_climb_tiles` 2, `left_wall_step_rows` 4), `_left_wall_heights()` cacheado y
  solo en chunk 0. Empieza en `base_height`, sube 1 tile por columna dos veces y despuÃ©s
  4 filas por columna hasta `min_height`, donde se queda. Fuera de la cadena con tope.
- `_keep_player_inside_world()` pasa de parar en `TILE_SIZE` a parar en la Ãºltima columna
  pintada (`-880 px`).
- Medido con script headless sobre `game.tscn`: 56 columnas de -56 a -1, la de -1 en fila
  49, subida mÃ¡xima 4 filas, 10 tramos de 4, cresta plana en fila 5 desde -37; jugador
  forzado a -5000 px acaba en -880. 4 filas = 64 px > 41 px de salto.
- `scripts/debug_tools.gd`: fuera `SPEEDS`; `_speed` float con KP9 Ã—2, KP7 Ã—0.5 y KP8 a
  1.0, suelo `MIN_SPEED` 0.001; `game_speed` pasa a `start_speed`. Verificado enviando
  teclas al nodo: x1 â†’ x2 â†’ x4 â†’ x2 â†’ x1 â†’ x0.5 â†’ x0.25 y etiqueta `x0.25`.
- `docs/world.md`, `docs/player.md`, `README.md`, `changelog.md` y `estado.md`
  actualizados. F5 pendiente; ambos tickets en `revision`.

## 2026-11-12 Â· `buffy` Â· Viaje rÃ¡pido sobre el terreno (T-0054)
- `humano-ruben`: KP4/KP6 no deben subir un nÃºmero fijo de tiles respecto a la posiciÃ³n
  actual, sino dejar al jugador un poco por encima del terreno del destino.
- `scripts/world_generator.gd`: `ground_y_at(world_x)` devuelve la fila superior de la
  columna en pÃ­xeles; `_height_at()` ya resuelve los tiles negativos con
  `_left_wall_height_at()` (la cresta de T-0052 en la fila 5).
- `scripts/debug_tools.gd`: `teleport_lift_tiles` (10) fuera, entra
  `teleport_above_ground_tiles` (4); `_teleport()` calcula X destino, pone Y en
  suelo âˆ’ 4 tiles y llama a `refresh_chunks()` para que el terreno exista en el frame.
- Medido en `game.tscn` enviando teclas: hueco de 4.00 tiles tras KP6 desde el spawn
  (tile 50 â†’ 114.5) y otra vez (â†’ 178.5), 3.96 al volver con KP4 y 3.92 al caer sobre la
  cresta de la barrera izquierda (tile âˆ’52, fila 5).
- `README.md`, `docs/player.md`, `changelog.md` y `estado.md` actualizados. F5 pendiente;
  ticket en `revision`.

## 2026-11-12 Â· `buffy` Â· Monedas arriba a la izquierda con icono (T-0055)
- `humano-ruben`: el contador de monedas sale debajo de las stats; lo quiere arriba a la
  izquierda con un icono de moneda.
- Causa: `UILayer/coins` tenÃ­a `anchors_preset = 15` (pantalla completa) con el texto
  centrado. En 768Ã—432 caÃ­a en (10, 63), pero en un viewport mayor (pantalla completa
  adaptativa) baja con la pantalla y acaba sobre el panel de stats.
- `scenes/game.tscn`: `coins` a rect fijo (26, 26)â€“(120, 42), alineado a la izquierda y
  12 px; nodo nuevo `coin_icon` (TextureRect 16Ã—16 en (6, 26)) con un `AtlasTexture` del
  primer frame de `assets/coins/MonedaD.png`. Se mantiene la ruta `UILayer/coins` porque
  `player.gd::_ensure_coins_ui()` la busca; el fallback de cÃ³digo usa el mismo rect.
- Medido con script headless en 768Ã—432 y 960Ã—540: label en (26, 26) 94Ã—17 e icono en
  (6, 26) 16Ã—16 en ambos; consumibles (4, 4)â€“(108, 22) y stats (5, 82) intactos; con
  `add_coin(7)` el texto pasa a "7" y el pop sigue.
- `docs/ui.md`, `changelog.md` y `estado.md` actualizados. F5 pendiente; ticket en
  `revision`.

## 2026-11-12 Â· `buffy` Â· AuditorÃ­a de documentaciÃ³n (T-0056)
- `humano-ruben` pide actualizar toda la documentaciÃ³n y crear en el vault lo que falte
  (enemigos, drops, biomas, itemsâ€¦).
- AuditorÃ­a contra cÃ³digo: sets de enemigos por bioma (`pradera` 3 orcos + 3 slimes + 1
  sapo, `bosque_rojo` 1 lobo + 1 sapo, `nieve` 2 esqueletos + 2 arqueros + 1 lobo), 44
  `.tres` con icono, estadÃ­sticas de enemigos en `_init()` con Ã—1.35/Ã—1.25, `item_drops`
  reales (orco 42 %, lobo/rana/slime 32 %) y caÃ­da de 260 px a 620 px/s.
- Reescritos `docs/enemies.md` y `docs/items.md`; nuevos `docs/biomes.md`,
  `docs/loot.md` y `docs/passives.md`; corregidos `docs/world.md` (ventana, biomas,
  caÃ­da), `docs/ui.md` (`DebugHint`), `docs/player.md` (stats 5, 82),
  `docs/historial.md` y `README.md` (controles 1-3, New Game, sin KP3).
- Vault: nuevo `vault/documentacion.md` (mapa + auditorÃ­a + huecos: audio, muerte,
  skills, progresiÃ³n, jefe), Ã­ndice en `vault/README.md`, totales y correcciones en
  `vault/pasivas/` (Maza +2, Colmillo +3, Piedra de oro +10 %).
- Verificado con grep/sed sobre escenas, `.tres` y scripts; sin tocar cÃ³digo, no hace
  falta F5. Ticket en `revision`.

## 2026-11-12 Â· `buffy` Â· Decoraciones de bioma (T-0057) y ramas por feature
- `humano-ruben` pide que cada feature vaya en su propia rama y se integre con PR, y que
  el mundo spawee `assets/map/decor` (2 arbustos, 2 Ã¡rboles, 2 rocas) detrÃ¡s del suelo, sin
  colisiÃ³n, escala ni parallax, con el verde tintado por bioma.
- Vault: `README.md` estrena el flujo de ramas/PR (`feat/<slug>`, merge squash, `main` solo
  recibe merges); `AGENTS.md` recoge la regla y `estado.md` apunta a `feat/decor`.
- CÃ³digo: `Biome.decor_colors` (array) y grupo **Decor** en `WorldGenerator`; cada sprite
  es el primer hijo del chunk (detrÃ¡s de `Solid`/`GrassPaint`) y las copias grises
  `bush_1_gray.png`, `bush_2_gray.png` y `tree_gray.png` se generan dejando los troncos.
- Tres tintes por bioma: verdes en pradera, rojos/naranjas en bosque rojo y verdes frÃ­os en
  nieve; rocas y Ã¡rbol muerto no se tintan.
- Verificado con script headless; queda el F5 visual y el push/PR de la rama.

## 2026-11-12 Â· `buffy` Â· Decoraciones, segunda pasada (T-0057)

- Feedback de Ruben: todo mÃ¡s grande y muchos mÃ¡s Ã¡rboles, con densidad y tipos por bioma; pradera con bastantes Ã¡rboles y bosque rojo con muchÃ­simos mÃ¡s (rojos, con naranjas y amarillos en menor cantidad); rocas al fondo; arbustos que se mueven y sueltan partÃ­culas al pasar.
- `Biome` gana `decor_per_chunk`, `decor_kinds`, `decor_weights` y `decor_color_weights`; el generador conserva sus arrays como fallback y resuelve los nombres (`decor_lookup`).
- Escalas 1.7â€“1.9 con `offset` en la base; rocas `z_index` âˆ’1 y orden de dibujo rocas â†’ Ã¡rboles â†’ arbustos; nuevo `scripts/world/decor_prop.gd` para el bamboleo y las hojas, con `fx.leaves()` reutilizando el nodo `fx`.
- Comprobado headless: pradera 32 decorados (13 Ã¡rboles), bosque rojo 52 (35 Ã¡rboles; tintes 29/15/5), nieve 24, bases alineadas, 0 colisiones, rocas al fondo y bamboleo con 1 estallido de hojas. F5 pendiente.
- `feat/decor` publicada y [PR #1](https://github.com/TontonR/GodotSintesi/pull/1) abierta contra `main`, sin mergear. La PR incluye ademÃ¡s los 3 commits locales de `main` que aÃºn no estÃ¡n en `origin`.
- Afectados: `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/decor_prop.gd`, `scripts/fx.gd`, `resources/world/biomes/*.tres`, `docs/decor.md`, `docs/biomes.md`, `docs/world.md`, `docs/fx.md`, ticket T-0057, `changelog.md`, `estado.md`, `roadmap.md`.

## 2026-11-12 Â· `buffy` Â· Decoraciones, tercera pasada (T-0057)

- Ruben: los troncos salÃ­an teÃ±idos aunque el gris estaba bien; zonas vacÃ­as y zonas sobrecargadas; nieve con poca generaciÃ³n y 40% de Ã¡rboles muertos; subir todo a git.
- Causa: `tree_gray.png` conserva el tronco marrÃ³n, pero el `modulate` del bioma multiplica el sprite entero. Ahora `_decor_texture()` genera y cachea una copia por textura + color y `_tint_foliage()` solo recolorea los pÃ­xeles verdes (hojas), dejando tronco, contorno y marrones intactos; `modulate` queda en blanco y `DecorProp.tint_color` da color a las hojas.
- Reparto: slots estratificados (un prop por slot, Â±30% de jitter) y `decor_min_gap_tiles` = 3; densidades 20/26/10 por chunk y `Biome.decor_dead_tree_ratio` (nieve 0.4) convierte el 40% exacto de los Ã¡rboles del chunk en muertos.
- Verificado headless: tronco idÃ©ntico al original con tinte rojo, hojas teÃ±idas, rocas y Ã¡rbol muerto sin tocar, cachÃ© reutilizada; separaciones mÃ­nimas 9/5/21 tiles; 20/26/10 props por chunk; nieve 15 vivos / 10 muertos = 0.40. F5 pendiente.
- Afectados: `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/decor_prop.gd`, `resources/world/biomes/{pradera,bosque_rojo,nieve}.tres`, `docs/decor.md`, ticket T-0057, `changelog.md`, `estado.md`.

## 2026-11-13 Â· `buffy` Â· Nieve casi blanca y atravesar enemigos (T-0057 cuarta pasada, T-0058)

- Ruben: la vegetaciÃ³n de la nieve sale gris y, andando, se empuja a los enemigos; prefiere atravesarlos pero que atravesarlos duela.
- `resources/world/biomes/nieve.tres`: `decor_colors` pasa a `(0.98, 1, 1)`, `(0.88, 0.94, 0.99)` y `(0.78, 0.86, 0.94)` con los mismos pesos 3/3/2.
- Empuje: `slime.tscn`, `skeleton.tscn` y `archer.tscn` tenÃ­an `collision_mask = 3` (mundo + jugador) y su `move_and_slide()` los sacaba del solape; bajan a 1 como el resto.
- DaÃ±o de contacto en `scripts/player.gd`: `body_contact_damage` (5) y `body_contact_cooldown` (1 s por enemigo) con `intersect_shape` sobre la mÃ¡scara 4 y `take_damage_from()` sin knockback (guardia/parry frontal y KP5 siguen valiendo).
- Afectados: `resources/world/biomes/nieve.tres`, `scripts/player.gd`, `scenes/enemies/{slime,skeleton,archer}.tscn`, `docs/decor.md`, `docs/biomes.md`, `docs/player.md`, `docs/enemies.md`, tickets T-0057 y T-0058, `changelog.md`, `estado.md`, `roadmap.md`.
- Verificado solo por inspecciÃ³n: F5 pendiente de empuje, daÃ±o de contacto y tono de la nieve.

## 2026-11-13 Â· `buffy` Â· Muerte definitiva y tres slots de guardado (T-0059, T-0060)

- Ruben: al morir no se debe revivir; pantalla de muerte y la run se acaba. Guardado en hasta 3 runs (slots) sobrescribibles. Recuerda fusionar las PR a `main`.
- `scripts/save_game.gd` pasa de un `user://savegame.cfg` a `user://run_slot_N.cfg` con `current_slot`, `slot_summary()`, `start_new_run()` y `delete_slot()`; se van `SAVE_PATH` y `has_save()`.
- MenÃº principal: fuera New Game/Continue; `Menu/Layout/Slots/Slot1â€¦3` con `Play` (continÃºa o empieza run nueva con semilla) y `Erase`.
- Muerte: `Player.died` + `is_dead()`, `Game._on_player_died()` borra el slot, espera 1.4 s y abre `DeathScreen` (CanvasLayer 30) sin revivir; `save_run()` rechaza salud 0 y la pausa no guarda una run muerta.
- Afectados: `scripts/save_game.gd`, `scripts/game.gd`, `scripts/player.gd`, `scripts/ui/{main_menu,pause_menu,death_screen}.gd`, `scenes/main_menu.tscn`, `scenes/game.tscn`, `scenes/ui/death_screen.tscn`, `docs/ui.md`, `docs/player.md`, tickets T-0059/T-0060, `changelog.md`, `estado.md`, `roadmap.md`.
- `gh` no estÃ¡ instalado en esta mÃ¡quina: la PR #1 sigue abierta y hay que mergearla desde GitHub (o instalando `gh`) antes de que `main` reciba estas features.

## 2026-11-13 Â· `buffy` Â· MenÃº New Game / Continue / Load (T-0060, revisiÃ³n de UX)

- Ruben: querÃ­a el menÃº anterior (New Game + Continue) y un botÃ³n Load que despliegue las partidas guardadas; Continue carga la Ãºltima run cerrada.
- `scenes/main_menu.tscn`: vuelven `NewGame` y `Continue`, se aÃ±ade `Load` y las tres filas de slot (Play/Erase) se mueven a `Menu/LoadDialog` con `Back` y Esc.
- `scripts/save_game.gd`: `latest_slot()` (mtime mÃ¡s reciente = Ãºltima run cerrada) y `slot_for_new_run()` (primer slot libre o el mÃ¡s antiguo si los tres estÃ¡n llenos).
- `scripts/ui/main_menu.gd`: New Game â†’ semilla â†’ slot automÃ¡tico; Continue â†’ `latest_slot()`; Load â†’ diÃ¡logo con los tres slots, filas vacÃ­as deshabilitadas y Erase.
- Afectados: `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/save_game.gd`, `docs/ui.md`, ticket T-0060, `changelog.md`, `estado.md`.
- Verificado por inspecciÃ³n; F5 pendiente (crear 3 runs, borrar una, Continue y cargar cada slot).

## 2026-11-13 Â· `buffy` Â· Arreglo de la pantalla de muerte (T-0059)

- Ruben: la pantalla de muerte no aparecÃ­a. Causa: el editor abierto reserializÃ³ `scenes/game.tscn` y se llevÃ³ el nodo `DeathScreen` y su `ext_resource`; `Game._on_player_died()` no lo encontraba y no mostraba nada.
- Arreglo: nodo devuelto a `game.tscn` y `Game._ensure_death_screen()` instancia `res://scenes/ui/death_screen.tscn` si la escena no lo trae (protege ante futuras reserializaciones del editor).
- Verificado con script headless desechable (`res://_death_check.gd`, borrado despuÃ©s): `dead=true`, `health=0`, `screen_visible=true`, `paused=true`, Godot exit 0 sin errores de script.
- Afectados: `scenes/game.tscn`, `scripts/game.gd`, `docs/ui.md`, ticket T-0059, `changelog.md`, `estado.md`.

## 2026-11-13 Â· `buffy` Â· Aviso de sobrescritura + contador de metros (T-0060, T-0061)

- Ruben: querÃ­a que al guardar sin hueco el juego avisara y pidiera quÃ© run sobrescribir; contador de metros (bloques) arriba al centro; y que Load muestre monedas y metros en vez de la semilla.
- `SaveGame`: `has_free_slot()` y `first_free_slot()` (devuelve -1 si no queda hueco) sustituyen a `slot_for_new_run()`; `[run] meters` nuevo, con `SPAWN_X` (808) como fallback para slots viejos; `slot_summary()` expone `meters`.
- `WorldGenerator.meters_at(world_x)` (spawn 50Ã—16+8); `UILayer/Meters` en `game.tscn`; `Game._process()` refresca el label solo al cambiar de bloque.
- MenÃº: Start arranca en el primer hueco o abre `LoadDialog` en modo sobrescritura (todo habilitado, `Erase` oculto, `Back` vuelve al diÃ¡logo de semilla); las filas muestran `M m Â· C coins`.
- Verificado: `--check-only` en world_generator/save_game/game/main_menu (exit 0) y script headless desechable (borrado) â†’ `start_m=0 label=0 m`, tras +160 px `10 m`. F5 pendiente.
- Afectados: `scripts/world_generator.gd`, `scripts/save_game.gd`, `scripts/game.gd`, `scripts/ui/main_menu.gd`, `scenes/game.tscn`, `docs/ui.md`, tickets T-0060/T-0061, `changelog.md`, `estado.md`, `roadmap.md`.

## 2026-11-13 Â· `buffy` Â· El parry perfecto aturde al lobo (T-0062)

- Ruben: el lobo quedÃ³ OP con el daÃ±o de contacto (atraviesa, golpea por la espalda donde no llega el escudo, corre mÃ¡s que tÃº y el contacto te desintegra). Pide aturdimiento de 0.5â€“1 s al pararle perfecto y que sea un poco mÃ¡s lento.
- Causa real: el lobo ya pega con su propio hitbox y el jugador le sumaba encima los 5 px de contacto genÃ©rico (13 + 5 cada 0.5 s).
- `EnemyBase.uses_custom_contact_damage()` (false por defecto); el lobo lo pone a `true` y `player._update_body_contact()` lo salta.
- `Player.parried(attacker)`: se emite al consumir la ventana de parry; el lobo se conecta una sola vez (grupo `player`, `_parry_connected`) y, si el atacante es Ã©l, entra en `STUN` con `parry_stun_time` 0.8 s, destello azulado y sin daÃ±o de contacto; en el aire espera a aterrizar y luego vuelve al aviso.
- `charge_speed` 150 â†’ 140: sigue superando el paseo (130) y queda por debajo del sprint (221).
- Verificado headless (script desechable borrado): parry de otro atacante no aturde, parry propio â†’ `state=5` (STUN) 0.8 s, luego vuelve a embestir, `_contact_cooldowns` del jugador vacÃ­o con el lobo encima y `charge_speed=140`. `--check-only` en player/enemy_base/werewolf con exit 0. F5 pendiente.

## 2026-11-13 Â· `buffy` Â· Cimas blancas en la montaÃ±a nevada (T-0063)

- Ruben: en el bioma nevado la cima del fondo se oscurece en vez de verse blanca.
- Causa: `mountains/Sprite2DSnow` (`mountain2_snow.png`, la capa de nieve) no estaba en ninguna lista de tinte y su textura es blanco sucio (â‰ˆ 184, 172, 171) sobre un risco teÃ±ido de `rock_color` 0.75; el modulate solo multiplica, asÃ­ que ningÃºn tinte normal la aclaraba.
- Nuevo canal `Biome.snow_color` (blanco por defecto) + `snow_tint_paths` (`../mountains/Sprite2DSnow`) aplicado en `_update_biome_tint()` junto a forest/rock/base.
- `nieve.tres`: `snow_color = (1.55, 1.6, 1.65)` (por encima de 1, empuja la capa a blanco puro) y `rock_color` 0.75 â†’ `(0.92, 0.94, 0.98)`.
- Antes de tocar cÃ³digo compuse las tres capas en PIL para comparar variantes (actual / roca clara + nieve al 150 % / todo a blanco); se eligiÃ³ la intermedia.
- Verificado headless (script desechable borrado): `snow_color=(1.55, 1.6, 1.65)`, `Sprite2DSnow` dentro de `_snow_tint_nodes` y el canal `"snow"` devolviÃ©ndolo; `--check-only` en world_generator/biome exit 0. F5 pendiente.

## 2026-11-13 Â· `buffy` Â· La capa de nieve no era la cima entera (T-0063, 2.Âª pasada)

- Ruben: `mountain2_snow.png` estaba mal; la cima tiene dos colores y la imagen solo recogÃ­a el brillo (el mÃ¡s pequeÃ±o).
- Paleta real de `mountain2.png`: roca en tres tonos â€” brillo `184, 172, 171` (5.944 px), cara iluminada `161, 148, 147` (20.474 px) y cara de sombra `107, 108, 122` (13.136 px) â€” mÃ¡s dos teales de vegetaciÃ³n (`45, 80, 82`, `40, 61, 67`).
- La nieve antigua solo tenÃ­a el brillo. Regenerada con los tres tonos: blanco puro, `222, 230, 242` y `150, 162, 180`; la vegetaciÃ³n queda fuera (alpha 0). 39.554 px frente a 5.944.
- Con tres tonos, subir el modulate por encima de 1 los aplasta a blanco: `nieve.tres` pasa a `snow_color = (1, 1, 1, 1)` y el valor por defecto de `Biome.snow_color` es `(1, 1, 1, 0)` para que solo el bioma nevado muestre la capa (antes el prado y el bosque rojo tenÃ­an manchas blancas sueltas).
- Comparadas dos variantes compuestas en PIL (dejar la cara de sombra como roca vs. cubrirla); se elige cubrirla: es la lectura de "la cima entera" y la que pedÃ­a Ruben.
- Verificado: asset con los tres tonos en el PNG y en la textura importada, `--check-only` en `world_generator.gd`/`biome.gd`. F5 pendiente.

## 2026-11-13 Â· `buffy` Â· La cima conserva su color fuera de la nieve (T-0063, 3.Âª pasada)

- Ruben: en los biomas no nevados la cima debe parecerse al color original de la imagen, con un mini toque del color de cada bioma.
- La capa de nieve se pintÃ³ blanca, asÃ­ que hay que devolverle el tono del arte con el modulate: `Biome.snow_color` por defecto `(0.72, 0.66, 0.65)` multiplica los tres blancos y deja â‰ˆ `184, 168, 166` donde el arte tenÃ­a `184, 172, 171`.
- `pradera.tres` `(0.715, 0.675, 0.625)` (verde tenue) y `bosque_rojo.tres` `(0.74, 0.65, 0.625)` (cÃ¡lido tenue); `nieve.tres` sigue en `(1, 1, 1)`.
- Medido sobre los tres tonos con PIL: peor delta en prado y bosque rojo 12/255 (4,7 %); en nieve 98/255 (38 %), que es justo el salto a blanco.
- Verificado headless con script desechable (canal `snow` de los tres `.tres`) y `--check-only` en world_generator/biome. F5 pendiente.
- Confirmado con un probe que renderiza de verdad (captura del viewport, no `--headless`): el brillo del blanco con `snow_color = (0.72, 0.66, 0.65)` sale `184, 168, 166` en pantalla. El modulate multiplica en sRGB, asÃ­ que la reconstrucciÃ³n del tono original es exacta en la prÃ¡ctica y no hay que corregir por espacio de color.

## 2026-11-13 Â· `buffy` Â· El lobo se congela y siempre repite embestida (T-0064)

- Ruben: el lobo se queda quieto para siempre tras perseguirte; y al salir del stun deberÃ­a poder correr o saltar.
- Causa: el `match _state` de `_update_behavior()` no tenÃ­a rama `RECOVER`; `_process_recovery()` existÃ­a pero nunca se llamaba, asÃ­ que tras la primera embestida o salto el estado se quedaba congelado y su temporizador (el que devuelve a `WINDUP` o a vagar) no corrÃ­a nunca.
- Arreglo: rama `State.RECOVER` aÃ±adida al `match`.
- Stun: `stun_jump_chance` 0.5 y `_stun_next_attack` (-1 ciclo normal, 1 embestida, 2 salto) que `_launch_attack()` consume una vez; se limpia al volver a vagar. Antes el final del stun siempre reembestÃ­a porque el contador 2 + 1 no cuenta el stun.
- Verificado headless: `RECOVER` a 0 pasa a `WINDUP`, 40 stuns reparten 16 embestidas / 24 saltos, y la intenciÃ³n forzada acaba en `CHARGE`/`JUMP`. `--check-only` sin errores; F5 pendiente.

## 2026-11-13 Â· `buffy` Â· CatÃ¡logo de enemigos e items con estado y skills (T-0065)

- Ruben: faltaba una vista de conjunto de enemigos (drops con probabilidad, stats, mecÃ¡nicas)
  y de objetos, con una casilla de estado y fichas detalladas conectadas entre sÃ­.
- Nuevo `vault/enemies.md` (lista de los 8) + `vault/enemies/<slug>.md` (stats base â†’ finales,
  IA, tabla de drops con enlace al objeto, spawn y checklist de F5). Todos en `por revisar`;
  fantasma y demonio marcados como inalcanzables.
- Nuevo `vault/items.md` (44 objetos) + `vault/items/<slug>.md`, generados desde `resources/*.tres`
  y los `item_drops` de las escenas: 9 consumibles, 35 pasivas, 17 con drop. Todos en
  `por asignar textura` (el icono existe, es provisional). Totales: orco 42 %, lobo/rana/slime 32 %.
- Skills `estado-enemigos` y `estado-items` en `.opencode/skills/` con el vocabulario de estados,
  dÃ³nde mirar, cuÃ¡ndo actualizar y trampas; `.agents/skills/` tiene la entrada para Freebuff.
- Trampa del generador: en `[ext_resource ... uid="uid://..." path="..." id="..."]`, el regex
  `id="..."` casa tambiÃ©n dentro de `uid="..."`; hay que anclar con `\bid=`. Con eso se resolvieron
  los 44 iconos y las 4 tablas de loot (antes salÃ­an `1_tex` y faltaba Wolf Fang).
- Sin cambios de cÃ³digo ni de escenas; verificaciÃ³n de enlaces y conteos, sin F5.

## 2026-11-13 Â· `buffy` Â· Biomas mÃ¡s cortos, estamina y monedas (T-0066)

- Ruben: biomas demasiado largos, estamina que se agota enseguida y monedas que
  aparecen bajo el suelo.
- Biomas: `min_biome_tiles` 1024 â†’ 512 y `max_biome_tiles` 4096 â†’ 2048 (de 4â€“16 a
  2â€“8 chunks); la transiciÃ³n de 256 tiles sigue cabiendo en el tramo mÃ­nimo.
- Estamina: carrera 7 + 6/s y guardia 10 + 12/s (antes 10 + 10/s y 15 + 20/s).
- Monedas: `coin.gd` lanza el rayo de suelo desde 64 px arriba, asÃ­ un drop nacido
  dentro del tile detecta la superficie y sale; antes se asentaba enterrado.
- Docs `world`/`biomes`/`player`/`loot` actualizados. Sin Godot ni commit; F5 pendiente.

## 2026-11-13 Â· `buffy` Â· El salto no corta la carrera (T-0067)

- Ruben: saltar corriendo frenaba y al aterrizar se pagaba otra vez la entrada de carrera.
- `_update_stamina()` apagaba `_is_running` al despegar; sin el multiplicador, `move_toward`
  bajaba la X a 130 en el aire, y la rama de entrada volvÃ­a a cobrar `run_initial_cost`.
- Ahora la carrera solo se corta al soltar Shift, guardar, atacar o quedarse sin estamina;
  el drenaje sigue en el aire. Docs de player al dÃ­a. Sin Godot; F5 pendiente.

## 2026-11-13 Â· `opencode-jorge` Â· Iconos de consumibles y tiers de pociones (T-0069)
- Ruben confirma el mapa de sprites y pide aplicar el rework: vida/estamina en 20/50/100.
- 9 `.tres` de consumibles actualizados (nombre, efecto, icono, `id`); `Vital Essence` pasa a `Vigorizing Pie` y `Mucus Heart` a `Mucus Essence`.
- Rutas de `.tres` intactas para no romper saves; `pocion_mocos` usa `assets/items/Icon19.png` (aun sin `.import`).
- `docs/items.md` y preview `docs/pociones-antes-despues.png` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-13 Â· `opencode-jorge` Â· Iconos de pasivas pendientes (T-0070)
- Ruben pide asignar sprites parecidos a las 34 pasivas que seguian con iconos provisionales o genericos.
- Cada pasiva usa un `assets/items/item###.png` distinto: amuletos con colgante, anillo, armaduras, botas, garras, etc.
- `Focus` no existe y no se crea; `Third-Hit Projectile` no estaba en la lista y conserva `magicW`.
- `docs/items.md` y preview `docs/pasivas-antes-despues.png` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-13 Â· `opencode-jorge` Â· Correcciones de iconos de pasivas (T-0071)
- Ruben corrige T-0070: Light Armor `item221`, Heavy Armor `item226`, Greed `item169`, Wolf Fang `Icon34`, Iron Heart `item199`, Wolf Claws `Icon12`, Mucus `item310`, Wolf Pelt `item202`, Light Feet `item276`.
- `cazador` pasa a `Hunter's Faith`; `pulso_vampirico` pasa a `Sanguine Ruby` con `Icon29` copiado a `sanguine_ruby.png`.
- `docs/items.md` y preview `docs/pasivas-cambios-2026-11-13.png` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-17 Â· `opencode-jorge` Â· Sincronizar el vault tras el F5 (T-0068)

- Ruben probÃ³ durante dÃ­as todo lo que estaba en `revision` y funciona. Cierro los 52
  tickets verificados, T-0001 como absorbido y T-0002 como descartado (no hay skills).
- CorrecciÃ³n de diseÃ±o: inventario = consumibles (1/2/3, ampliables) + coleccionables con
  pasiva siempre activa o condicional; **no hay armas ni las habrÃ¡**.
- `ideas.md`, `docs/items.md`, `roadmap.md` y `estado.md` al dÃ­a. `mutant_toad.tscn`
  revertido y `.obsidian/` ignorado.
- Sin Godot ni commit: solo docs y `.gitignore`. T-0068 queda en `revision`.

## 2026-11-17 Â· `opencode-jorge` Â· Inventario legible y slots fijos (T-0072)

- Ruben: el inventario es feo, el texto del objeto es enorme y con textos largos el HUD
  se estira; los slots de consumibles se adaptan a la textura y deberÃ­a ser al revÃ©s.
- `inventory_screen.tscn`: fuentes 20/18/18 -> 15/12/12, cabeceras 13, pÃ¡gina 11, icono
  de preview 128 -> 96 y `clip_text` en la descripciÃ³n (su altura mÃ­nima empujaba la
  ventana de 248 a 404 px).
- `inventory_slot.tscn`: `expand_icon = true`; fuera el `expand_icon` que ponÃ­a
  `inventory_screen.gd` a mano. Comprobado headless: 32Ã—32 y 16Ã—16 dan slot 18Ã—18 (HUD) y
  40Ã—40 (inventario).
- `vault/items/*.md`: tabla de valores regenerada desde los `.tres` (habÃ­a fichas con los
  valores viejos de pociÃ³n) y el pendiente de textura pasa a icono asignado + F5.
- `docs/ui.md` y `vault/items.md` al dÃ­a. Sin F5.

## 2026-11-17 Â· `opencode-jorge` Â· Editor web de objetos (T-0073)

- Ruben: programa HTML para ver y editar `vault/items`; landing con los 44, editor de
  nombre/habilidades/textura y filtro por estado; al guardar debe quedar claro que el
  cambio no estÃ¡ en el juego.
- Servidor local `vault/items-editor/server.py` (stdlib, 127.0.0.1) con `/api/items`,
  `/api/items/<slug>` (GET/POST) y `/assets/` para los iconos; front en HTML/CSS/JS sin
  dependencias.
- Guardar reescribe ficha y catÃ¡logo, pone el estado `en proceso` y aÃ±ade el pendiente
  "Aplicar los cambios de esta ficha en el `.tres` y en el juego"; el `.tres` no se toca.
- Probado con `--root` sobre una copia: carga de 44 objetos, 6 estados, guardado y
  formateo del pendiente. UI sin abrir en navegador.

## 2026-11-17 Â· `opencode-jorge` Â· Editor de objetos arreglado (T-0073)

- Ruben: el editor "parece que el CSS no carga" y no se ven las imÃ¡genes. Causa real: el
  servidor mandaba `style.css` y `app.js` como `text/plain` (el navegador descarta la hoja
  de estilos) y las filas del catÃ¡logo pedÃ­an `/items/x.png` en lugar de `/assets/items/x.png`.
- Servidor: MIME por extensiÃ³n, rutas relativas en `index.html`, `/style.css` y `/app.js`
  tambiÃ©n en la raÃ­z (asÃ­ se ve algo aunque se abra el fichero a pelo).
- Datos: la landing ahora sale de `vault/items/*.md`, con el catÃ¡logo solo como respaldo
  para filas sin ficha; `?slug=` y visor del `.md` guardado; el selector de estado arranca
  en `en proceso`.
- Comprobado con Chrome headless sobre el repo real: 44 objetos, 44 iconos a 200 y CSS
  `text/css; charset=utf-8`.

## 2026-11-17 Â· `opencode-jorge` Â· Editor: estado real y valores avanzados (T-0073)

- Ruben: el estado aparece siempre "en proceso" y no tiene sentido editar valores del
  `.tres` en el editor (los `.tres` son del juego).
- Estado: fuera el desplegable que arrancaba en `en proceso`; ahora se pinta el estado
  real de la ficha y el servidor fuerza `en proceso` al guardar.
- Valores del recurso: dentro de "Opciones avanzadas" (cerrado), con nota de que son la
  tabla copiada de la ficha y que el editor no lee el `.tres`.

## 2026-11-17 Â· `opencode-jorge` Â· Editor: alta/borrado, estado y pendientes (T-0073)

- Ruben: poder aÃ±adir y borrar objetos; el estado tenÃ­a que cargarse bien, no
  desaparecer; y un script de pendientes para que el agente sepa quÃ© tocar en Godot.
- Estado: desplegable con el estado real de la ficha. Regla: si el contenido cambia y el
  estado no, se guarda `en proceso` (lo decide el cliente, el servidor obedece).
- Alta: plantilla de ficha (tipo consumible/pasiva, calidad, textura) + fila insertada en
  orden alfabÃ©tico en `vault/items.md`. Borrado: ficha + fila; el `.tres` nunca se toca.
- `pendientes.py`: sin dependencias, importa el parseo del `server.py`, compara ficha y
  `.tres` y lista solo diferencias; probado con un `.tres` cambiado y con uno que falta.
- Descubierto y arreglado: `colgante_hierro.md` tiene la tabla alineada con espacios y el
  parser la dejaba vacÃ­a (el objeto no se podÃ­a editar).
## 2026-11-17 Â· `opencode-jorge` Â· Nuevos objetos de ideas.md (T-0054)
- Ruben aprueba las 4 tandas y los valores propuestos; `Fragmento` queda fuera.
- Se crean los 14 objetos de arquero, esqueleto, fantasma y demonio, con sistemas nuevos para arco, invulnerabilidad, teleport, saltos, rata y DOT.
- Se aÃ±aden al `item_drops` de `archer.tscn`, `skeleton.tscn`, `ghost.tscn` y `demon.tscn`.
- Ficheros: `scripts/collectables/*.gd`, `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `resources/*.tres`, `scenes/collectables/player_arrow.tscn`, escenas de enemigos y docs.

---

## 2026-11-17 Â· `buffy` Â· Abierto T-0074: estructuras por chunk

- Abierto [T-0074](tickets/T-0074-estructuras-por-chunk.md) a peticiÃ³n de Ruben: que se
  puedan **aÃ±adir estructuras** (como recurso `.tres` o escena) a un bioma y que el
  generador decida por chunk si salen, **con la semilla** como fuente del reparto.
- Rama `feat/estructuras-chunk` sale de `main`; de momento **solo el ticket**, sin cÃ³digo
  ni arte: el prototipo usarÃ¡ un placeholder cantoso.
- Ficheros previstos: `scripts/world/structure.gd` (nuevo), `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/structures/`, `docs/world.md`, `docs/biomes.md`.
- Dudas en el ticket: colisiÃ³n (no en el prototipo), textura vs escena y estructuras que
  crucen chunks (fuera de alcance).

---

## 2026-11-18 Â· `opencode-jorge` Â· T-0074: estructuras por chunk implementadas

- ContinÃºo el [T-0074](tickets/T-0074-estructuras-por-chunk.md) abierto por `buffy` a
  peticiÃ³n de Ruben: `WorldStructure` + 2 `.tres` de prueba con placeholder, roll por chunk
  con la semilla, colocaciÃ³n con mÃ¡rgenes/separaciÃ³n y el bioma decidiendo cuÃ¡ntas y cuÃ¡les.
- Ficheros: `scripts/world/structure.gd` (nuevo), `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/structures/*.tres`,
  `assets/map/structures/*.png`, `resources/world/biomes/pradera.tres` y `bosque_rojo.tres`,
  `docs/world.md`, `docs/biomes.md`.
- DesvÃ­o: el nÃºmero por chunk vive solo en el bioma (no en el recurso). Ticket en `revision`,
  pendiente de F5; sin commit todavÃ­a.

## 2026-11-18 Â· `opencode-jorge` Â· T-0074: una tirada por estructura (decisiÃ³n de Ruben)

- Ruben cambia el modelo: **no** una estructura por chunk, sino una tirada
  independiente por estructura y chunk, con probabilidad por bioma. Un chunk puede no
  tener ninguna o tener todas, nunca dos de la misma.
- `Biome`: fuera `structures_per_chunk` y `structure_weights`, entra `structure_chances`.
  `WorldStructure` pierde `weight` (el bioma es la Ãºnica fuente de probabilidades).
- Pradera torre 15 % / ruina 25 %, bosque rojo ruina 30 %, nieve nada.
- Se documentan en `vault/ideas.md` Â§ 5.1 los tres tipos de estructura (sprite Ãºnico,
  generaciÃ³n a bloques y explorable) con dificultad y estimaciÃ³n en horas.
- Ficheros: `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/structure.gd`,
  `resources/world/biomes/{pradera,bosque_rojo}.tres`, `resources/world/structures/*.tres`,
  `docs/world.md`, `docs/biomes.md`, ticket T-0074.

## 2026-11-18 Â· `opencode-jorge` Â· Super planning de estructuras y tienda al 2026-12-11

- Ruben recalibra estimaciones (sprite ~1 h, bloques 4â€“8 h, explorable 15â€“30 h) y fija el
  orden prÃ¡ctico: **tipo 2 (bloques) primero**, el tipo 1 cae de paso y el 3 se apoya en el 2.
- Reparto: **RubÃ©n** estructuras y tienda; **Jorge** enemigos/objetos nuevos y arte
  (texturas y sonidos); agentes por ticket.
- Nuevo [`planning-estructuras.md`](planning-estructuras.md): tipos, calendario con hitos
  24 nov / 1 dic / 8 dic / 11 dic, backlog T-0075â€¦T-0085 con estimaciones, ruta crÃ­tica,
  decisiones pendientes (tienda), recortes y definiciÃ³n de "hecho".
- Roadmap P1 lista los tickets previstos sin abrir; se crean al arrancar cada fase.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: estructuras por bloques (tipo 2)

- Primera prueba del tipo 2: `WorldStructure.pattern` (rejilla de `#`) pintada como
  bloques grises de prueba de 16 px, sin colisiÃ³n, detrÃ¡s del decor.
- `ruin_test.tres` pasa a patrÃ³n 8Ã—5; cada columna apoya en su propio suelo, asÃ­ que la
  ruina sigue el relieve en vez de flotar.
- Ficheros: `scripts/world/structure.gd`, `scripts/world/block_structure.gd` (nuevo),
  `scripts/world_generator.gd`, `resources/world/structures/ruin_test.tres`,
  `docs/world.md`. Ticket T-0075 en `revision`, sin commit.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: atlas claro/oscuro y bloques sÃ³lidos

- Arte propio en `assets/map/structures/ruin_tiles.png` (claro) y `ruin_tiles_dark.png`
  (oscuro, derivado Ã—0.38/0.44/0.52): 8Ã—2 tiles de 16 px con variedad de tono y musgo.
- La ruina son dos capas: muro oscuro de fondo (`back_texture`, z âˆ’1, Ã­ndice 0 del chunk)
  y pocos bloques claros delante (`tile_texture`, z 0, `front_chance` 0.12 en las 2 filas
  bajas) con `StaticBody2D` en la capa 1, una caja por tramo horizontal.
- `BlockStructure` pinta del atlas con Ã­ndice por hash de celda (mismo en cada recarga) y
  usa tiles con musgo cuando no hay bloque encima. `block_color` queda de reserva.
- Generador: `vault/estructuras/make_tiles.py` (escribe los dos PNG y el preview).
- Sin commit; falta F5.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: texturas mate y sÃ³lidos solo en el suelo

- Texturas rehechas: mismo estilo de bloques + ladrillos que funcionaba, pero **mate**
  (fuera la lÃ­nea de brillo) y con mÃ¡s color (piedra gris/frÃ­a/cÃ¡lida/verde, ladrillo
  gris/cÃ¡lido/frÃ­o/oscuro/con musgo, coronaciÃ³n de ladrillo con musgo). La pared usa
  sobre todo ladrillo; la piedra queda de acento.
- GeneraciÃ³n: los bloques con hitbox ya no estÃ¡n en las 2 filas bajas al azar. Solo hay
  dos casos, ambos en la fila de suelo: piedras sueltas sobre un bloque de pared
  (`front_chance` 0.25) y vigas de soporte que rellenan los huecos bajo el muro
  (`support_chance` 0.6). Nada flota y todo se puede saltar.
- `BlockStructure.cell_tiles` permite fijar el tile por celda (la capa de delante elige
  entre piedra y viga); el muro sigue con hash de la celda y coronaciÃ³n con musgo.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: texturas segÃºn la referencia

- Atlases rehechos al estilo de la referencia: ladrillo teal muy oscuro con junta verde
  (dos variantes) y bloques de pizarra chunky en grande/largo/pequeÃ±o, claro/oscuro y con
  musgo. Sigue siendo mate.
- La pared es solo ladrillo; la fila de suelo del muro pinta piedra con musgo
  (`FOUNDATION_TILES`), como la franja de la referencia. Los sÃ³lidos de delante usan
  `STONE_TILES` y los soportes `SUPPORT_TILES`.
- `BlockStructure.cell_tiles` acepta -1 = elegir ladrillo por hash.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: fondo solo de ladrillo

- La pared de fondo ya no pinta piedra: todas las celdas son ladrillo (`WALL_TILES`);
  los bloques 8-13 (piedra grande/larga/pequeÃ±a, clara y oscura, con musgo) se quedan en
  el atlas y solo los usa la capa de delante con colisiÃ³n.
- `_blocks_cells()` deja de devolver `cell_tiles` para el fondo; `FOUNDATION_TILES`
  eliminado. `BlockStructure.cell_tiles` sigue para la capa sÃ³lida.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: fuera decor dentro de ruinas y musgo por bioma

- `_decor_outside_structures()` descarta el decor que cae dentro de `x Â± half` de
  cualquier estructura del chunk (se aplica despuÃ©s de tirar las estructuras).
- Cada estructura guarda un `tint` de `_decor_tint_at()` y pinta sus atlas con
  `_tinted_texture(source, tint, 24, 12)`; `_tint_foliage()` gana umbrales opcionales
  para no teÃ±ir la junta teal del ladrillo y dejar el musgo con el color del bioma.
  Resultado cacheado en `_decor_tint_cache`.

## 2026-11-19 Â· `opencode-jorge` Â· crash al abrir el mundo (game.tscn con exports null)

- `scenes/game.tscn` habÃ­a quedado reserializado por el editor con **todas** las
  propiedades del `map` (y de los demÃ¡s nodos con script) a `null`, incluido
  `chunk_scene = null`, asÃ­ que `_load_chunk()` llamaba `instantiate()` sobre null.
  El diff era solo lÃ­neas `= null`: restaurado con `git checkout -- scenes/game.tscn`.
- Comprobado en headless (`godot --headless --path . res://scenes/game.tscn`) sin
  errores, y otra pasada forzando `pradera` a 100 % de ruina (despuÃ©s revertido) para
  ejecutar el camino de estructuras y el tintado del musgo.

## 2026-11-19 Â· `opencode-jorge` Â· T-0075: ruinas como TileSet editable

- `BlockStructure` pasa de `Node2D` con `_draw()` a **`TileMapLayer`**: la textura y la
  colisiÃ³n ya no se calculan por cÃ³digo, se editan en el editor.
- Nuevo `resources/world/structures/ruin_tileset.tres` con dos fuentes: 0 = atlas oscuro
  (muro, sin fÃ­sica) y 1 = atlas claro (piedras del suelo). La fÃ­sica de la fuente 1 estÃ¡
  en los tiles 8, 9, 11 y 12 (capa 1); el resto no tiene hitbox.
- `WorldStructure` cambia `tile_texture`/`back_texture`/`block_color` por un Ãºnico
  `tileset`; `ruin_test.tres` apunta al nuevo recurso.
- El tintado del musgo se aplica duplicando el TileSet (`_structure_tileset()`), asÃ­ que
  los polÃ­gonos de colisiÃ³n se conservan.

## 2026-11-24 Â· `opencode-jorge` Â· Reparto de agentes y T-0076 (cajas rompibles)

- Ruben reparte el trabajo: opencode (planning + testeo + cajas rompibles), Freebuff
  (estructura explorable, T-0079) y PixelForge (arte, T-0086). Yo dirijo a PixelForge.
- Reclamo **T-0076** (fase A del planning): cajas de madera dentro de las ruinas con
  vida, drop de monedas y estado "ya roto" persistido.
- Ficheros: `scripts/world/breakable_block.gd` (nuevo),
  `scenes/world/breakable_block.tscn` (nuevo), `scripts/world_generator.gd`,
  `docs/world.md`.
- Arte definitivo: PixelForge (T-0086); de momento un placeholder de 16Ã—16.

## 2026-11-24 Â· `opencode-jorge` Â· T-0076 hecho (revision) y prompt para PixelForge

- Cajas rompibles en las ruinas: `BreakableBlock` (40 de vida, 1â€“3 monedas, seÃ±al
  `broken`), colocadas por `_crate_tiles()` (chunk 0 fuera) y persistidas en
  `world/broken` (`save_game.gd` guarda y carga la clave).
- Comprobado en headless (semilla 775344231, chunks 1â€“40): 18 cajas en 10 ruinas, 0 mal
  colocadas; la ruta real de spawn monta la caja en su fila de suelo (chunk 4);
  `scenes/game.tscn` arranca 180 frames sin errores.
- Abierto **T-0086** para las texturas de caja de PixelForge; el prompt va aparte y el PNG
  entra por mÃ­. F5 pendiente.

## 2026-11-24 Â· `buffy` Â· T-0079 interior explorable (MVP)

- Abierto T-0079 y rama `feat/estructura-explorable` desde `main` `ccbae38` en un worktree
  aparte: el checkout compartido tiene T-0076 de `opencode-jorge` sin commitear y no se ha
  tocado.
- Mazmorra autÃ³noma nueva: 2 pisos con semilla, salas de anchos variables separadas por
  muros con puerta,
  `spawn_point`, `exit_requested` y `save_state()`/`load_state()` puros (`{seed, floor}`).
- Ficheros: `scripts/world/dungeon_generator.gd`, `scripts/world/dungeon_test.gd`,
  `scenes/structures/dungeon.tscn`, `scenes/structures/dungeon_test.tscn`,
  `docs/dungeon.md`, `AGENTS.md`, `vault/tickets/T-0079-interior-explorable.md`.
- Pendiente: la puerta mundoâ†’mazmorra (hija + mundo oculto, o `change_scene` + autoload) y
  el estado por piso, para T-0080. F6 de Ruben sobre `dungeon_test.tscn`.

## 2026-11-24 Â· `buffy` Â· Entrada a la mazmorra desde el mundo (T-0087)

- Puerta negra placeholder (`scenes/structures/dungeon_entrance.tscn`) repartida por
  `WorldGenerator`: una fija junto al spawn del chunk 0 y una tirada por chunk (0.2),
  despuÃ©s de enemigos, monedas y decor para no mover sus posiciones.
- F sobre el Ã¡rea entra: `DungeonLayer` (`scenes/game.tscn`) oculta y pausa `map`,
  instancia `dungeon.tscn` y la salida devuelve al jugador al mismo punto, sin recargar
  la escena (vida, monedas, inventario y semilla se conservan).
- Ficheros: `scripts/world/dungeon_entrance.gd`, `scripts/world/dungeon_layer.gd`,
  `scenes/structures/dungeon_entrance.tscn`, `scripts/world_generator.gd`,
  `scenes/game.tscn`, `docs/dungeon.md`, `vault/tickets/T-0087-entrada-mazmorra.md`.
- Pendiente F5/F6 de Ruben; guardar dentro de la mazmorra sigue siendo T-0080.

## 2026-11-24 Â· `buffy` Â· FusiÃ³n de estructuras y arte de la mazmorra (T-0088)

- Creada `test/fusion-structure` desde `main`: merge `--no-ff` de `feat/bloques-rompibles`
  (T-0074/T-0075/T-0076) y `feat/estructura-explorable` (T-0079/T-0087); conflictos en
  `world_generator.gd` (se conservan estructuras, cajas y puertas) y en bitÃ¡cora/changelog/estado.
- La mazmorra abandona `ground_tile.png`: fondo, techo y muros con ladrillo de ruinas
  (`ruin_tiles_dark.png`) y suelo de piedra (`ruin_tiles.png`), del mismo atlas 8Ã—2 que las
  estructuras; fÃ­sica de cuadro completo en suelo/muros y `Back` sin colisiÃ³n.
- Pendiente F5 de Ruben; no hay Godot CLI en la sesiÃ³n.

## 2026-11-24 Â· `buffy` Â· Bugs de la fusiÃ³n (T-0088)

- `DungeonLayer` solo ocultaba/pausaba `map`, pero la colisiÃ³n de los `TileMapLayer` sigue
  activa; la mazmorra pasa a `WORLD_OFFSET` (y âˆ’10000) y el jugador se teletransporta allÃ­.
- `ruin_tileset.tres`: la piedra clara 8 (0:1) ya tiene cuadro completo de colisiÃ³n, asÃ­ que
  las piedras del frente son sÃ³lidas. `_structure_allowed()` descarta patrones sin `tileset`
  y las piedras del frente se mueven al Ã­ndice 0 (detrÃ¡s del decor).
- `docs/world.md`/`docs/dungeon.md` corregidos; F5 pendiente (sin Godot CLI).

## 2026-11-24 Â· `buffy` Â· Interior de castillo y salida de la mazmorra (T-0089, T-0090)

- T-0090: `assets/map/structures/castle_tiles.png` (atlas 8Ã—6 de 32 px del `map.zip`)
  repinta el interior: piedra en `Back`, ladrillo en `Walls`/techo, piedra en `Floor` y
  ventanas/estandartes en la capa nueva `Decor`. `TILE_SIZE` 32, 75Ã—6 tiles, puerta de 4
  tiles y pad de 32Ã—64 px. El `.tres` del pack no trae colisiÃ³n: el TileSet se sigue
  construyendo en cÃ³digo y todas las celdas sÃ³lidas la reciben.
- T-0089: la salida calculaba los chunks con la cÃ¡mara suavizada, que sigue en la
  mazmorra tras el teletransporte. `_update_chunks()` pasa a usar la X del jugador en ese
  caso. Medido en headless a 200 000 px: 49 chunks (0..48) â†’ 5 (140 ms).
- Comprobado en headless: 0 tiles de muro/suelo sin colisiÃ³n, 42 celdas de decor y 9 ms
  por las dos plantas. Falta F5/F6 de Ruben: aspecto del castillo y salida lejana.

## 2026-11-24 Â· `buffy` Â· Mazmorra del castillo como hall de plataformas (T-0093)

- `scripts/world/dungeon_generator.gd`: sala plana sustituida por hall de 7/9 tramos en
  filas 32â€“34, huecos de 2â€“3 tiles con repisa y escalÃ³n, losas sobre huecos anchos y ruta
  alta en la sala central; fondo de piedra hasta el marco con fosas de vacÃ­o recortadas.
- El remate del suelo pasa del tile de techo `24` al `18` para que la superficie no
  muestre la franja de vacÃ­o. Ventanas cada 5 tiles y estandartes al 25/50/75 %.
- Verificado con harness de renderizado (KP3 â†’ F, semilla `20261124`, plantas 0/1) y
  capturas `vault/estructuras/platform_f0_*.png` / `platform_f1_*.png`; falta F5/F6.

## 2026-11-24 Â· `buffy` Â· T-0093 segunda pasada: sala de referencia y responsabilidades

- Rehecha la mazmorra como una sola sala de 34 Ã— 22 (tres bloques de suelo, dos fosas,
  8 ventanas, 2 estandartes y 3 plataformas de madera), con el fondo de piedra claro.
- `scripts/structures/castle/`: `CastleLayout` (datos), `CastleTiles` (atlas/colisiÃ³n),
  `CastlePainter` (capas) y `DungeonGenerator` (ciclo); `WorldGenerator`/`WorldStructure`
  intactos. La capa de madera pasa de `Floor` a `Platforms` con colisiÃ³n fina one-way.
- Probe headless KP3 â†’ F, semilla `20261124`, plantas 0/1, sin errores de script; capturas
  `hall_spawn`, `hall_overview`, `hall_left_platform`, `hall_center_floor`, `hall_f1_spawn`.
  Falta F5/F6 de Ruben.

## 2026-11-24 Â· `buffy` Â· T-0093 paredes/suelo del castillo

- Corregidas las esquinas con las piezas reales del atlas: marco y suelo
  comparten borde `20/24/19/22` y esquinas `18/21/26/23`; el canto claro queda
  fuera del ladrillo, como en la referencia.
- `resources/shaders/castle_cutout.gdshader` descarta el pÃºrpura `#423a51`;
  `Back` deja de pintar el tile `25` y `DungeonVoid` da el negro exterior y de
  las fosas.
- Chequeo headless del castillo: marco/esquinas, fosas/exterior y materiales
  correctos; captura visual del hall completo revisada. F5/F6 pendientes.

## 2026-11-24 Â· `buffy` Â· T-0093 correcciÃ³n de orientaciÃ³n y fondo

- Solo el marco que rodea la sala vuelve al canto interior: borde `24/20/22/19`
  y esquinas `28/29/27/30`. Los bloques de suelo conservan `20/24/19/22` y
  `18/21/26/23`.
- El fondo normal era el `Parallax2D` del mundo (`z = -100`), no generaciÃ³n de
  chunks: `DungeonLayer` ya los descarga. `DungeonVoid` pasa de CanvasLayer a
  `Polygon2D` en `z = -5`, encima del parallax y debajo de `Back`.
- Probe con un fondo falso magenta en `z = -100`: el hall sale con negro y no se
  ve magenta. Frame IDs y `VOID_BACKDROP` correctos; exit 0. F5/F6 pendientes.

## 2026-11-24 Â· `buffy` Â· T-0093 fondo original, sin shader

- El PNG de `castle_tiles.png` no se ha modificado. El degradado/segundo negro
  venÃ­a de `castle_cutout.gdshader`, que convertÃ­a el pÃºrpura del atlas en
  transparencia y dejaba ver otro fondo; se elimina el shader y sus materiales.
- `DungeonVoid` usa el pÃºrpura original `#423a51` en un `Polygon2D` z=-5. Los
  bordes de suelo y marco conservan su interior original, como el borde del mapa.
- Probe con parallax falso magenta: el fondo no se cuela. Sin material en las
  capas; frame IDs correctos; exit 0. F5/F6 pendientes.

## 2026-11-25 · `opencode-jorge` · Revisión de T-0093 y T-0080 persistencia por piso

- T-0093 (de `buffy`): revisada y verificada en headless con Godot 4.7.2 (semilla
  `20261124`, plantas 0/1): colisión completa en `Walls`, `Platforms` one-way, layout
  determinista y distinto por planta, `game.tscn`/`dungeon_test.tscn` sin errores.
  Corregidos el comentario muerto del shader y el F6 (`UILayer` en `dungeon_test.tscn`).
- T-0080 abierto y hecho: `DungeonLayer.save_state()/restore_from_save()`, sección
  `[dungeon] state` en `save_game.gd` y llamada en `game.gd`. Guardar dentro del
  castillo conserva planta, posición y punto de vuelta; `run/position` y metros pasan a
  ser del mundo. Verificado headless con un probe desechable (slot 3 borrado al acabar).
  Ficheros: `scripts/world/dungeon_layer.gd`, `scripts/save_game.gd`, `scripts/game.gd`,
  `scenes/structures/dungeon_test.tscn`, `scripts/structures/castle/castle_tiles.gd`,
  `docs/dungeon.md` y `vault/`.

## 2026-11-25 · Continuación de testeo y rediseño procedural del castillo (T-0093)

- Detectado y corregido en `dungeon_generator.gd` el error de `flushing queries` al pisar `Exit` (`exit_requested.emit.call_deferred()`), dejando `_probe_flow` con 0 errores.
- `castle_tiles.gd` / `castle_painter.gd`: añadido `SOLID_FILL` (`25`) y autotiling por 8 vecinos sobre un grid booleano `solid[x, y]` para fusionar marco, bloques adyacentes y esquinas sin huecos ni cortes negros.
- `castle_layout.gd` / `dungeon_generator.gd`: hall ampliado a 64 tiles, techo bajado a `TOP_ROW = 6` con ventanas/estandartes en `y = 8`, suelo continuo escalonado sin fosas (alternando escalones de piedra de 1 tile y subidas de 2–3 tiles con plataformas mínimas) y verificador BFS (`20/20` layouts alcanzables, 0 errores en Godot 4.7.2).
- Ficheros: `scripts/structures/castle/{castle_layout,castle_painter,castle_tiles,dungeon_generator}.gd`, `docs/dungeon.md`, `vault/{changelog,bitacora,estado}.md`.
