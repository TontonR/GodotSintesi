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

## 2026-11-12 · `buffy` · Monedas arriba a la izquierda con icono (T-0055)
- `humano-ruben`: el contador de monedas sale debajo de las stats; lo quiere arriba a la
  izquierda con un icono de moneda.
- Causa: `UILayer/coins` tenía `anchors_preset = 15` (pantalla completa) con el texto
  centrado. En 768×432 caía en (10, 63), pero en un viewport mayor (pantalla completa
  adaptativa) baja con la pantalla y acaba sobre el panel de stats.
- `scenes/game.tscn`: `coins` a rect fijo (26, 26)–(120, 42), alineado a la izquierda y
  12 px; nodo nuevo `coin_icon` (TextureRect 16×16 en (6, 26)) con un `AtlasTexture` del
  primer frame de `assets/coins/MonedaD.png`. Se mantiene la ruta `UILayer/coins` porque
  `player.gd::_ensure_coins_ui()` la busca; el fallback de código usa el mismo rect.
- Medido con script headless en 768×432 y 960×540: label en (26, 26) 94×17 e icono en
  (6, 26) 16×16 en ambos; consumibles (4, 4)–(108, 22) y stats (5, 82) intactos; con
  `add_coin(7)` el texto pasa a "7" y el pop sigue.
- `docs/ui.md`, `changelog.md` y `estado.md` actualizados. F5 pendiente; ticket en
  `revision`.

## 2026-11-12 · `buffy` · Auditoría de documentación (T-0056)
- `humano-ruben` pide actualizar toda la documentación y crear en el vault lo que falte
  (enemigos, drops, biomas, items…).
- Auditoría contra código: sets de enemigos por bioma (`pradera` 3 orcos + 3 slimes + 1
  sapo, `bosque_rojo` 1 lobo + 1 sapo, `nieve` 2 esqueletos + 2 arqueros + 1 lobo), 44
  `.tres` con icono, estadísticas de enemigos en `_init()` con ×1.35/×1.25, `item_drops`
  reales (orco 42 %, lobo/rana/slime 32 %) y caída de 260 px a 620 px/s.
- Reescritos `docs/enemies.md` y `docs/items.md`; nuevos `docs/biomes.md`,
  `docs/loot.md` y `docs/passives.md`; corregidos `docs/world.md` (ventana, biomas,
  caída), `docs/ui.md` (`DebugHint`), `docs/player.md` (stats 5, 82),
  `docs/historial.md` y `README.md` (controles 1-3, New Game, sin KP3).
- Vault: nuevo `vault/documentacion.md` (mapa + auditoría + huecos: audio, muerte,
  skills, progresión, jefe), índice en `vault/README.md`, totales y correcciones en
  `vault/pasivas/` (Maza +2, Colmillo +3, Piedra de oro +10 %).
- Verificado con grep/sed sobre escenas, `.tres` y scripts; sin tocar código, no hace
  falta F5. Ticket en `revision`.

## 2026-11-12 · `buffy` · Decoraciones de bioma (T-0057) y ramas por feature
- `humano-ruben` pide que cada feature vaya en su propia rama y se integre con PR, y que
  el mundo spawee `assets/map/decor` (2 arbustos, 2 árboles, 2 rocas) detrás del suelo, sin
  colisión, escala ni parallax, con el verde tintado por bioma.
- Vault: `README.md` estrena el flujo de ramas/PR (`feat/<slug>`, merge squash, `main` solo
  recibe merges); `AGENTS.md` recoge la regla y `estado.md` apunta a `feat/decor`.
- Código: `Biome.decor_colors` (array) y grupo **Decor** en `WorldGenerator`; cada sprite
  es el primer hijo del chunk (detrás de `Solid`/`GrassPaint`) y las copias grises
  `bush_1_gray.png`, `bush_2_gray.png` y `tree_gray.png` se generan dejando los troncos.
- Tres tintes por bioma: verdes en pradera, rojos/naranjas en bosque rojo y verdes fríos en
  nieve; rocas y árbol muerto no se tintan.
- Verificado con script headless; queda el F5 visual y el push/PR de la rama.

## 2026-11-12 · `buffy` · Decoraciones, segunda pasada (T-0057)

- Feedback de Ruben: todo más grande y muchos más árboles, con densidad y tipos por bioma; pradera con bastantes árboles y bosque rojo con muchísimos más (rojos, con naranjas y amarillos en menor cantidad); rocas al fondo; arbustos que se mueven y sueltan partículas al pasar.
- `Biome` gana `decor_per_chunk`, `decor_kinds`, `decor_weights` y `decor_color_weights`; el generador conserva sus arrays como fallback y resuelve los nombres (`decor_lookup`).
- Escalas 1.7–1.9 con `offset` en la base; rocas `z_index` −1 y orden de dibujo rocas → árboles → arbustos; nuevo `scripts/world/decor_prop.gd` para el bamboleo y las hojas, con `fx.leaves()` reutilizando el nodo `fx`.
- Comprobado headless: pradera 32 decorados (13 árboles), bosque rojo 52 (35 árboles; tintes 29/15/5), nieve 24, bases alineadas, 0 colisiones, rocas al fondo y bamboleo con 1 estallido de hojas. F5 pendiente.
- `feat/decor` publicada y [PR #1](https://github.com/TontonR/GodotSintesi/pull/1) abierta contra `main`, sin mergear. La PR incluye además los 3 commits locales de `main` que aún no están en `origin`.
- Afectados: `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/decor_prop.gd`, `scripts/fx.gd`, `resources/world/biomes/*.tres`, `docs/decor.md`, `docs/biomes.md`, `docs/world.md`, `docs/fx.md`, ticket T-0057, `changelog.md`, `estado.md`, `roadmap.md`.

## 2026-11-12 · `buffy` · Decoraciones, tercera pasada (T-0057)

- Ruben: los troncos salían teñidos aunque el gris estaba bien; zonas vacías y zonas sobrecargadas; nieve con poca generación y 40% de árboles muertos; subir todo a git.
- Causa: `tree_gray.png` conserva el tronco marrón, pero el `modulate` del bioma multiplica el sprite entero. Ahora `_decor_texture()` genera y cachea una copia por textura + color y `_tint_foliage()` solo recolorea los píxeles verdes (hojas), dejando tronco, contorno y marrones intactos; `modulate` queda en blanco y `DecorProp.tint_color` da color a las hojas.
- Reparto: slots estratificados (un prop por slot, ±30% de jitter) y `decor_min_gap_tiles` = 3; densidades 20/26/10 por chunk y `Biome.decor_dead_tree_ratio` (nieve 0.4) convierte el 40% exacto de los árboles del chunk en muertos.
- Verificado headless: tronco idéntico al original con tinte rojo, hojas teñidas, rocas y árbol muerto sin tocar, caché reutilizada; separaciones mínimas 9/5/21 tiles; 20/26/10 props por chunk; nieve 15 vivos / 10 muertos = 0.40. F5 pendiente.
- Afectados: `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/decor_prop.gd`, `resources/world/biomes/{pradera,bosque_rojo,nieve}.tres`, `docs/decor.md`, ticket T-0057, `changelog.md`, `estado.md`.

## 2026-11-13 · `buffy` · Nieve casi blanca y atravesar enemigos (T-0057 cuarta pasada, T-0058)

- Ruben: la vegetación de la nieve sale gris y, andando, se empuja a los enemigos; prefiere atravesarlos pero que atravesarlos duela.
- `resources/world/biomes/nieve.tres`: `decor_colors` pasa a `(0.98, 1, 1)`, `(0.88, 0.94, 0.99)` y `(0.78, 0.86, 0.94)` con los mismos pesos 3/3/2.
- Empuje: `slime.tscn`, `skeleton.tscn` y `archer.tscn` tenían `collision_mask = 3` (mundo + jugador) y su `move_and_slide()` los sacaba del solape; bajan a 1 como el resto.
- Daño de contacto en `scripts/player.gd`: `body_contact_damage` (5) y `body_contact_cooldown` (1 s por enemigo) con `intersect_shape` sobre la máscara 4 y `take_damage_from()` sin knockback (guardia/parry frontal y KP5 siguen valiendo).
- Afectados: `resources/world/biomes/nieve.tres`, `scripts/player.gd`, `scenes/enemies/{slime,skeleton,archer}.tscn`, `docs/decor.md`, `docs/biomes.md`, `docs/player.md`, `docs/enemies.md`, tickets T-0057 y T-0058, `changelog.md`, `estado.md`, `roadmap.md`.
- Verificado solo por inspección: F5 pendiente de empuje, daño de contacto y tono de la nieve.

## 2026-11-13 · `buffy` · Muerte definitiva y tres slots de guardado (T-0059, T-0060)

- Ruben: al morir no se debe revivir; pantalla de muerte y la run se acaba. Guardado en hasta 3 runs (slots) sobrescribibles. Recuerda fusionar las PR a `main`.
- `scripts/save_game.gd` pasa de un `user://savegame.cfg` a `user://run_slot_N.cfg` con `current_slot`, `slot_summary()`, `start_new_run()` y `delete_slot()`; se van `SAVE_PATH` y `has_save()`.
- Menú principal: fuera New Game/Continue; `Menu/Layout/Slots/Slot1…3` con `Play` (continúa o empieza run nueva con semilla) y `Erase`.
- Muerte: `Player.died` + `is_dead()`, `Game._on_player_died()` borra el slot, espera 1.4 s y abre `DeathScreen` (CanvasLayer 30) sin revivir; `save_run()` rechaza salud 0 y la pausa no guarda una run muerta.
- Afectados: `scripts/save_game.gd`, `scripts/game.gd`, `scripts/player.gd`, `scripts/ui/{main_menu,pause_menu,death_screen}.gd`, `scenes/main_menu.tscn`, `scenes/game.tscn`, `scenes/ui/death_screen.tscn`, `docs/ui.md`, `docs/player.md`, tickets T-0059/T-0060, `changelog.md`, `estado.md`, `roadmap.md`.
- `gh` no está instalado en esta máquina: la PR #1 sigue abierta y hay que mergearla desde GitHub (o instalando `gh`) antes de que `main` reciba estas features.

## 2026-11-13 · `buffy` · Menú New Game / Continue / Load (T-0060, revisión de UX)

- Ruben: quería el menú anterior (New Game + Continue) y un botón Load que despliegue las partidas guardadas; Continue carga la última run cerrada.
- `scenes/main_menu.tscn`: vuelven `NewGame` y `Continue`, se añade `Load` y las tres filas de slot (Play/Erase) se mueven a `Menu/LoadDialog` con `Back` y Esc.
- `scripts/save_game.gd`: `latest_slot()` (mtime más reciente = última run cerrada) y `slot_for_new_run()` (primer slot libre o el más antiguo si los tres están llenos).
- `scripts/ui/main_menu.gd`: New Game → semilla → slot automático; Continue → `latest_slot()`; Load → diálogo con los tres slots, filas vacías deshabilitadas y Erase.
- Afectados: `scenes/main_menu.tscn`, `scripts/ui/main_menu.gd`, `scripts/save_game.gd`, `docs/ui.md`, ticket T-0060, `changelog.md`, `estado.md`.
- Verificado por inspección; F5 pendiente (crear 3 runs, borrar una, Continue y cargar cada slot).

## 2026-11-13 · `buffy` · Arreglo de la pantalla de muerte (T-0059)

- Ruben: la pantalla de muerte no aparecía. Causa: el editor abierto reserializó `scenes/game.tscn` y se llevó el nodo `DeathScreen` y su `ext_resource`; `Game._on_player_died()` no lo encontraba y no mostraba nada.
- Arreglo: nodo devuelto a `game.tscn` y `Game._ensure_death_screen()` instancia `res://scenes/ui/death_screen.tscn` si la escena no lo trae (protege ante futuras reserializaciones del editor).
- Verificado con script headless desechable (`res://_death_check.gd`, borrado después): `dead=true`, `health=0`, `screen_visible=true`, `paused=true`, Godot exit 0 sin errores de script.
- Afectados: `scenes/game.tscn`, `scripts/game.gd`, `docs/ui.md`, ticket T-0059, `changelog.md`, `estado.md`.

## 2026-11-13 · `buffy` · Aviso de sobrescritura + contador de metros (T-0060, T-0061)

- Ruben: quería que al guardar sin hueco el juego avisara y pidiera qué run sobrescribir; contador de metros (bloques) arriba al centro; y que Load muestre monedas y metros en vez de la semilla.
- `SaveGame`: `has_free_slot()` y `first_free_slot()` (devuelve -1 si no queda hueco) sustituyen a `slot_for_new_run()`; `[run] meters` nuevo, con `SPAWN_X` (808) como fallback para slots viejos; `slot_summary()` expone `meters`.
- `WorldGenerator.meters_at(world_x)` (spawn 50×16+8); `UILayer/Meters` en `game.tscn`; `Game._process()` refresca el label solo al cambiar de bloque.
- Menú: Start arranca en el primer hueco o abre `LoadDialog` en modo sobrescritura (todo habilitado, `Erase` oculto, `Back` vuelve al diálogo de semilla); las filas muestran `M m · C coins`.
- Verificado: `--check-only` en world_generator/save_game/game/main_menu (exit 0) y script headless desechable (borrado) → `start_m=0 label=0 m`, tras +160 px `10 m`. F5 pendiente.
- Afectados: `scripts/world_generator.gd`, `scripts/save_game.gd`, `scripts/game.gd`, `scripts/ui/main_menu.gd`, `scenes/game.tscn`, `docs/ui.md`, tickets T-0060/T-0061, `changelog.md`, `estado.md`, `roadmap.md`.

## 2026-11-13 · `buffy` · El parry perfecto aturde al lobo (T-0062)

- Ruben: el lobo quedó OP con el daño de contacto (atraviesa, golpea por la espalda donde no llega el escudo, corre más que tú y el contacto te desintegra). Pide aturdimiento de 0.5–1 s al pararle perfecto y que sea un poco más lento.
- Causa real: el lobo ya pega con su propio hitbox y el jugador le sumaba encima los 5 px de contacto genérico (13 + 5 cada 0.5 s).
- `EnemyBase.uses_custom_contact_damage()` (false por defecto); el lobo lo pone a `true` y `player._update_body_contact()` lo salta.
- `Player.parried(attacker)`: se emite al consumir la ventana de parry; el lobo se conecta una sola vez (grupo `player`, `_parry_connected`) y, si el atacante es él, entra en `STUN` con `parry_stun_time` 0.8 s, destello azulado y sin daño de contacto; en el aire espera a aterrizar y luego vuelve al aviso.
- `charge_speed` 150 → 140: sigue superando el paseo (130) y queda por debajo del sprint (221).
- Verificado headless (script desechable borrado): parry de otro atacante no aturde, parry propio → `state=5` (STUN) 0.8 s, luego vuelve a embestir, `_contact_cooldowns` del jugador vacío con el lobo encima y `charge_speed=140`. `--check-only` en player/enemy_base/werewolf con exit 0. F5 pendiente.

## 2026-11-13 · `buffy` · Cimas blancas en la montaña nevada (T-0063)

- Ruben: en el bioma nevado la cima del fondo se oscurece en vez de verse blanca.
- Causa: `mountains/Sprite2DSnow` (`mountain2_snow.png`, la capa de nieve) no estaba en ninguna lista de tinte y su textura es blanco sucio (≈ 184, 172, 171) sobre un risco teñido de `rock_color` 0.75; el modulate solo multiplica, así que ningún tinte normal la aclaraba.
- Nuevo canal `Biome.snow_color` (blanco por defecto) + `snow_tint_paths` (`../mountains/Sprite2DSnow`) aplicado en `_update_biome_tint()` junto a forest/rock/base.
- `nieve.tres`: `snow_color = (1.55, 1.6, 1.65)` (por encima de 1, empuja la capa a blanco puro) y `rock_color` 0.75 → `(0.92, 0.94, 0.98)`.
- Antes de tocar código compuse las tres capas en PIL para comparar variantes (actual / roca clara + nieve al 150 % / todo a blanco); se eligió la intermedia.
- Verificado headless (script desechable borrado): `snow_color=(1.55, 1.6, 1.65)`, `Sprite2DSnow` dentro de `_snow_tint_nodes` y el canal `"snow"` devolviéndolo; `--check-only` en world_generator/biome exit 0. F5 pendiente.

## 2026-11-13 · `buffy` · La capa de nieve no era la cima entera (T-0063, 2.ª pasada)

- Ruben: `mountain2_snow.png` estaba mal; la cima tiene dos colores y la imagen solo recogía el brillo (el más pequeño).
- Paleta real de `mountain2.png`: roca en tres tonos — brillo `184, 172, 171` (5.944 px), cara iluminada `161, 148, 147` (20.474 px) y cara de sombra `107, 108, 122` (13.136 px) — más dos teales de vegetación (`45, 80, 82`, `40, 61, 67`).
- La nieve antigua solo tenía el brillo. Regenerada con los tres tonos: blanco puro, `222, 230, 242` y `150, 162, 180`; la vegetación queda fuera (alpha 0). 39.554 px frente a 5.944.
- Con tres tonos, subir el modulate por encima de 1 los aplasta a blanco: `nieve.tres` pasa a `snow_color = (1, 1, 1, 1)` y el valor por defecto de `Biome.snow_color` es `(1, 1, 1, 0)` para que solo el bioma nevado muestre la capa (antes el prado y el bosque rojo tenían manchas blancas sueltas).
- Comparadas dos variantes compuestas en PIL (dejar la cara de sombra como roca vs. cubrirla); se elige cubrirla: es la lectura de "la cima entera" y la que pedía Ruben.
- Verificado: asset con los tres tonos en el PNG y en la textura importada, `--check-only` en `world_generator.gd`/`biome.gd`. F5 pendiente.

## 2026-11-13 · `buffy` · La cima conserva su color fuera de la nieve (T-0063, 3.ª pasada)

- Ruben: en los biomas no nevados la cima debe parecerse al color original de la imagen, con un mini toque del color de cada bioma.
- La capa de nieve se pintó blanca, así que hay que devolverle el tono del arte con el modulate: `Biome.snow_color` por defecto `(0.72, 0.66, 0.65)` multiplica los tres blancos y deja ≈ `184, 168, 166` donde el arte tenía `184, 172, 171`.
- `pradera.tres` `(0.715, 0.675, 0.625)` (verde tenue) y `bosque_rojo.tres` `(0.74, 0.65, 0.625)` (cálido tenue); `nieve.tres` sigue en `(1, 1, 1)`.
- Medido sobre los tres tonos con PIL: peor delta en prado y bosque rojo 12/255 (4,7 %); en nieve 98/255 (38 %), que es justo el salto a blanco.
- Verificado headless con script desechable (canal `snow` de los tres `.tres`) y `--check-only` en world_generator/biome. F5 pendiente.
- Confirmado con un probe que renderiza de verdad (captura del viewport, no `--headless`): el brillo del blanco con `snow_color = (0.72, 0.66, 0.65)` sale `184, 168, 166` en pantalla. El modulate multiplica en sRGB, así que la reconstrucción del tono original es exacta en la práctica y no hay que corregir por espacio de color.

## 2026-11-13 · `buffy` · El lobo se congela y siempre repite embestida (T-0064)

- Ruben: el lobo se queda quieto para siempre tras perseguirte; y al salir del stun debería poder correr o saltar.
- Causa: el `match _state` de `_update_behavior()` no tenía rama `RECOVER`; `_process_recovery()` existía pero nunca se llamaba, así que tras la primera embestida o salto el estado se quedaba congelado y su temporizador (el que devuelve a `WINDUP` o a vagar) no corría nunca.
- Arreglo: rama `State.RECOVER` añadida al `match`.
- Stun: `stun_jump_chance` 0.5 y `_stun_next_attack` (-1 ciclo normal, 1 embestida, 2 salto) que `_launch_attack()` consume una vez; se limpia al volver a vagar. Antes el final del stun siempre reembestía porque el contador 2 + 1 no cuenta el stun.
- Verificado headless: `RECOVER` a 0 pasa a `WINDUP`, 40 stuns reparten 16 embestidas / 24 saltos, y la intención forzada acaba en `CHARGE`/`JUMP`. `--check-only` sin errores; F5 pendiente.

## 2026-11-13 · `buffy` · Catálogo de enemigos e items con estado y skills (T-0065)

- Ruben: faltaba una vista de conjunto de enemigos (drops con probabilidad, stats, mecánicas)
  y de objetos, con una casilla de estado y fichas detalladas conectadas entre sí.
- Nuevo `vault/enemies.md` (lista de los 8) + `vault/enemies/<slug>.md` (stats base → finales,
  IA, tabla de drops con enlace al objeto, spawn y checklist de F5). Todos en `por revisar`;
  fantasma y demonio marcados como inalcanzables.
- Nuevo `vault/items.md` (44 objetos) + `vault/items/<slug>.md`, generados desde `resources/*.tres`
  y los `item_drops` de las escenas: 9 consumibles, 35 pasivas, 17 con drop. Todos en
  `por asignar textura` (el icono existe, es provisional). Totales: orco 42 %, lobo/rana/slime 32 %.
- Skills `estado-enemigos` y `estado-items` en `.opencode/skills/` con el vocabulario de estados,
  dónde mirar, cuándo actualizar y trampas; `.agents/skills/` tiene la entrada para Freebuff.
- Trampa del generador: en `[ext_resource ... uid="uid://..." path="..." id="..."]`, el regex
  `id="..."` casa también dentro de `uid="..."`; hay que anclar con `\bid=`. Con eso se resolvieron
  los 44 iconos y las 4 tablas de loot (antes salían `1_tex` y faltaba Wolf Fang).
- Sin cambios de código ni de escenas; verificación de enlaces y conteos, sin F5.
