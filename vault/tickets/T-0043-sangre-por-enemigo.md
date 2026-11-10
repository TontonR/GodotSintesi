# T-0043 · Color de sangre por enemigo

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `baja` |
| Dueño | `buffy` |
| Sistema | enemies / fx |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-10 |
| Relacionado | T-0028, T-0031 |

## Problema

Todos los enemigos estallaban con el mismo rojo: `fx.enemy_death()` llevaba los cuatro
colores del estallido escritos a mano. Un slime, un esqueleto o un demonio no se podían
diferenciar por la sangre.

## Causa / contexto

`enemy_base.gd` llamaba a `fx.call("enemy_death", posición)` sin más, y `fx.gd` componía
jet oscuro, salpicadura, niebla y chispas como literales independientes.

## Plan

1. `fx.BLOOD_COLOR` (0.82, 0.11, 0.1) como rojo por defecto y parámetro opcional de
   `enemy_death(world_position, blood_color)`.
2. Derivar las cuatro capas de ese color: jet `darkened(0.4)`, salpicadura tal cual,
   niebla con alfa 0.55 y chispas `lightened(0.75)`.
3. `EnemyBase.blood_color` exportado (grupo `FX`) con el mismo rojo por defecto, pasado al
   `fx.call("enemy_death", ..., blood_color)` de `_die()`.
4. Documentar en `docs/fx.md` y `docs/enemies.md`.

## Criterios de aceptación

- [x] Cada escena de enemigo puede fijar su `blood_color` desde el inspector.
- [ ] Sin tocar nada, el estallido se ve como antes (rojo).
- [x] `docs/fx.md` y `docs/enemies.md` actualizados.
- [x] `changelog.md` y `estado.md` actualizados.

## Resultado

`scripts/fx.gd` y `scripts/enemies/enemy_base.gd`. Los literales de color desaparecen:
un solo export recolorea el estallido entero. Los `.tscn` quedan con el rojo por defecto,
así que el cambio se ve cuando se les asigna color. F5 pendiente.
