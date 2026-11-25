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

## 2026-11-13 · `buffy` · Biomas más cortos, estamina y monedas (T-0066)

- Ruben: biomas demasiado largos, estamina que se agota enseguida y monedas que
  aparecen bajo el suelo.
- Biomas: `min_biome_tiles` 1024 → 512 y `max_biome_tiles` 4096 → 2048 (de 4–16 a
  2–8 chunks); la transición de 256 tiles sigue cabiendo en el tramo mínimo.
- Estamina: carrera 7 + 6/s y guardia 10 + 12/s (antes 10 + 10/s y 15 + 20/s).
- Monedas: `coin.gd` lanza el rayo de suelo desde 64 px arriba, así un drop nacido
  dentro del tile detecta la superficie y sale; antes se asentaba enterrado.
- Docs `world`/`biomes`/`player`/`loot` actualizados. Sin Godot ni commit; F5 pendiente.

## 2026-11-13 · `buffy` · El salto no corta la carrera (T-0067)

- Ruben: saltar corriendo frenaba y al aterrizar se pagaba otra vez la entrada de carrera.
- `_update_stamina()` apagaba `_is_running` al despegar; sin el multiplicador, `move_toward`
  bajaba la X a 130 en el aire, y la rama de entrada volvía a cobrar `run_initial_cost`.
- Ahora la carrera solo se corta al soltar Shift, guardar, atacar o quedarse sin estamina;
  el drenaje sigue en el aire. Docs de player al día. Sin Godot; F5 pendiente.

## 2026-11-13 · `opencode-jorge` · Iconos de consumibles y tiers de pociones (T-0069)
- Ruben confirma el mapa de sprites y pide aplicar el rework: vida/estamina en 20/50/100.
- 9 `.tres` de consumibles actualizados (nombre, efecto, icono, `id`); `Vital Essence` pasa a `Vigorizing Pie` y `Mucus Heart` a `Mucus Essence`.
- Rutas de `.tres` intactas para no romper saves; `pocion_mocos` usa `assets/items/Icon19.png` (aun sin `.import`).
- `docs/items.md` y preview `docs/pociones-antes-despues.png` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-13 · `opencode-jorge` · Iconos de pasivas pendientes (T-0070)
- Ruben pide asignar sprites parecidos a las 34 pasivas que seguian con iconos provisionales o genericos.
- Cada pasiva usa un `assets/items/item###.png` distinto: amuletos con colgante, anillo, armaduras, botas, garras, etc.
- `Focus` no existe y no se crea; `Third-Hit Projectile` no estaba en la lista y conserva `magicW`.
- `docs/items.md` y preview `docs/pasivas-antes-despues.png` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-13 · `opencode-jorge` · Correcciones de iconos de pasivas (T-0071)
- Ruben corrige T-0070: Light Armor `item221`, Heavy Armor `item226`, Greed `item169`, Wolf Fang `Icon34`, Iron Heart `item199`, Wolf Claws `Icon12`, Mucus `item310`, Wolf Pelt `item202`, Light Feet `item276`.
- `cazador` pasa a `Hunter's Faith`; `pulso_vampirico` pasa a `Sanguine Ruby` con `Icon29` copiado a `sanguine_ruby.png`.
- `docs/items.md` y preview `docs/pasivas-cambios-2026-11-13.png` actualizados. F5 pendiente; ticket en `revision`.

## 2026-11-17 · `opencode-jorge` · Sincronizar el vault tras el F5 (T-0068)

- Ruben probó durante días todo lo que estaba en `revision` y funciona. Cierro los 52
  tickets verificados, T-0001 como absorbido y T-0002 como descartado (no hay skills).
- Corrección de diseño: inventario = consumibles (1/2/3, ampliables) + coleccionables con
  pasiva siempre activa o condicional; **no hay armas ni las habrá**.
- `ideas.md`, `docs/items.md`, `roadmap.md` y `estado.md` al día. `mutant_toad.tscn`
  revertido y `.obsidian/` ignorado.
- Sin Godot ni commit: solo docs y `.gitignore`. T-0068 queda en `revision`.

## 2026-11-17 · `opencode-jorge` · Inventario legible y slots fijos (T-0072)

- Ruben: el inventario es feo, el texto del objeto es enorme y con textos largos el HUD
  se estira; los slots de consumibles se adaptan a la textura y debería ser al revés.
- `inventory_screen.tscn`: fuentes 20/18/18 -> 15/12/12, cabeceras 13, página 11, icono
  de preview 128 -> 96 y `clip_text` en la descripción (su altura mínima empujaba la
  ventana de 248 a 404 px).
- `inventory_slot.tscn`: `expand_icon = true`; fuera el `expand_icon` que ponía
  `inventory_screen.gd` a mano. Comprobado headless: 32×32 y 16×16 dan slot 18×18 (HUD) y
  40×40 (inventario).
- `vault/items/*.md`: tabla de valores regenerada desde los `.tres` (había fichas con los
  valores viejos de poción) y el pendiente de textura pasa a icono asignado + F5.
- `docs/ui.md` y `vault/items.md` al día. Sin F5.

## 2026-11-17 · `opencode-jorge` · Editor web de objetos (T-0073)

- Ruben: programa HTML para ver y editar `vault/items`; landing con los 44, editor de
  nombre/habilidades/textura y filtro por estado; al guardar debe quedar claro que el
  cambio no está en el juego.
- Servidor local `vault/items-editor/server.py` (stdlib, 127.0.0.1) con `/api/items`,
  `/api/items/<slug>` (GET/POST) y `/assets/` para los iconos; front en HTML/CSS/JS sin
  dependencias.
- Guardar reescribe ficha y catálogo, pone el estado `en proceso` y añade el pendiente
  "Aplicar los cambios de esta ficha en el `.tres` y en el juego"; el `.tres` no se toca.
- Probado con `--root` sobre una copia: carga de 44 objetos, 6 estados, guardado y
  formateo del pendiente. UI sin abrir en navegador.

## 2026-11-17 · `opencode-jorge` · Editor de objetos arreglado (T-0073)

- Ruben: el editor "parece que el CSS no carga" y no se ven las imágenes. Causa real: el
  servidor mandaba `style.css` y `app.js` como `text/plain` (el navegador descarta la hoja
  de estilos) y las filas del catálogo pedían `/items/x.png` en lugar de `/assets/items/x.png`.
- Servidor: MIME por extensión, rutas relativas en `index.html`, `/style.css` y `/app.js`
  también en la raíz (así se ve algo aunque se abra el fichero a pelo).
- Datos: la landing ahora sale de `vault/items/*.md`, con el catálogo solo como respaldo
  para filas sin ficha; `?slug=` y visor del `.md` guardado; el selector de estado arranca
  en `en proceso`.
- Comprobado con Chrome headless sobre el repo real: 44 objetos, 44 iconos a 200 y CSS
  `text/css; charset=utf-8`.

## 2026-11-17 · `opencode-jorge` · Editor: estado real y valores avanzados (T-0073)

- Ruben: el estado aparece siempre "en proceso" y no tiene sentido editar valores del
  `.tres` en el editor (los `.tres` son del juego).
- Estado: fuera el desplegable que arrancaba en `en proceso`; ahora se pinta el estado
  real de la ficha y el servidor fuerza `en proceso` al guardar.
- Valores del recurso: dentro de "Opciones avanzadas" (cerrado), con nota de que son la
  tabla copiada de la ficha y que el editor no lee el `.tres`.

## 2026-11-17 · `opencode-jorge` · Editor: alta/borrado, estado y pendientes (T-0073)

- Ruben: poder añadir y borrar objetos; el estado tenía que cargarse bien, no
  desaparecer; y un script de pendientes para que el agente sepa qué tocar en Godot.
- Estado: desplegable con el estado real de la ficha. Regla: si el contenido cambia y el
  estado no, se guarda `en proceso` (lo decide el cliente, el servidor obedece).
- Alta: plantilla de ficha (tipo consumible/pasiva, calidad, textura) + fila insertada en
  orden alfabético en `vault/items.md`. Borrado: ficha + fila; el `.tres` nunca se toca.
- `pendientes.py`: sin dependencias, importa el parseo del `server.py`, compara ficha y
  `.tres` y lista solo diferencias; probado con un `.tres` cambiado y con uno que falta.
- Descubierto y arreglado: `colgante_hierro.md` tiene la tabla alineada con espacios y el
  parser la dejaba vacía (el objeto no se podía editar).
## 2026-11-17 · `opencode-jorge` · Nuevos objetos de ideas.md (T-0054)
- Ruben aprueba las 4 tandas y los valores propuestos; `Fragmento` queda fuera.
- Se crean los 14 objetos de arquero, esqueleto, fantasma y demonio, con sistemas nuevos para arco, invulnerabilidad, teleport, saltos, rata y DOT.
- Se añaden al `item_drops` de `archer.tscn`, `skeleton.tscn`, `ghost.tscn` y `demon.tscn`.
- Ficheros: `scripts/collectables/*.gd`, `scripts/player.gd`, `scripts/enemies/enemy_base.gd`, `resources/*.tres`, `scenes/collectables/player_arrow.tscn`, escenas de enemigos y docs.

---

## 2026-11-17 · `buffy` · Abierto T-0074: estructuras por chunk

- Abierto [T-0074](tickets/T-0074-estructuras-por-chunk.md) a petición de Ruben: que se
  puedan **añadir estructuras** (como recurso `.tres` o escena) a un bioma y que el
  generador decida por chunk si salen, **con la semilla** como fuente del reparto.
- Rama `feat/estructuras-chunk` sale de `main`; de momento **solo el ticket**, sin código
  ni arte: el prototipo usará un placeholder cantoso.
- Ficheros previstos: `scripts/world/structure.gd` (nuevo), `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/structures/`, `docs/world.md`, `docs/biomes.md`.
- Dudas en el ticket: colisión (no en el prototipo), textura vs escena y estructuras que
  crucen chunks (fuera de alcance).

---

## 2026-11-18 · `opencode-jorge` · T-0074: estructuras por chunk implementadas

- Continúo el [T-0074](tickets/T-0074-estructuras-por-chunk.md) abierto por `buffy` a
  petición de Ruben: `WorldStructure` + 2 `.tres` de prueba con placeholder, roll por chunk
  con la semilla, colocación con márgenes/separación y el bioma decidiendo cuántas y cuáles.
- Ficheros: `scripts/world/structure.gd` (nuevo), `scripts/world_generator.gd`,
  `scripts/world/biome.gd`, `resources/world/structures/*.tres`,
  `assets/map/structures/*.png`, `resources/world/biomes/pradera.tres` y `bosque_rojo.tres`,
  `docs/world.md`, `docs/biomes.md`.
- Desvío: el número por chunk vive solo en el bioma (no en el recurso). Ticket en `revision`,
  pendiente de F5; sin commit todavía.

## 2026-11-18 · `opencode-jorge` · T-0074: una tirada por estructura (decisión de Ruben)

- Ruben cambia el modelo: **no** una estructura por chunk, sino una tirada
  independiente por estructura y chunk, con probabilidad por bioma. Un chunk puede no
  tener ninguna o tener todas, nunca dos de la misma.
- `Biome`: fuera `structures_per_chunk` y `structure_weights`, entra `structure_chances`.
  `WorldStructure` pierde `weight` (el bioma es la única fuente de probabilidades).
- Pradera torre 15 % / ruina 25 %, bosque rojo ruina 30 %, nieve nada.
- Se documentan en `vault/ideas.md` § 5.1 los tres tipos de estructura (sprite único,
  generación a bloques y explorable) con dificultad y estimación en horas.
- Ficheros: `scripts/world_generator.gd`, `scripts/world/biome.gd`, `scripts/world/structure.gd`,
  `resources/world/biomes/{pradera,bosque_rojo}.tres`, `resources/world/structures/*.tres`,
  `docs/world.md`, `docs/biomes.md`, ticket T-0074.

## 2026-11-18 · `opencode-jorge` · Super planning de estructuras y tienda al 2026-12-11

- Ruben recalibra estimaciones (sprite ~1 h, bloques 4–8 h, explorable 15–30 h) y fija el
  orden práctico: **tipo 2 (bloques) primero**, el tipo 1 cae de paso y el 3 se apoya en el 2.
- Reparto: **Rubén** estructuras y tienda; **Jorge** enemigos/objetos nuevos y arte
  (texturas y sonidos); agentes por ticket.
- Nuevo [`planning-estructuras.md`](planning-estructuras.md): tipos, calendario con hitos
  24 nov / 1 dic / 8 dic / 11 dic, backlog T-0075…T-0085 con estimaciones, ruta crítica,
  decisiones pendientes (tienda), recortes y definición de "hecho".
- Roadmap P1 lista los tickets previstos sin abrir; se crean al arrancar cada fase.

## 2026-11-19 · `opencode-jorge` · T-0075: estructuras por bloques (tipo 2)

- Primera prueba del tipo 2: `WorldStructure.pattern` (rejilla de `#`) pintada como
  bloques grises de prueba de 16 px, sin colisión, detrás del decor.
- `ruin_test.tres` pasa a patrón 8×5; cada columna apoya en su propio suelo, así que la
  ruina sigue el relieve en vez de flotar.
- Ficheros: `scripts/world/structure.gd`, `scripts/world/block_structure.gd` (nuevo),
  `scripts/world_generator.gd`, `resources/world/structures/ruin_test.tres`,
  `docs/world.md`. Ticket T-0075 en `revision`, sin commit.

## 2026-11-19 · `opencode-jorge` · T-0075: atlas claro/oscuro y bloques sólidos

- Arte propio en `assets/map/structures/ruin_tiles.png` (claro) y `ruin_tiles_dark.png`
  (oscuro, derivado ×0.38/0.44/0.52): 8×2 tiles de 16 px con variedad de tono y musgo.
- La ruina son dos capas: muro oscuro de fondo (`back_texture`, z −1, índice 0 del chunk)
  y pocos bloques claros delante (`tile_texture`, z 0, `front_chance` 0.12 en las 2 filas
  bajas) con `StaticBody2D` en la capa 1, una caja por tramo horizontal.
- `BlockStructure` pinta del atlas con índice por hash de celda (mismo en cada recarga) y
  usa tiles con musgo cuando no hay bloque encima. `block_color` queda de reserva.
- Generador: `vault/estructuras/make_tiles.py` (escribe los dos PNG y el preview).
- Sin commit; falta F5.

## 2026-11-19 · `opencode-jorge` · T-0075: texturas mate y sólidos solo en el suelo

- Texturas rehechas: mismo estilo de bloques + ladrillos que funcionaba, pero **mate**
  (fuera la línea de brillo) y con más color (piedra gris/fría/cálida/verde, ladrillo
  gris/cálido/frío/oscuro/con musgo, coronación de ladrillo con musgo). La pared usa
  sobre todo ladrillo; la piedra queda de acento.
- Generación: los bloques con hitbox ya no están en las 2 filas bajas al azar. Solo hay
  dos casos, ambos en la fila de suelo: piedras sueltas sobre un bloque de pared
  (`front_chance` 0.25) y vigas de soporte que rellenan los huecos bajo el muro
  (`support_chance` 0.6). Nada flota y todo se puede saltar.
- `BlockStructure.cell_tiles` permite fijar el tile por celda (la capa de delante elige
  entre piedra y viga); el muro sigue con hash de la celda y coronación con musgo.

## 2026-11-19 · `opencode-jorge` · T-0075: texturas según la referencia

- Atlases rehechos al estilo de la referencia: ladrillo teal muy oscuro con junta verde
  (dos variantes) y bloques de pizarra chunky en grande/largo/pequeño, claro/oscuro y con
  musgo. Sigue siendo mate.
- La pared es solo ladrillo; la fila de suelo del muro pinta piedra con musgo
  (`FOUNDATION_TILES`), como la franja de la referencia. Los sólidos de delante usan
  `STONE_TILES` y los soportes `SUPPORT_TILES`.
- `BlockStructure.cell_tiles` acepta -1 = elegir ladrillo por hash.

## 2026-11-19 · `opencode-jorge` · T-0075: fondo solo de ladrillo

- La pared de fondo ya no pinta piedra: todas las celdas son ladrillo (`WALL_TILES`);
  los bloques 8-13 (piedra grande/larga/pequeña, clara y oscura, con musgo) se quedan en
  el atlas y solo los usa la capa de delante con colisión.
- `_blocks_cells()` deja de devolver `cell_tiles` para el fondo; `FOUNDATION_TILES`
  eliminado. `BlockStructure.cell_tiles` sigue para la capa sólida.

## 2026-11-19 · `opencode-jorge` · T-0075: fuera decor dentro de ruinas y musgo por bioma

- `_decor_outside_structures()` descarta el decor que cae dentro de `x ± half` de
  cualquier estructura del chunk (se aplica después de tirar las estructuras).
- Cada estructura guarda un `tint` de `_decor_tint_at()` y pinta sus atlas con
  `_tinted_texture(source, tint, 24, 12)`; `_tint_foliage()` gana umbrales opcionales
  para no teñir la junta teal del ladrillo y dejar el musgo con el color del bioma.
  Resultado cacheado en `_decor_tint_cache`.

## 2026-11-19 · `opencode-jorge` · crash al abrir el mundo (game.tscn con exports null)

- `scenes/game.tscn` había quedado reserializado por el editor con **todas** las
  propiedades del `map` (y de los demás nodos con script) a `null`, incluido
  `chunk_scene = null`, así que `_load_chunk()` llamaba `instantiate()` sobre null.
  El diff era solo líneas `= null`: restaurado con `git checkout -- scenes/game.tscn`.
- Comprobado en headless (`godot --headless --path . res://scenes/game.tscn`) sin
  errores, y otra pasada forzando `pradera` a 100 % de ruina (después revertido) para
  ejecutar el camino de estructuras y el tintado del musgo.

## 2026-11-19 · `opencode-jorge` · T-0075: ruinas como TileSet editable

- `BlockStructure` pasa de `Node2D` con `_draw()` a **`TileMapLayer`**: la textura y la
  colisión ya no se calculan por código, se editan en el editor.
- Nuevo `resources/world/structures/ruin_tileset.tres` con dos fuentes: 0 = atlas oscuro
  (muro, sin física) y 1 = atlas claro (piedras del suelo). La física de la fuente 1 está
  en los tiles 8, 9, 11 y 12 (capa 1); el resto no tiene hitbox.
- `WorldStructure` cambia `tile_texture`/`back_texture`/`block_color` por un único
  `tileset`; `ruin_test.tres` apunta al nuevo recurso.
- El tintado del musgo se aplica duplicando el TileSet (`_structure_tileset()`), así que
  los polígonos de colisión se conservan.

## 2026-11-24 · `opencode-jorge` · Reparto de agentes y T-0076 (cajas rompibles)

- Ruben reparte el trabajo: opencode (planning + testeo + cajas rompibles), Freebuff
  (estructura explorable, T-0079) y PixelForge (arte, T-0086). Yo dirijo a PixelForge.
- Reclamo **T-0076** (fase A del planning): cajas de madera dentro de las ruinas con
  vida, drop de monedas y estado "ya roto" persistido.
- Ficheros: `scripts/world/breakable_block.gd` (nuevo),
  `scenes/world/breakable_block.tscn` (nuevo), `scripts/world_generator.gd`,
  `docs/world.md`.
- Arte definitivo: PixelForge (T-0086); de momento un placeholder de 16×16.

## 2026-11-24 · `opencode-jorge` · T-0076 hecho (revision) y prompt para PixelForge

- Cajas rompibles en las ruinas: `BreakableBlock` (40 de vida, 1–3 monedas, señal
  `broken`), colocadas por `_crate_tiles()` (chunk 0 fuera) y persistidas en
  `world/broken` (`save_game.gd` guarda y carga la clave).
- Comprobado en headless (semilla 775344231, chunks 1–40): 18 cajas en 10 ruinas, 0 mal
  colocadas; la ruta real de spawn monta la caja en su fila de suelo (chunk 4);
  `scenes/game.tscn` arranca 180 frames sin errores.
- Abierto **T-0086** para las texturas de caja de PixelForge; el prompt va aparte y el PNG
  entra por mí. F5 pendiente.

## 2026-11-24 · `buffy` · T-0079 interior explorable (MVP)

- Abierto T-0079 y rama `feat/estructura-explorable` desde `main` `ccbae38` en un worktree
  aparte: el checkout compartido tiene T-0076 de `opencode-jorge` sin commitear y no se ha
  tocado.
- Mazmorra autónoma nueva: 2 pisos con semilla, salas de anchos variables separadas por
  muros con puerta,
  `spawn_point`, `exit_requested` y `save_state()`/`load_state()` puros (`{seed, floor}`).
- Ficheros: `scripts/world/dungeon_generator.gd`, `scripts/world/dungeon_test.gd`,
  `scenes/structures/dungeon.tscn`, `scenes/structures/dungeon_test.tscn`,
  `docs/dungeon.md`, `AGENTS.md`, `vault/tickets/T-0079-interior-explorable.md`.
- Pendiente: la puerta mundo→mazmorra (hija + mundo oculto, o `change_scene` + autoload) y
  el estado por piso, para T-0080. F6 de Ruben sobre `dungeon_test.tscn`.

## 2026-11-24 · `buffy` · Entrada a la mazmorra desde el mundo (T-0087)

- Puerta negra placeholder (`scenes/structures/dungeon_entrance.tscn`) repartida por
  `WorldGenerator`: una fija junto al spawn del chunk 0 y una tirada por chunk (0.2),
  después de enemigos, monedas y decor para no mover sus posiciones.
- F sobre el área entra: `DungeonLayer` (`scenes/game.tscn`) oculta y pausa `map`,
  instancia `dungeon.tscn` y la salida devuelve al jugador al mismo punto, sin recargar
  la escena (vida, monedas, inventario y semilla se conservan).
- Ficheros: `scripts/world/dungeon_entrance.gd`, `scripts/world/dungeon_layer.gd`,
  `scenes/structures/dungeon_entrance.tscn`, `scripts/world_generator.gd`,
  `scenes/game.tscn`, `docs/dungeon.md`, `vault/tickets/T-0087-entrada-mazmorra.md`.
- Pendiente F5/F6 de Ruben; guardar dentro de la mazmorra sigue siendo T-0080.

## 2026-11-24 · `buffy` · Fusión de estructuras y arte de la mazmorra (T-0088)

- Creada `test/fusion-structure` desde `main`: merge `--no-ff` de `feat/bloques-rompibles`
  (T-0074/T-0075/T-0076) y `feat/estructura-explorable` (T-0079/T-0087); conflictos en
  `world_generator.gd` (se conservan estructuras, cajas y puertas) y en bitácora/changelog/estado.
- La mazmorra abandona `ground_tile.png`: fondo, techo y muros con ladrillo de ruinas
  (`ruin_tiles_dark.png`) y suelo de piedra (`ruin_tiles.png`), del mismo atlas 8×2 que las
  estructuras; física de cuadro completo en suelo/muros y `Back` sin colisión.
- Pendiente F5 de Ruben; no hay Godot CLI en la sesión.

## 2026-11-24 · `buffy` · Bugs de la fusión (T-0088)

- `DungeonLayer` solo ocultaba/pausaba `map`, pero la colisión de los `TileMapLayer` sigue
  activa; la mazmorra pasa a `WORLD_OFFSET` (y −10000) y el jugador se teletransporta allí.
- `ruin_tileset.tres`: la piedra clara 8 (0:1) ya tiene cuadro completo de colisión, así que
  las piedras del frente son sólidas. `_structure_allowed()` descarta patrones sin `tileset`
  y las piedras del frente se mueven al índice 0 (detrás del decor).
- `docs/world.md`/`docs/dungeon.md` corregidos; F5 pendiente (sin Godot CLI).

## 2026-11-24 · `buffy` · Interior de castillo y salida de la mazmorra (T-0089, T-0090)

- T-0090: `assets/map/structures/castle_tiles.png` (atlas 8×6 de 32 px del `map.zip`)
  repinta el interior: piedra en `Back`, ladrillo en `Walls`/techo, piedra en `Floor` y
  ventanas/estandartes en la capa nueva `Decor`. `TILE_SIZE` 32, 75×6 tiles, puerta de 4
  tiles y pad de 32×64 px. El `.tres` del pack no trae colisión: el TileSet se sigue
  construyendo en código y todas las celdas sólidas la reciben.
- T-0089: la salida calculaba los chunks con la cámara suavizada, que sigue en la
  mazmorra tras el teletransporte. `_update_chunks()` pasa a usar la X del jugador en ese
  caso. Medido en headless a 200 000 px: 49 chunks (0..48) → 5 (140 ms).
- Comprobado en headless: 0 tiles de muro/suelo sin colisión, 42 celdas de decor y 9 ms
  por las dos plantas. Falta F5/F6 de Ruben: aspecto del castillo y salida lejana.

## 2026-11-24 · `buffy` · Mazmorra del castillo como hall de plataformas (T-0093)

- `scripts/world/dungeon_generator.gd`: sala plana sustituida por hall de 7/9 tramos en
  filas 32–34, huecos de 2–3 tiles con repisa y escalón, losas sobre huecos anchos y ruta
  alta en la sala central; fondo de piedra hasta el marco con fosas de vacío recortadas.
- El remate del suelo pasa del tile de techo `24` al `18` para que la superficie no
  muestre la franja de vacío. Ventanas cada 5 tiles y estandartes al 25/50/75 %.
- Verificado con harness de renderizado (KP3 → F, semilla `20261124`, plantas 0/1) y
  capturas `vault/estructuras/platform_f0_*.png` / `platform_f1_*.png`; falta F5/F6.

## 2026-11-24 · `buffy` · T-0093 segunda pasada: sala de referencia y responsabilidades

- Rehecha la mazmorra como una sola sala de 34 × 22 (tres bloques de suelo, dos fosas,
  8 ventanas, 2 estandartes y 3 plataformas de madera), con el fondo de piedra claro.
- `scripts/structures/castle/`: `CastleLayout` (datos), `CastleTiles` (atlas/colisión),
  `CastlePainter` (capas) y `DungeonGenerator` (ciclo); `WorldGenerator`/`WorldStructure`
  intactos. La capa de madera pasa de `Floor` a `Platforms` con colisión fina one-way.
- Probe headless KP3 → F, semilla `20261124`, plantas 0/1, sin errores de script; capturas
  `hall_spawn`, `hall_overview`, `hall_left_platform`, `hall_center_floor`, `hall_f1_spawn`.
  Falta F5/F6 de Ruben.

## 2026-11-24 · `buffy` · T-0093 paredes/suelo del castillo

- Corregidas las esquinas con las piezas reales del atlas: marco y suelo
  comparten borde `20/24/19/22` y esquinas `18/21/26/23`; el canto claro queda
  fuera del ladrillo, como en la referencia.
- `resources/shaders/castle_cutout.gdshader` descarta el púrpura `#423a51`;
  `Back` deja de pintar el tile `25` y `DungeonVoid` da el negro exterior y de
  las fosas.
- Chequeo headless del castillo: marco/esquinas, fosas/exterior y materiales
  correctos; captura visual del hall completo revisada. F5/F6 pendientes.

## 2026-11-24 · `buffy` · T-0093 corrección de orientación y fondo

- Solo el marco que rodea la sala vuelve al canto interior: borde `24/20/22/19`
  y esquinas `28/29/27/30`. Los bloques de suelo conservan `20/24/19/22` y
  `18/21/26/23`.
- El fondo normal era el `Parallax2D` del mundo (`z = -100`), no generación de
  chunks: `DungeonLayer` ya los descarga. `DungeonVoid` pasa de CanvasLayer a
  `Polygon2D` en `z = -5`, encima del parallax y debajo de `Back`.
- Probe con un fondo falso magenta en `z = -100`: el hall sale con negro y no se
  ve magenta. Frame IDs y `VOID_BACKDROP` correctos; exit 0. F5/F6 pendientes.

## 2026-11-24 · `buffy` · T-0093 fondo original, sin shader

- El PNG de `castle_tiles.png` no se ha modificado. El degradado/segundo negro
  venía de `castle_cutout.gdshader`, que convertía el púrpura del atlas en
  transparencia y dejaba ver otro fondo; se elimina el shader y sus materiales.
- `DungeonVoid` usa el púrpura original `#423a51` en un `Polygon2D` z=-5. Los
  bordes de suelo y marco conservan su interior original, como el borde del mapa.
- Probe con parallax falso magenta: el fondo no se cuela. Sin material en las
  capas; frame IDs correctos; exit 0. F5/F6 pendientes.

## 2026-11-25 � `opencode-jorge` � Revisi�n de T-0093 y T-0080 persistencia por piso

- T-0093 (de `buffy`): revisada y verificada en headless con Godot 4.7.2 (semilla
  `20261124`, plantas 0/1): colisi�n completa en `Walls`, `Platforms` one-way, layout
  determinista y distinto por planta, `game.tscn`/`dungeon_test.tscn` sin errores.
  Corregidos el comentario muerto del shader y el F6 (`UILayer` en `dungeon_test.tscn`).
- T-0080 abierto y hecho: `DungeonLayer.save_state()/restore_from_save()`, secci�n
  `[dungeon] state` en `save_game.gd` y llamada en `game.gd`. Guardar dentro del
  castillo conserva planta, posici�n y punto de vuelta; `run/position` y metros pasan a
  ser del mundo. Verificado headless con un probe desechable (slot 3 borrado al acabar).
  Ficheros: `scripts/world/dungeon_layer.gd`, `scripts/save_game.gd`, `scripts/game.gd`,
  `scenes/structures/dungeon_test.tscn`, `scripts/structures/castle/castle_tiles.gd`,
  `docs/dungeon.md` y `vault/`.
