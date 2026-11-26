# T-0098 · Normalizar los rectángulos de ataque espejados

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | enemies / player / fx |
| Creado | 2026-11-26 |
| Actualizado | 2026-11-26 |
| Relacionado | T-0096, T-0097 |

## Problema

El debugger de Godot mostraba **3974 errores** del tipo:

```text
spritefusion_ambient.gd:895 @ _lift_rect(): Rect2 size is negative, this is not supported.
Use Rect2.abs() to get a Rect2 with a positive size.
```

Se disparaban al golpear o al recibir ataques cerca de hojas y litter. Los dos puntos
señalados (`881` y `895`) son los `has_point()` de las hojas y del litter; el error no
está en la nieve ni en el dibujo del manto.

## Causa / contexto

`EnemyBase.attack_rects()` construye los rectángulos de `attack_range`. Ese `Area2D` vive
debajo de `flip_pivot` en las escenas de enemigos, y `_set_facing_direction()` pone
`flip_pivot.scale.x = -1.0` cuando el enemigo mira a la izquierda.

`_collision_rect()` hacía:

```gdscript
var size := shape.size * shape_node.global_transform.get_scale()
```

Con `scale.x = -1`, `size.x` quedaba negativo. Después, `_lift_rect()` llamaba a
`rect.get_center()` y `rect.has_point()`, y Godot rechaza esas operaciones en un `Rect2`
con tamaño negativo. Cada ataque de un enemigo orientado a la izquierda repetía el error
para cada hoja/litter comprobado, de ahí los miles de mensajes.

`player.gd:_shape_rect()` tenía el mismo patrón latente. Las hitboxes del jugador no están
bajo `SpritePivot` hoy, pero cualquier padre con escala negativa habría reproducido el
problema.

## Plan

1. Normalizar el tamaño de los rectángulos de rectángulo (`absf`) y el radio de los
   círculos en `EnemyBase._collision_rect()` y `Player._shape_rect()`.
2. Añadir una defensa en `SpriteFusionAmbient._lift_rect()`: si llega un `Rect2` negativo,
   convertirlo con `Rect2.abs()` antes de usarlo.
3. Documentar el contrato en `docs/fx.md` y dejar el ticket en `revision`.
4. Verificar el diff y versionarlo en la rama de consolidación.

## Criterios de aceptación

- [ ] Atacar o recibir ataques con un enemigo mirando a la izquierda no genera errores
      `Rect2 size is negative`.
- [ ] Las hojas y el litter siguen reaccionando a las hitboxes espejadas.
- [x] `docs/fx.md` actualizado.
- [x] Entrada en `changelog.md`, `estado.md`, `bitacora.md` y `roadmap.md`.

## Resultado

- `scripts/enemies/enemy_base.gd`: `_collision_rect()` normaliza `size` y `radius` con
  `absf`.
- `scripts/player.gd`: `_shape_rect()` aplica la misma normalización defensiva.
- `scripts/world/spritefusion_ambient.gd`: `_lift_rect()` sanea cualquier rectángulo
  negativo con `Rect2.abs()` antes de `get_center()`/`has_point()`.
- `docs/fx.md`: documentado que las cajas de ataque bajo un pivote espejado deben seguir
  teniendo tamaño positivo.

No se ejecutó Godot en esta sesión: falta F5 para confirmar que el contador de errores
queda a cero durante el combate.
