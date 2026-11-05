# T-0029 · Polvo a ras de suelo, sangre grande y moco por toda la hitbox

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `fix` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx/player |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0028 (FX), T-0027 (partículas de bioma) |

## Problema

- El polvo de saltar, aterrizar y correr salía a la altura del ombligo, no del suelo.
- El moco salía de un punto en el centro del jugador en vez de toda la hitbox.
- La muerte de un enemigo era un estallido pequeño (18 + 6 partículas) poco vistoso.

## Causa

- `player._dust_at()` usaba offset `(0, -2)` y el origen del cuerpo está a media altura (la hitbox mide 16×54 px centrada).
- `moco_emitter.gd` usaba `EMISSION_SHAPE_SPHERE` con radio 8 y `position = (0, 8)`.
- `fx.enemy_death()` lanzaba dos estallidos de 150/90 px/s y escalas 1,4/1,0.

## Plan

1. `_feet_offset()` en el jugador deriva la mitad inferior de `CollisionShape2D` y las tres llamadas de polvo emiten ahí.
2. `MocoEmitter` emite en caja de 14×48 px centrada en la hitbox.
3. `enemy_death()` con cuatro capas de sangre (chorro oscuro con estela alineada a la velocidad, salpicadura roja, niebla y chispas) más un golpe de cámara leve.

## Criterios de aceptación

- [ ] F5: el polvo nace en los pies al saltar, aterrizar y correr.
- [ ] F5: el moco gotea de todo el cuerpo, no de un punto.
- [ ] F5: la muerte deja un reventón amplio y satisfactorio sin tapar el combate.
- [x] `docs/fx.md` y `docs/items.md` actualizados.
- [x] Entrada en `changelog.md`, `bitacora.md` y `estado.md` al cerrar.

## Resultado

- `scripts/player.gd`: `_feet_offset()` calcula los pies desde `CollisionShape2D` (27 px − 2) y el polvo de salto, aterrizaje y carrera emite ahí.
- `scripts/collectables/moco_emitter.gd`: emisión en caja de 14×48 px cubriendo la hitbox.
- `scripts/fx.gd`: `_burst()` acepta gravedad, radio, spread y alineación a la velocidad; `enemy_death()` usa cuatro capas (32+26+14+8 partículas, hasta 300 px/s) y `shake(1.4, 0.12)`; nueva textura de gota 2×5.
- Verificación: `git diff --check` y revisión del diff. El primer F5 destapó que `EMISSION_SHAPE_BOX` es de 3D; corregido a `EMISSION_SHAPE_RECTANGLE` + `emission_rect_extents`. Falta confirmar el resto en F5.
