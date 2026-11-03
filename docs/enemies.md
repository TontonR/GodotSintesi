# Enemigos — `EnemyBase`, fantasma y orco

_2026-10-20 · 2026-10-25 · rama `feat/skills-and-complex-passives`_

## Qué hace y dónde vive

- `scripts/enemies/enemy_base.gd` (`CharacterBody2D`) + hijos `ghost.gd` (volador, ranged, TP) y `orc.gd` (melee). Escenas en `scenes/enemies/`.
- `orc.tscn` y `ghost.tscn` tienen `scale = (2, 2)` en la raíz: sprite, collider y áreas al doble. El generador apoya la base del collider en el suelo (`_body_bottom`), no el origen, más `spawn_y_offset` (el fantasma sube 6 px porque su cola dibuja por debajo del collider).
- Detectan al jugador por el grupo `player`.
- IA por prioridad: huir > atacar > perseguir. Los hijos sobrescriben `_update_behavior`, `_start_attack`, `_perform_attack`, `_on_death`.

## Exports de la base

- Basic: `max_health` 10, `base_attack` 5, `base_defense`, `knockback_defense`, `speed_movement` 50, `attack_cooldown` 2.
- Config: `flying_enemy`; `step_height` 16 (auto-subida de 1 tile, mismo criterio que el jugador: mira por delante y sube 17 px); `spawn_y_offset` (px que se sube al aparecer); `ranged_enemy` + `projectile` (¡no `projectile_scene`!) + `projectile_speed` / `projectile_damage` / `projectile_spawn`; `flee_enemy` + `flee_area`.
- Ataque: `attack_impact_delay` 0.5, `attack_duration` 1.0.
- Loot: `loot_table` la monta `_build_loot_table()`: moneda al `coin_drop_chance` 45 % (`coin_drop_amount` 1) y un `ItemPickup` con el pool del enemigo al `item_drop_chance` 30 %. Asignar el item antes de `add_child`, parentar y luego fijar `global_position` para respetar el transform del chunk.

## Fantasma

- `charge_time` 0.4, `tp_cooldown` 8.0, `tp_zone_margin` 10, `tp_min_travel` 80, `tp_attempts` 12, invulnerable durante el TP.
- TP al anillo elíptico entre `flee_range` y `attack_range`, nunca por encima del jugador (`offset.y = minf(offset.y, 0.0)`); sin `post_attack_tp_delay`.

## Trampas

- Un override vacío de `loot_table` en la escena dejaba al fantasma sin drops (ya eliminado).

## Dificultad y densidad (2026-11-03, T-0020)

- `EnemyBase.health_multiplier` 1.35 y `attack_multiplier` 1.25 se aplican en `_ready()`
  sobre `max_health` / `base_attack` (los hijos fijan sus stats en `_init()` y las escenas
  pueden sobrescribirlos, así que el ajuste va al final). Una sola palanca para todos.
- Slime a `scale = Vector2(1.2, 1.2)`; el resto de los traídos siguen a ×2.
- Densidad: la base son 13 enemigos por chunk y `_enemy_count_multiplier()` reparte
  (6 en los chunks 0–1, 16 a partir del 8.º).
- Los enemigos se colocan en huecos iguales a lo ancho del chunk con un ruido de ±25 %
  del hueco (`_generate_chunk`), no con una X al azar por enemigo: así no se apelotonan.

## Enemigos del compañero (2026-11-03, T-0019)

Traídos de `origin/feat/enemigos-demon-toad-werewolf` con `git checkout`, sin merge
(el mundo por chunks y la cámara de `main` son posteriores a la rama).

- **Demonio** (`demon.gd`, `demon_fire.gd`): vuela ~80 px sobre el spawn, ciclo FLY 3 s →
  aviso → chorro 3 s con `RayCast2D` al suelo; 5 de daño cada 0.5 s. Si le paran el chorro
  con la guardia (`player.is_guarding()`) queda aturdido.
- **Sapo mutante / rana** (`mutant_toad.gd`): máquina `IDLE/JUMP/ATTACK` propia; salta y
  cada 3 aterrizajes lanza una ráfaga de 3 proyectiles destructibles.
- **Lobo** (`werewolf.gd`): merodea por la zona que le da el generador (grupo
  `world_generator`), 2 embestidas + 1 salto; usa
  `player.take_damage_from(..., knockup, knockup_lock, ...)`.
- **Slime** (`slime.gd`), **esqueleto** (`skeleton.gd`, primer golpe gratis) y
  **arquero** (`archer.gd`, `archer_projectile.gd`) son `EnemyBase` con stats en `_init()`.
- Registro: `WorldGenerator.enemy_scenes` / `enemy_counts_per_chunk` en el mismo orden,
  hoy base `[4 orcos, 2 ranas, 1 lobo, 2 slimes, 2 esqueletos, 2 arqueros]` y escalada
  por chunk (menos en los dos primeros, más cuanto más lejos).
- **Fantasma y demonio desactivados** (2026-11-03): fuera de `enemy_scenes`; quedan
  anotados en `WorldGenerator.DISABLED_ENEMY_SCENES` con su escena y su script intactos.
- `scale = Vector2(2, 2)` en la raíz de los seis (2026-11-03): se ven al doble y
  `_body_bottom()` ya multiplica por la escala, así que siguen apoyados en el suelo.
- Spawn: el chunk 0 **sí** genera enemigos, a partir de
  `safe_start_tiles + enemy_safe_gap_tiles` (50 + 20 tiles, ~300 px del spawn); antes el
  chunk 0 estaba vacío y el enemigo más cercano quedaba a media pantalla y pico.
- API nueva en `EnemyBase`: `apply_slow(multiplier, seconds)`, aviso `on_enemy_killed` a
  las pasivas del jugador y `loot_preset` / `loot_pool` / `item_drop_chance`.
- **Loot por enemigo**: `loot_preset` (`Ogro`, `Lobo`, `Rana`, `Slime`) monta la tabla en
  `_build_loot_table()`. La elección es con peso: `Normal` 1.0, `Raro` 0.25. Tablas en
  `vault/pasivas/`.
- El arquero no tiene pasivas todavía (la tabla venía vacía): usa el pool genérico.
