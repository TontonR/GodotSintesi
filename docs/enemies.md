# Enemigos — `EnemyBase`, fantasma, orco, lobo, sapo y demonio

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

## Lobo, sapo y demonio (2026-11-01, rama `feat/biomas`)

- Traídos de `origin/feat/enemigos-demon-toad-werewolf` sin su generador ni su `player.gd`.
- **Lobo** (`werewolf`): 60 de vida, merodea su chunk (`chunk_width_tiles`), embiste de punta a punta del área de detección; cada 2 embestidas la siguiente vuelta es un salto con daño doble. El primer golpe de cada embestida lanza al jugador (`knockup`).
- **Sapo** (`mutant_toad`): salta en arcos altos; cada 3 aterrizajes lanza una ráfaga de 3 proyectiles destructibles (`toad_projectile`, un golpe basta).
- **Demonio** (`demon`): vuela 80 px sobre el spawn y cada 3 s se para sobre el jugador para escupir fuego (`demon_fire`, área que se alarga hasta el suelo). Si el jugador lo bloquea, queda aturdido 5 s o hasta 3 golpes.
- Estos tres piden al jugador `take_damage_from(..., knockback, knockup)` e `is_guarding()`; ver `docs/player.md`.

## Colisiones (pass-through)

- El jugador (`collision_mask` 1) y los terrestres orco/lobo/sapo (`collision_mask` 1) solo chocan con el mundo: se atraviesan entre ellos, no se puede subir encima ni empujar. El daño va por `Area2D`, no por cuerpo.
- El fantasma y el demonio ya tenían máscara 0.

## Trampas

- Un override vacío de `loot_table` en la escena dejaba al fantasma sin drops (ya eliminado).
- Los enemigos nuevos se escribieron contra el generador viejo de zonas: solo el lobo leía la configuración del mundo, y ya usa `chunk_width_tiles`.
