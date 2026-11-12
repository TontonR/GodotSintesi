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

## 2026-11-05 · `buffy` · KP5 inmortal, pasivas sin stack y caducidad de pickups (T-0022)

- Pedido por `humano-ruben`: KP5 alterna inmortalidad; pasivas que no se apilen ni se
  vuelvan a soltar una vez equipadas; pickups que parpadean a los 25 s vistos y se van
  a los 30 s, con borrado de seguridad a los 60 s desde el spawn; monedas excluidas.
- Afectados: `scripts/debug_tools.gd`, `scripts/player.gd`,
  `scripts/collectables/player_passive.gd`, `scripts/collectables/passive_items.gd`,
  `scripts/enemies/enemy_base.gd`, `item_pickup.gd`, `docs/items.md`, `docs/player.md`.
- Sin commit y sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente en el editor.

## 2026-11-05 · `buffy` · Biomas por bloque y más bosque rojo (T-0023)

- Pedido por `humano-ruben`: la transición de biomas pasa de chunks a bloques, con la
  transición tan ancha como un chunk; hay muy poco bosque rojo.
- `world_generator.gd`: bioma por bloque, ventana deslizante de 256 bloques para el
  color, bosques de fondo teñidos al cambiar de bloque, `biome_frequency` 0.12 y
  `biome_transition_tiles` (0 = un chunk). Pesos 0.6/0.4 en los `.tres`.
- `chunk.gd`/`chunk.tscn`: el césped ya no es un `TileMapLayer` teñido entero; se
  dibuja columna a columna con `GrassPaint`.
- Afectados: `scripts/world_generator.gd`, `scripts/world/chunk.gd`,
  `scenes/world/chunk.tscn`, `resources/world/biomes/pradera.tres`,
  `resources/world/biomes/bosque_rojo.tres`, `docs/world.md`.
- Sin commit y sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente en el editor.

## 2026-11-05 · `buffy` · Fondos tintables y terreno por bioma (T-0024)

- Pedido por `humano-ruben`: el bosque rojo se veía negro de fondo; regenerar pinos y
  montaña con solo la vegetación en gris claro y la punta de la montaña sin pintar; y
  que el bioma module el ruido Perlin (bosque rojo con alturas más marcadas).
- Assets: `pine1_gray.png`/`pine2_gray.png` regenerados y `mountain2_gray.png` nuevo
  (solo bosque teal, transparente en piedra/punta). Script de Python temporal, sin
  ficheros extra en el repo.
- `game.tscn`: pinos grises y `mountains/Sprite2DGreen`; `forest_tint_paths` incluye ese
  overlay. La piedra de la montaña sigue sin teñirse por bioma.
- `world_generator.gd`/`biome.gd`: modificadores de amplitud y frecuencia por bioma
  (bosque rojo 1.7/1.25) mezclados en la ventana de 256 bloques, con alturas float64
  deterministas en las costuras.
- Afectados: `assets/map/background/`, `scenes/game.tscn`, `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/biomes/bosque_rojo.tres`, `docs/world.md`.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit de la tanda al cerrar.

## 2026-11-05 · `buffy` · Gris medio y verde original en la pradera (T-0025)

- `humano-ruben`: el gris claro de T-0024 fue un error; bajarlo y que el bosque
  normal (pradera) recupere el verde de antes.
- Assets regenerados con gris `100 + 0.35 × max(R,G,B)` (~113–129).
- Nuevo `Biome.forest_color` (solo fondos): pradera `(0.233,0.388,0.388)` = verde
  original `(27,45,45)` sobre el gris 116; bosque rojo `(1,0.32,0.28)`.
- `_biome_tint_at_tile()` usa `forest_color`; el césped sigue con `grass_color`.
- Afectados: `assets/map/background/*_gray.png`, `scripts/world/biome.gd`,
  `scripts/world_generator.gd`, `resources/world/biomes/*.tres`, `docs/world.md`.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit al cerrar.

## 2026-11-05 · `buffy` · Un tono por capa de fondo (T-0026)

- `humano-ruben`: los tres fondos salían del mismo color con T-0025; antes cada
  capa era más oscura que la siguiente. Que se diferencien en todos los colores.
- Gris calibrado por capa: pino cercano 92, pino lejano 116, montaña 172/211.
  Con `forest_color` de pradera devuelven los tonos originales de cada capa.
- Bosque rojo: mismos escalones, `(92,29,26)` < `(116,37,32)` < `(172,55,48)` <
  `(211,68,59)`.
- Sin cambios de código: solo assets y `docs/world.md`.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit al cerrar.

## 2026-11-05 · `buffy` · Nieve separada, bioma de nieve y ambiente (T-0027)

- `humano-ruben`: la punta de nieve salía teñida; separarla y ponerla encima,
  añadir bioma de nieve, suavizar el relieve rojo, aplanar un poco la pradera y
  meter hojas rojas / copos de nieve.
- Causa: `mountain2_gray.png` se regeneró con toda la montaña; el overlay está
  en `forest_tint_paths` y teñía piedra y nieve. Ahora solo el bosque.
- `mountain2_snow.png` + `Sprite2DSnow` encima; `Biome.rock_color` +
  `rock_tint_paths` para la piedra (gris solo en nieve).
- `nieve.tres`: césped (0.93,0.96,1), bosque (0.82,0.88,0.96), 2 esqueletos +
  2 arqueros + 1 lobo, peso 0.2. Pesos 0.55/0.3/0.2.
- Terreno: rojo 1.35/1.1; pradera 0.95.
- `biome_particles.gd`: hojas (28) y copos (220) con texturas generadas en código.
- Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente. Commit al cerrar.

## 2026-11-05 · `buffy` · FX de combate y feedback de HUD (T-0028)

- `humano-ruben`: añadir muchas mejoras de partículas y UX.
- `scripts/fx.gd` + nodo `fx` (grupo `fx`): chispas de golpe, estallido de
  muerte, polvo al saltar/aterrizar/correr, chispas de moneda/objeto/curación,
  números flotantes, sacudida de cámara y flash rojo.
- HUD: pop del contador de monedas y latido de la barra bajo el 30 % de vida.
- Biome particles: fundido de 0,4 s al entrar/salir y viento lateral.
- Enganches en player, enemy_base, coin, item_pickup y biome_particles.
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-05 · `buffy` · Polvo a los pies, sangre y moco (T-0029)

- `humano-ruben`: el polvo de correr/saltar salía del ombligo, el moco solo del
  centro y la muerte de los enemigos se quedaba corta.
- `scripts/player.gd`: `_feet_offset()` toma la mitad inferior de
  `CollisionShape2D` (16×54 px) y las tres llamadas de polvo emiten a ras de
  suelo; `dust()` baja a gravedad 240 y radio 4.
- `scripts/collectables/moco_emitter.gd`: emisión en caja de 14×48 px que cubre
  la hitbox, en vez de esfera de radio 8 en el centro.
- `scripts/fx.gd`: `_burst()` acepta gravedad, radio, spread y alineación a la
  velocidad; `enemy_death()` lanza 4 capas de sangre (32+26+14+8 partículas,
  gota 2×5 con estela) y `shake(1.4, 0.12)`.
- F5 pendiente; commit al cerrar.

## 2026-11-05 · `buffy` · Polvo del bioma, parry y física de pickups (T-0030)

- `humano-ruben`: el polvo no reflejaba el color del césped, faltaban efectos al
  parrear y las monedas/objetos no tenían física visible.
- `scripts/fx.gd`: `dust()` consulta `WorldGenerator.biome_at_world_x()` y usa
  `grass_color.lightened(0.35)`; nuevo `parry()` con chispas blancas/doradas,
  `¡PARRY!`, `shake(1.2, 0.1)` y `damage_flash()` con color/alfa opcionales.
- `scripts/player.gd`: `parry_window` 0,18 s al levantar la guardia; el golpe
  frontal dentro de la ventana se para con `fx.parry()` y consume la ventana.
- `scripts/collectables/coin.gd`: gravedad 900, raycast al suelo con reintentos,
  rebote 0,4 y vaivén de 1 px. `world_generator`: `coin_spawn_height` 40 px.
- `item_pickup.gd`: `drop_hop` 150 px/s al aparecer.
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-05 · `buffy` · Parry retocado y estadísticas (T-0031)

- `humano-ruben`: el parry iba raro, había que cambiar su stamina y faltaban
  stats (velocidad de ataque, daño/prob. crítico, velocidad, suerte) que se
  vieran siempre a la izquierda sin molestar.
- `scripts/player.gd`: `parry_window` 0,2 s + `parry_cooldown` 0,3 s (no se
  rearma spameando), `parry_stamina_refund` 30 al acertar, `fx.parry_ready()`
  al abrir la ventana y `_apply_damage()` devuelve si el golpe llegó para no
  empujar nunca con la guardia puesta.
- Stats nuevas: `attack_speed` (escala la animación de ataque), `crit_chance`
  0,05, `crit_damage` 2.0 y `luck` 0, con métodos `add_*` y crítico base en
  `_deal_damage()`. `enemy_base.take_damage()` reenvía `critical` a
  `fx.enemy_hit()` y `_luck_drop_bonus()` mete la suerte en el loot.
- Panel `UILayer/StatsPanel`: `GridContainer` de 2 columnas en (5, 26), fuente 9,
  alpha 0,6, refresco por `_stats_dirty` (no cada frame).
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-05 · `buffy` · Daño en el panel y ambiente horizontal (T-0032)

- `humano-ruben`: faltaba la stat de daño, el panel chocaba con las monedas y
  las partículas de ambiente dejaban huecos al derivar de lado.
- `scripts/player.gd`: fila `Daño` (`hitbox_damage`) y panel movido a (5, 82),
  por debajo de la línea de monedas (y≈63); 6 filas y refresco por `_stats_dirty`.
- `scripts/world/biome_particles.gd`: `emission_rect_extents.x` de `view.x × 0,6`
  a `× 1,2` y cantidad al doble (56 hojas, 440 copos) para mantener densidad.
- F5 pendiente (regla de `AGENTS.md`); commit al cerrar.

## 2026-11-06 · `buffy` · Bóveda de ideas

- Creado `vault/ideas.md` a partir de las notas de `humano-ruben`: personaje,
  enemigos, DOT/estados, objetos, tienda y biomas, con estado
  (`hecho`/`parcial`/`idea`/`por definir`) y las dudas abiertas agrupadas.
- 17 pasivas ya están implementadas y en `EnemyBase.PRESET_POOLS`; los biomas
  existentes son pradera, bosque rojo y nieve; no hay tienda ni sistema de efectos.
- Detectado que `DISABLED_ENEMY_SCENES` no se usa y los biomas aún listan fantasma
  y demonio: conviene comprobarlo en F5.
- Registrado en el índice de `vault/README.md` y enlazado desde `roadmap.md`.
  Sin cambios de código ni tickets nuevos.

## 2026-11-06 · `buffy` · Entrega 2

- Creado `vault/entrega-2.md` (catalán, para Google Docs): resumen, cambios
  desde la entrega 1, explicación del cambio de herramientas (OpenCode →
  FreeBuff y Gemini Chat → OpenCode) y funcionamiento del vault entre IAs.
- Recalca los tres próximos objetivos (texturas de objetos, estructuras y
  boses, objetos y mecánicas) y justifica la reestructuración como causa del
  menor progreso visible. Sin cambios de código.

## 2026-11-06 · `buffy` · Sacudida de cámara y encuadre (T-0033)

- `humano-ruben`: tras el primer golpe la cámara se centraba en el jugador y no
  volvía al encuadre del arranque.
- Causa: `scripts/fx.gd` escribía `camera.offset` para la sacudida y al acabar
  lo ponía a `Vector2.ZERO`, borrando el `(60, -70)` de `scenes/player.tscn`.
- `scripts/fx.gd`: `_camera_base_offset` se captura al iniciar la sacudida (solo
  si no hay otra activa) y se restaura al expirar; el temblor va sumado encima.
- `docs/fx.md` actualizado. F5 pendiente (regla de `AGENTS.md`).

## 2026-11-06 · `buffy` · Inventario al doble (T-0034)

- `humano-ruben`: la GUI del inventario quedó pequeña tras el gran cambio de
  tamaños; pide el doble solo en el inventario.
- Causa: el viewport pasó a 768×432 (T-0010) y la pantalla conservó las medidas
  de 384×216.
- `scenes/inventory/inventory_screen.tscn`: todo duplicado (ventana 744×380,
  márgenes, radios, bordes, separaciones, paneles, retrato, preview y fuentes).
- `scenes/inventory/inventory_screen.gd`: huecos 40×40, coleccionables 32×32 y
  `expand_icon`; el HUD sigue a 18×18.
- `docs/ui.md` actualizado. F5 pendiente.

## 2026-11-09 · `opencode-jorge` · Lobo menos agresivo (T-0035)
- Petición de Ruben: el lobo corre demasiado y no deja pelear.
- `scripts/enemies/werewolf.gd`: `charge_speed` 150, `charge_distance_scale` 0.4, `attack_recovery` 1.5 y recuperación quieto (sin persecución).
- F5 pendiente; ticket en `revision`.

## 2026-11-09 · `opencode-jorge` · Slime y lobo en el bosque (T-0036)
- Petición de Ruben: slime en el bosque y menos lobos.
- `resources/world/biomes/bosque_rojo.tres`: `enemy_counts` [1 lobo, 1 sapo, 1 demonio, 2 slimes].
- F5 pendiente; ticket en `revision`.

## 2026-11-09 · `opencode-jorge` · Loot por enemigo (T-0037)
- Ruben rechaza los presets compartidos: quiere tabla y probabilidad por objeto en cada enemigo.
- `LootEntry` nuevo y `item_drops` en `EnemyBase`; fuera `PRESET_POOLS`, `loot_preset`, `item_drop_chance` y `rare_loot_weight`.
- Cuatro escenas migradas (ogro, lobo, rana y slime). F5 pendiente; ticket en `revision`.

## 2026-11-09 · `opencode-jorge` · Corrección del loot (T-0037)
- Ruben aclara: una sola tirada para todos los coleccionables (probabilidades sumadas) y monedas siempre aparte, pudiendo soltar varias.
- `_drop_loot` separado en `_drop_coins` y `_drop_item`; elección del objeto ponderada por `drop_chance`.
- Docs y ticket actualizados. F5 pendiente.

## 2026-11-10 · `opencode-jorge` · Fuera skills (T-0038)
- Ruben quita las skills: el inventario queda con 3 consumibles y teclas 1/2/3.
- `Skills.gd` borrado; `SKILL_SLOTS`, `SkillsFlow` y `use_slot_4/5` fuera.
- `docs/items.md` pasa a catálogo completo (9 consumibles + 35 pasivas), todas en `falta textura`.
- F5 pendiente; ticket en `revision`.

## 2026-11-12 · `opencode-jorge` · Tope de pendiente en el terreno (T-0049)
- Reclamo T-0049 (petición de Ruben): paredes de 4 tiles en la seed 775344231 (tile 28227).
- `max_step_tiles` (1) en `world_generator.gd`: cada columna a ±1 fila de la anterior, cadena cacheada por chunk; la columna compartida se hereda del vecino para no romper la costura. Fuera `_terrain_at_tile()`.
- Verificado con script headless desechable (seed 775344231, 28k tiles): escalón máximo 1 y costuras exactas; `game.tscn` arranca sin errores.
- `docs/world.md` y `changelog.md` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-12 · `buffy` · Terreno redondeado en vez de escalera (T-0050)
- Petición de `humano-ruben`: el tope de ±1 de T-0049 convirtió las laderas en una escalera
  antinatural (diagonales de un escalón por columna, tramos de hasta 51 columnas). Que se
  vean redondeadas, con paredes de 2 tiles y de 3 muy de vez en cuando.
- `scripts/world_generator.gd`: fuera `clampi(h, prev ± max_step_tiles)`.
  `_build_shaped_heights()` + `_shaped_step()` sostienen la losa con
  `tread_hold_chance` (0.65, mitad a 2 tiles de desvío) y pegan pared de
  `max_step_tiles` (ahora 2), con 3 cuando sale `rare_step_chance` (0.06). La tirada es
  `_terrain_roll()` (hash de seed + columna), sin RNG que arrastrar entre chunks.
  `_clamped_*` renombrados a `_shaped_*`.
- Verificado con script headless desechable (seeds 12345 y 775344231, 28 200 tiles):
  máximo 3, 74–76 % de columnas planas, 14 % de 1 tile, 10–11 % de 2 y 0.2 % de 3;
  costuras exactas en 110 chunks y spawn plano. `game.tscn` arranca sin errores.
- `docs/world.md`, `changelog.md` y `estado.md` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-12 · `buffy` · Elevaciones exageradas del bosque rojo (T-0051)
- `humano-ruben`: prefiere la generación anterior a la de T-0050 (demasiados suelos de 2
  tiles) y siguen saliendo elevaciones exageradas en algunos sitios.
- `scripts/world_generator.gd` revertido a T-0049 (`git checkout`): vuelve el tope de ±1,
  sin `_shaped_step()`. T-0050 queda `cerrado` como revertido.
- Causa de las zonas raras: no era el ruido ni las costuras, sino los modificadores del
  bosque rojo (`terrain_amplitude_multiplier` 1.35 y `terrain_frequency_multiplier` 1.1).
  Con el tope de ±1 el suelo no puede seguir al ruido y fabrica rampas de un escalón por
  columna: 30–40 tiles de montaña y hasta 123 escalones seguidos.
- Medido en el generador real (40 000 tiles, seeds 12345/775344231/777): la frecuencia era
  la de las rampas (123 → 21–22 al bajarla) y la amplitud la de las montañas (relieve
  37–39 → 28–29). Con el bosque rojo en 0.95/1.0: peor ventana de 300 tiles 26 y tramos
  de 11–14 escalones.
- `bosque_rojo.tres` a 0.95/1.0 y `docs/world.md` actualizado con la regla "un bioma solo
  aplana". F5 pendiente; ticket en `revision`.

## 2026-11-12 · `buffy` · Barrera izquierda como montaña y debug de velocidad (T-0052, T-0053)
- `humano-ruben`: a la izquierda se veía el vacío; quería una gran montaña, escalable un
  poco al principio pero imposible de subir, para camuflar la barrera. Y el numpad
  cambia: KP7 mitad, KP9 doble sin límite y KP8 reset.
- `scripts/world/chunk.gd`: `paint()` acepta `left_heights` y pinta columnas en X local
  negativo (el `TileMapLayer` no tiene límites), con el tono de hierba de la columna 0.
- `scripts/world_generator.gd`: grupo `Left wall` (`left_wall_tiles` 56,
  `left_wall_climb_tiles` 2, `left_wall_step_rows` 4), `_left_wall_heights()` cacheado y
  solo en chunk 0. Empieza en `base_height`, sube 1 tile por columna dos veces y después
  4 filas por columna hasta `min_height`, donde se queda. Fuera de la cadena con tope.
- `_keep_player_inside_world()` pasa de parar en `TILE_SIZE` a parar en la última columna
  pintada (`-880 px`).
- Medido con script headless sobre `game.tscn`: 56 columnas de -56 a -1, la de -1 en fila
  49, subida máxima 4 filas, 10 tramos de 4, cresta plana en fila 5 desde -37; jugador
  forzado a -5000 px acaba en -880. 4 filas = 64 px > 41 px de salto.
- `scripts/debug_tools.gd`: fuera `SPEEDS`; `_speed` float con KP9 ×2, KP7 ×0.5 y KP8 a
  1.0, suelo `MIN_SPEED` 0.001; `game_speed` pasa a `start_speed`. Verificado enviando
  teclas al nodo: x1 → x2 → x4 → x2 → x1 → x0.5 → x0.25 y etiqueta `x0.25`.
- `docs/world.md`, `docs/player.md`, `README.md`, `changelog.md` y `estado.md`
  actualizados. F5 pendiente; ambos tickets en `revision`.

## 2026-11-12 · `buffy` · Viaje rápido sobre el terreno (T-0054)
- `humano-ruben`: KP4/KP6 no deben subir un número fijo de tiles respecto a la posición
  actual, sino dejar al jugador un poco por encima del terreno del destino.
- `scripts/world_generator.gd`: `ground_y_at(world_x)` devuelve la fila superior de la
  columna en píxeles; `_height_at()` ya resuelve los tiles negativos con
  `_left_wall_height_at()` (la cresta de T-0052 en la fila 5).
- `scripts/debug_tools.gd`: `teleport_lift_tiles` (10) fuera, entra
  `teleport_above_ground_tiles` (4); `_teleport()` calcula X destino, pone Y en
  suelo − 4 tiles y llama a `refresh_chunks()` para que el terreno exista en el frame.
- Medido en `game.tscn` enviando teclas: hueco de 4.00 tiles tras KP6 desde el spawn
  (tile 50 → 114.5) y otra vez (→ 178.5), 3.96 al volver con KP4 y 3.92 al caer sobre la
  cresta de la barrera izquierda (tile −52, fila 5).
- `README.md`, `docs/player.md`, `changelog.md` y `estado.md` actualizados. F5 pendiente;
  ticket en `revision`.
