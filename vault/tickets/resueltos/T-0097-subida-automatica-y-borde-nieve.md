# T-0097 · Subida automática fiable y borde del manto de nieve

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | player / world |
| Creado | 2026-11-26 |
| Actualizado | 2026-11-27 |
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

- [x] Un escalón de un tile se sube de forma consistente andando y corriendo (headless 2026-11-26).
- [x] Los medios bloques siguen subiéndose con la altura mínima y sin quedar en el aire (headless 2026-11-26).
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

Godot 4.7.2 headless en esta sesión: la subida se verificó con un arnés temporal y el
`game.tscn` real; F5 visual pendiente de la cantidad gradual y del borde del manto.
Commit base en la rama de consolidación `feat/castillo-plantas-3-10` (`694e6d2`, T-0098).

## Ronda 2026-11-26 · primera colisión y apoyo en el destino

Ruben reportó que la subida automática «cada vez funciona menos» al probar con KP5, KP9 y
D mantenida. El problema se reprodujo en headless incluso a 1×:

- La comprobación de apoyo se hacía en la posición actual, pero al elevar el cuerpo el
  suelo antiguo ya no está debajo de los pies; por eso rechazaba escalones de 8/16 px.
- A 16×/32× el sondeo recorría todo el frame y veía el segundo escalón de una escalera,
  rechazando el primero.
- Si el primer contacto caía justo al final del avance, la subida dejaba al cuerpo a la
  altura del borde pero sin estar encima; `is_on_floor()` quedaba falso y se atascaba.
- Conservar la velocidad vertical de gravedad tras la subida lo hundía ~1 px en la cara
  siguiente a time scales altos.

El fix en `scripts/player.gd:_try_step_up()` busca la primera colisión del recorrido,
sube solo ese escalón, comprueba hueco y apoyo de 2 px en el destino, anula `velocity.y` y
se abstiene cuando el contacto cae en el límite del frame para reintentar al siguiente.

Verificación headless (Godot 4.7.2, arneses temporales retirados):

- 60/60 casos: 8/16 px, escalones anchos y estrechos, dos escalones seguidos, andando y
  corriendo a 1×, 4×, 16×, 32× y 64×.
- `game.tscn` real, semilla 12345, inmortal y D mantenida: avance de 898 px a 1×, 2.739 px
  a 16×, 3.328 px a 32× y 3.579 px a 64×, sin errores de física en el log.
- F5 visual pendiente; el caso 64× es una prueba de estrés, no la velocidad de juego.
