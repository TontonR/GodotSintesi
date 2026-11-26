# T-0097 · Subida automática fiable y borde del manto de nieve

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player / world |
| Creado | 2026-11-26 |
| Actualizado | 2026-11-26 |
| Relacionado | T-0093, T-0096 |

## Problema

La subida automática funcionaba casi siempre, pero fallaba de forma intermitente al
llegar a un escalón, sobre todo con velocidad de carrera. Además, el corte de ambiente
al 80 % se aplicaba igual a la cantidad de partículas y al manto de nieve: las partículas
no tenían transición de cantidad y el manto terminaba en una línea vertical sobre terreno
llano.

## Causa / contexto

- `player.gd:_try_step_up()` probaba solo 1 px por delante. A 130 px/s el cuerpo avanza
  más de 2 px por frame y a 221 px/s casi 4 px, así que a veces el escalón quedaba fuera
  del alcance de la prueba y el jugador se quedaba pegado a la cara hasta el frame
  siguiente. Tampoco comprobaba que la posición elevada tuviera suelo debajo: un saliente
  podía elevar el cuerpo y dejarlo caer, que se leía como otro fallo de la subida.
- `WorldGenerator.ambient_share_at_world_x()` devolvía 0/1 y se usaba para dos cosas
  distintas. Las partículas necesitan una cantidad gradual; el manto de nieve necesita un
  borde sólido. El hash por columna convertía el corte en un borde vertical visible.

## Plan

1. Calcular el alcance de la subida con la velocidad real del cuerpo y un mínimo de 3 px.
2. Mantener la búsqueda de la altura mínima que libera el escalón y añadir una comprobación
   de apoyo de 2 px bajo los pies elevados.
3. Separar `ambient_amount_at_world_x()` (cuota gradual de partículas) de
   `ambient_share_at_world_x()` (borde 0/1 del manto).
4. Mezclar `ambient_density` en la misma ventana de transición para que el prado no salte
   de 0,2 a 1,0 de golpe al cruzar el bloque del bosque rojo.
5. Dibujar el manto con una máscara sólida y prolongar cada borde izquierdo/derecho por
   terreno llano hasta el primer cambio de altura, tanto hacia arriba como hacia abajo.

## Criterios de aceptación

- [ ] Un escalón de un tile se sube de forma consistente andando y corriendo.
- [ ] Los medios bloques siguen subiéndose con la altura mínima y sin quedar en el aire.
- [ ] Un saliente o un borde sin suelo no eleva al jugador.
- [ ] La cantidad de hojas y nieve varía gradualmente al cruzar un bioma.
- [ ] El manto de nieve no se corta en mitad de una llanura: el borde se prolonga hasta
      un cambio de altura.
- [x] `docs/player.md`, `docs/world.md`, `docs/fx.md` y `docs/biomes.md` actualizados.
- [x] Entrada en `changelog.md`, `estado.md`, `bitacora.md` y `roadmap.md`.

## Resultado

Implementado en `scripts/player.gd` (alcance por velocidad, mínimo 3 px y apoyo de 2 px),
`scripts/world_generator.gd` (`ambient_amount_at_world_x`, densidad mezclada y
`ambient_share_at_world_x` duro), `scripts/world/spritefusion_ambient.gd`
(`_cover_world`, `_snow_cover_columns()` y extensión por terreno llano) y
`scripts/world/biome_particles.gd` (comentario de la nueva cantidad gradual).

La nieve usa ahora dos capas de decisión: probabilidad gradual para las partículas y borde
duro para el manto. El manto se prolonga desde cada borde sobre columnas con la misma
altura de suelo y se detiene en cuanto la altura cambia, suba o baje.

Documentación: `docs/player.md`, `docs/world.md`, `docs/fx.md`, `docs/biomes.md`,
`vault/changelog.md`, `vault/estado.md`, `vault/bitacora.md` y `vault/roadmap.md`.

Sin Godot en esta sesión: F5 pendiente de la subida, de la cantidad gradual y del borde del
manto. Commit en la rama de consolidación `feat/castillo-plantas-3-10` (`694e6d2`, T-0098).
