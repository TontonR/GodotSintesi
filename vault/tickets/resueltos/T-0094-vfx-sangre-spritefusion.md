# T-0094 · VFX de sangre de Sprite Fusion en la muerte de enemigos

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx |
| Creado | 2026-11-26 |
| Actualizado | 2026-11-26 (chorro al golpe) |
| Relacionado | T-0092, T-0093, T-0029, T-0043 |

## Problema

La muerte de un enemigo usa cuatro capas de `CPUParticles2D` creadas en código
(`fx.enemy_death()`): chorro, salpicadura, niebla y chispas. Sirven, pero no hay
hebras, ni gotas con estela, ni costras que se sequen en el suelo. Sprite Fusion
publica un efecto `blood` gratuito (MIT) con esa lectura completa y su receta
numérica, y el proyecto ya usa su canal público de ZIP para el ambiente (T-0093).

## Canal usado

- `assets/downloads/pixel-art-vfx/blood.zip` es una descarga pública MIT; no
  necesita cuenta ni claves. La receta se guarda en
  `assets/vfx/spritefusion/blood.ts` con la `LICENSE` que ya estaba.

## Plan

1. Portar la receta a un nodo propio en espacio de mundo, con un canvas RGBA8
   pequeño anclado al golpe (no una escena ni un PNG por frame).
2. Hebras de 90 ms, chorro y gotas con arrastre y gravedad, costras que se secan
   6 s sobre `WorldGenerator.ground_y_at()`, niebla, goteo desde la herida y
   rampa de 6 tonos derivada de `EnemyBase.blood_color` (T-0043).
3. Integrarlo en `fx.enemy_death()` sin cambiar su firma; dejar una chispa clara
   y la sacudida de cámara.
4. Documentar en `docs/fx.md`.

## Criterios de aceptación

- [x] Un nodo por muerte, en coordenadas de mundo y liberado solo al secarse.
- [x] Hebras, gotas (3 tamaños), niebla y goteo con los números de la receta.
- [x] Las gotas se paran en el suelo escalonado por tile y dejan costra.
- [x] `blood_color` por enemigo cambia toda la rampa, sin tocar la llamada.
- [x] MIT y fuente citada en `assets/vfx/spritefusion/`.
- [ ] F5: comprobar lectura y contraste de la sangre sobre los tres biomas.

## Resultado

Hecho en `scripts/fx/spritefusion_blood.gd` (`class_name SpriteFusionBlood`).
`fx.enemy_death(world_position, blood_color)` crea el nodo y conserva la chispa clara
y `shake(1.4, 0.12)`. Desde la ronda 6 pasa dirección **0**: el chorro direccional se
sustituye por una explosión radial (72 gotas base ×1,6, 20 de anillo y 10 puffs de
niebla, todas en 360° y más lentas), así la sangre no sale hacia el lado contrario y
se lee más cantidad al matar. El chorro lateral queda para golpes direccionales. Sin
F5 todavía.

## Golpes (2026-11-26)

`fx.enemy_hit()` ya no deja solo chispas: crea un `SpriteFusionBlood` más pequeño
(`amount` 0,55, `size` 0,8) y lo lanza hacia el lado contrario al jugador, con el
`blood_color` del enemigo. La muerte conserva el estallido radial. F5 pendiente.
