# Enemigo: Sapo mutante (`mutant_toad`)

Última actualización: 2026-10-22

## Dónde está

- Escena: `scenes/enemies/mutant_toad.tscn`
- Script: `scripts/enemies/mutant_toad.gd` (`class_name mutant_toad`, extiende `EnemyBase`)
- Proyectil: `scenes/enemies/toad_projectile.tscn` + `scripts/enemies/toad_projectile.gd`
- Sprites: `assets/enemies/mutant-toad/Spritesheets/` (idle 4, jump 4, attack 3; miran a la derecha)
- Sheet del proyectil: `assets/enemies/All_Fire_Bullet_Pixel_16x16_03.png`, fila 18 (y=288), columnas 11-16

## Comportamiento

Máquina de estados propia `IDLE / JUMP / ATTACK`; no usa el flujo de ataque de
`EnemyBase` (no hace daño por contacto).

1. **IDLE**: espera entre `jump_wait_min` y `jump_wait_max`; mira al jugador si
   está detectado.
2. **JUMP**: salto alto (`jump_force` -420) hacia el jugador si está detectado;
   sin jugador salta en dirección aleatoria dentro de `wander_radius` del spawn.
   `hop_speed` 150, sprite con la animación `jump` sin loop.
3. **Cada 3 aterrizajes**: reproduce `attack` y durante `shoot_delay` (0,7 s)
   parpadea con `windup_tint` (verde amarillento) para avisar; después lanza la
   ráfaga. Ya **no deja charcos tóxicos** (eliminados por completo).
4. **Ráfaga**: `projectiles_per_volley` (3) proyectiles apuntando al jugador con
   desviación aleatoria de ±`projectile_spread_degrees` (12°). Si el jugador ya
   no está detectado, no dispara.

## Proyectil

- `Area2D` en capa 8 / máscara 2: detecta al jugador y a la vez es detectado por
  los hitboxes de ataque del jugador (su máscara 12 incluye la capa 8).
- Animaciones: `inicial` (2 frames, no loop) → `active` (2, loop) →
  `disappear` (2, no loop) al impactar, expirar o recibir un golpe.
- `take_damage()` destruye el proyectil de un golpe (por eso el sapo lanza 3).
- Vida máxima `lifetime` 4 s.

## Integración

- `world_generator.gd`: añadido a `enemy_scenes` con 1 por zona.
- Capas del cuerpo: 4/3 (enemigo). Tamaño del sprite: escala 0.6.
- Sin colisión física con el jugador (`add_collision_exception_with` mutuo);
  conserva la colisión con el mundo y las Area2D de detección/daño.
