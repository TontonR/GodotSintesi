# Enemigos básicos: slime, esqueleto y arquero

Fecha: 2026-10-29

Los tres heredan de `EnemyBase`; no reimplementan detección, movimiento, ataque,
daño, loot ni muerte. Solo configuran stats/animaciones y su rasgo propio.

## Slime

- Script: `scripts/enemies/slime.gd` · Escena: `scenes/enemies/slime.tscn`
- IA mínima heredada: persigue y ataca cuerpo a cuerpo.
- 20 HP, 6 daño, 35 px/s, cooldown 1,8 s.
- Frames: `spritesheets/green/{idle,walk,attack_1}.png` (80×80).

## Esqueleto

- Script: `scripts/enemies/skeleton.gd` · Escena: `scenes/enemies/skeleton.tscn`
- Igual que el slime, pero el **primer golpe recibido hace 0 de daño**
  (`_first_hit_blocked`); el resto usa el daño normal de la base.
- 40 HP, 10 daño, 50 px/s, cooldown 2 s.
- Frames de `Skeleton enemy.png` (64×64): idle fila 3, walk fila 2, attack fila 0
  (frames 0–7).

## Arquero

- Script: `scripts/enemies/archer.gd` · Escena: `scenes/enemies/archer.tscn`
- `ranged_enemy = true`: se detiene al entrar el jugador en su rango (180 px) y
  dispara; detección de 260 px.
- 30 HP, 8 daño, 55 px/s, cooldown 2,2 s.
- Frames de `ArcherHero/Final/`: idle 2, walk 8, attack 11 (64×64).

## Proyectil

- Script: `scripts/enemies/archer_projectile.gd` · Escena:
  `scenes/enemies/archer_projectile.tscn`
- `setup(direction, speed, damage, shooter)` para encajar con `EnemyBase`.
- Placeholder: flecha de `All_Fire_Bullet_Pixel_16x16_03.png`, región
  `Rect2(323, 260, 28, 9)`, con escala `0.6`; se rota con `direction.angle() + PI`.
- Daña al jugador y se libera al impactar o a los 4 s.

La carpeta `PixelRats_Free_Carysaurus` no se usa.

## Aparición en el mundo

`scripts/world_generator.gd` incluye las tres escenas al final de `enemy_scenes`,
con `enemy_counts_per_zone = [4, 1, 1, 1, 1, 2, 1, 1]`: los enemigos antiguos
siguen apareciendo y se añaden 2 slimes, 1 esqueleto y 1 arquero por zona.
