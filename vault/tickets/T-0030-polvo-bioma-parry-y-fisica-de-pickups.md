# T-0030 · Polvo del color del bioma, parry con chispas y física de pickups

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | player / world / docs |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0028, T-0029 |

## Problema

- El polvo de `fx.dust()` usa un gris tostado fijo (`Color(0.84, 0.8, 0.72, 0.75)`), así que en la pradera no se lee como césped.
- No hay parry: la guardia bloquea el daño frontal sin ningún feedback de chispas ni de "golpe parado".
- Las monedas (`scripts/collectables/coin.gd`) son un `Area2D` estático: aparecen ya apoyadas en el suelo y no caen ni rebotan. Los objetos (`item_pickup.gd`) tienen gravedad, pero el drop nace prácticamente a ras de suelo y el aterrizaje casi no se ve.

## Plan

1. `fx.dust()` consulta el bioma en la X del impacto (`world_generator.biome_at_world_x`) y tiñe la nube con `grass_color` aclarado; sin generador, cae al gris anterior.
2. `fx.parry()`: dos estallidos de chispas (blancas y doradas), texto `¡PARRY!`, sacudida corta y destello cálido suave.
3. `player.gd`: ventana `parry_window` (0,18 s) al levantar la guardia. Un golpe frontal dentro de la ventana se para con `fx.parry()` y consume la ventana.
4. `coin.gd`: gravedad, búsqueda de suelo, rebote y vaivén al asentarse. `world_generator` las hace nacer `coin_spawn_height` px sobre el suelo para que se vea la caída.
5. `item_pickup.gd`: pequeño salto inicial (`drop_hop`) al aparecer, para que el drop caiga y rebote en vez de materializarse quieto.

## Criterios de aceptación

- [ ] En pradera el polvo sale verde; en bosque rojo, rojizo; en nieve, blanquecino.
- [ ] Bloquear con la guardia recién levantada muestra chispas y `¡PARRY!` sin recibir daño.
- [ ] Las monedas caen, rebotan y se quedan con un vaivén mínimo.
- [ ] Los objetos dropeados hacen un salto corto antes de caer.
- [ ] `docs/fx.md`, `docs/player.md`, `docs/world.md` y `docs/items.md` actualizados.
- [ ] Entrada en `changelog.md` y `estado.md` al cerrar.

## Resultado

- `scripts/fx.gd`: `dust()` tiñe con `Biome.grass_color.lightened(0.35)` vía `_biome_at()` (grupo `world_generator` → `biome_at_world_x()`), con el gris anterior como respaldo. Nuevo `parry()`: 16 chispas blancas + 10 doradas, `¡PARRY!`, `shake(1.2, 0.1)` y `damage_flash()` con color/alfa opcionales (0,16).
- `scripts/player.gd`: `parry_window` 0,18 s y `_parry_timer`; se arma al levantar la guardia y se consume al parar un golpe frontal, que llama a `fx.parry()` y sigue avisando a las pasivas de bloqueo.
- `scripts/collectables/coin.gd`: gravedad 900, búsqueda de suelo por raycast (capa 1), rebote 0,4, asentado y vaivén; media altura calculada del `CollisionShape2D` escalado. `scripts/world_generator.gd`: `coin_ground_offset` → `coin_spawn_height` (40 px), las monedas caen.
- `item_pickup.gd`: `drop_hop` 150 px/s al aparecer; `_find_ground()` no asienta mientras sube.
- Documentación: `docs/fx.md`, `docs/player.md`, `docs/world.md`, `docs/items.md`.
- Verificación: sin ejecutar Godot (regla de `AGENTS.md`); revisión del diff y `git diff --check`. Pendiente F5 visual.
