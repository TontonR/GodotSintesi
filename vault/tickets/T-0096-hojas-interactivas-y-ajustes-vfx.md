# T-0096 · Hojas interactivas, disolución por píxeles y ajustes VFX

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | fx / ui / world |
| Creado | 2026-11-26 |
| Actualizado | 2026-11-26 |
| Relacionado | T-0093, T-0094 |

## Problema

Las hojas ambientales de T-0093 solo salen del 55 % de las copas, no reaccionan al
jugador ni a los enemigos, el litter del suelo es permanente y las hojas que
desaparecen lo hacen con un fundido de alfa. Además no hay forma de apagar esas
partículas desde Ajustes ni de desactivar las físicas VFX si bajan el rendimiento.

## Plan

1. Añadir `VfxSettings` (autoload) con `leaves_enabled` y `enhanced_vfx_physics`,
   persistidos en `user://settings.cfg` y expuestos en `SettingsPanel`.
2. Hacer que todas las copas vivas entren en el reparto por turnos.
3. Añadir impulsos a las hojas al pasar el jugador o un enemigo, al correr y al
   golpear con las hitboxes; las hojas del suelo ganan vida al interactuar.
4. Sustituir el fundido de alfa de las hojas por una disolución aleatoria píxel a
   píxel con shader, tanto en las hojas que caen como en el litter.
5. Exponer `hurt_rect()`, `attack_rects()`, `is_attacking_now()` e `is_running_now()` en jugador/enemigos
   para que el sistema de partículas no dependa de campos privados.

## Criterios de aceptación

- [ ] Todas las copas vivas sueltan hojas y el reparto sigue siendo por turnos.
- [ ] El jugador y los enemigos mueven las hojas; correr las lanza y los golpes
      levantan las que caen dentro de la hitbox.
- [ ] Las hojas del suelo alargan su vida al pasar por encima.
- [ ] Al agotarse la vida, la hoja desaparece con píxeles aleatorios, sin alfa.
- [ ] Ajustes permite apagar las hojas y las físicas VFX mejoradas, y se guarda.
- [x] `docs/fx.md`, `docs/decor.md`, `docs/world.md` y `docs/ui.md` actualizados.
- [x] Entrada en `changelog.md` y `estado.md` al cerrar.

## Resultado

Implementado en `scripts/world/spritefusion_ambient.gd`: todas las copas participan en el
reparto por turnos, las hojas y el litter reaccionan a `hurt_rect()` de jugador/enemigos,
las `attack_rects()` activas las levantan, el litter gana vida al tocarlo y la retirada usa
`assets/vfx/spritefusion/leaf_dissolve.gdshader` (píxeles aleatorios, sin alfa).
`scripts/vfx_settings.gd` (autoload `VfxSettings`) y el panel de ajustes añaden **Leaf
particles** y **Enhanced VFX physics**, persistidos en `[vfx]`; los enemigos entran en el
grupo `enemies`. Docs: `docs/fx.md`, `docs/decor.md`, `docs/world.md`, `docs/ui.md`.

Sin Godot en esta sesión: F5 pendiente de todas las interacciones y de la disolución.

## Ronda 8 (2026-11-26)

La nieve vuelve al trazo por píxel de la primera versión, sin bandas de 16 px ni
interpolación diagonal entre alturas; cada columna solo cubre su propia superficie y deja
limpia la cara vertical. El ventisquero es 1 px más alto (2–6 px) y, con **Enhanced VFX
physics**, la huella del jugador lo comprime hasta 1 px y deja una huella baja durante
3,5 s. El toggle ahora también se aplica al efecto de nieve.

Las hojas siguen la dirección del movimiento o del centro de la hitbox. Los golpes elevan
como máximo 4 hojas por lote (0,3 s de espera) y correr mueve 2 por lote (0,18 s), con
impulso lateral en vez de salir casi solo hacia arriba.

## Ronda 9 (2026-11-26)

- La nieve interpola las muestras de suelo cada 16 px solo para el dibujo; los escalones
  se leen como pendientes cortas y desaparecen las costuras verticales. Las partículas
  siguen aterrizando en el escalón real de `_ground_at()`.
- El re-scatter posterior a un TP ya no nace bajo las copas; el reciclado normal reparte
  ~35 % bajo copas y el resto al aire, sin montones sobre los árboles.
- `fx.enemy_hit()` lanza un chorro direccional de sangre alejándose del jugador; la muerte
  mantiene el estallido radial.

## Ronda 10 (2026-11-26)

La interpolación de la ronda 9 convertía cada escalón en una pendiente fina y los picos de
ruido seguían leyéndose como líneas. El ventisquero usa ahora una altura uniforme de 3 px
sobre `_ground_at()`: el borde del bloque termina el manto y lo retoma en la repisa
inferior, sin diagonal ni píxeles sueltos. La compresión de la huella y las partículas no
cambian.

## Ronda 11 (2026-11-26)

La altura uniforme quedaba demasiado plana. Vuelve el ruido, pero solo de baja frecuencia
(`_snow_drift_height()`, 3–7 px): la superficie ondula y es más alta sin los picos densos
de 1 px que se veían como líneas. El manto sigue cortándose en el escalón real.

El ambiente también cambia: `ambient_share_at_world_x()` devuelve 0/1 según
`AMBIENT_SHARE_CUTOFF = 0.8`, así que hojas y nieve aparecen de golpe cerca de su bioma y
no se degradan durante toda la transición.

## Ronda 12 (2026-11-26)

El prado también tiene hojas, pero muchas menos que el bosque rojo. `Biome` gana
`ambient_density` (el prado usa 0.2) y `ambient_leaf_color` (verde en el prado, alfa 0 =
paletas de otoño). `WorldGenerator.ambient_density_at_world_x()` multiplica la cuota de
partículas y `ambient_leaf_color_at_world_x()` tiñe las hojas de cielo abierto y el
litter. Las copas de los árboles normales ya usan su `tint_color` verde; el bosque rojo
no cambia.

## Ronda 13 (2026-11-26)

La transición de partículas pasa a cantidad gradual (`ambient_amount_at_world_x` más la
densidad mezclada); el manto de nieve mantiene un borde duro y ahora lo prolonga por terreno
llano hasta el primer cambio de altura. La subida automática del jugador se corrige en
T-0097.
