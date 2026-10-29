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
- Loot: `loot_table` da 1–3 monedas garantizadas y un `ItemPickup` al 75%; asignar el item antes de `add_child`, parentar y luego fijar `global_position` para respetar el transform del chunk.

## Fantasma

- `charge_time` 0.4, `tp_cooldown` 8.0, `tp_zone_margin` 10, `tp_min_travel` 80, `tp_attempts` 12, invulnerable durante el TP.
- TP al anillo elíptico entre `flee_range` y `attack_range`, nunca por encima del jugador (`offset.y = minf(offset.y, 0.0)`); sin `post_attack_tp_delay`.

## Trampas

- Un override vacío de `loot_table` en la escena dejaba al fantasma sin drops (ya eliminado).
