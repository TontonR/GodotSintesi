# T-0057 · Decoraciones de bioma (arbustos, árboles y rocas)

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world |
| Rama | `feat/decor` |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-13 |
| Relacionado | T-0057 |

## Problema

`assets/map/decor/` (2 arbustos, 2 árboles, 2 rocas) estaba sin usar: el mundo
solo tenía suelo, hierba y fondos. Además los biomas no tenían un color propio
para la vegetación ni voz sobre qué decoración aparecía.

## Plan (primera pasada)

1. Añadir `decor_colors: Array[Color]` a `Biome` y rellenarlo en los tres `.tres`.
2. Generar copias grises de arbustos y árbol vivo (solo píxeles verdes).
3. Spawnear los decorados por chunk con pesos, detrás de `Solid`/`GrassPaint`,
   apoyados en la fila de superficie, sin colisión, escala ni parallax.
4. Elegir el tinte de cada decorado al azar del array del bioma de su tile.
5. Documentar en `docs/decor.md` y actualizar `docs/biomes.md`, `docs/world.md`
   y el índice de `AGENTS.md`.

## Plan (segunda pasada)

1. Escalar todo (arbustos 1.9, árboles 1.8, rocas 1.7) manteniendo el origen en
   la base para que el escalado no despegue el decorado del suelo.
2. Dar al bioma el control de densidad y tipos: `decor_per_chunk`,
   `decor_kinds` y `decor_weights`. Pradera con bastantes árboles (32 por chunk,
   ~13 árboles) y bosque rojo con muchos más (52 por chunk, ~35 árboles).
3. Ponderar los tintes con `decor_color_weights`: el bosque rojo mezcla rojo (6),
   naranja (3) y amarillo (1), así que dominan los rojos.
4. Mandar las rocas al fondo con `z_index` −1 y ordenar el dibujo
   rocas → árboles → arbustos.
5. Bamboleo de arbustos al pasar (`DecorProp`, 0.1 rad, radio 48 px) y estallido
   de 7 hojas del color del arbusto vía `fx.leaves()`.

## Plan (tercera pasada)

1. Arreglar el tronco teñido: generar la copia tintada por píxel en runtime y
   recolorear solo las hojas verdes, dejando el `modulate` en blanco.
2. Repartir el decorado en slots estratificados con separación mínima de 3
   tiles, para quitar tanto los huecos como las acumulaciones.
3. Bajar la densidad general (pradera 20, bosque rojo 26, nieve 10) y dejar la
   nieve con el 40% de sus árboles muertos de forma exacta por chunk.

## Plan (cuarta pasada)

1. Ruben: la vegetación de la nieve sale gris; llevar todos los tintes de
   decorado del bioma a casi blanco, conservando el matiz frío.

## Criterios de aceptación (cuarta pasada)

- [x] Arbustos y árboles vivos de nieve se leen escarchados, no grises.
- [ ] F5 visual en el bioma nevado.

## Criterios de aceptación (tercera pasada)

- [x] El tronco de los árboles conserva su marrón original en los tres biomas.
- [x] Dos decorados del mismo chunk nunca quedan a menos de 3 tiles.
- [x] El reparto es uniforme: ni zonas vacías largas ni acumulaciones.
- [x] Nieve con poca generación y 40% de árboles muertos.

## Criterios de aceptación

- [x] Salen arbustos, árboles y rocas en el mundo, detrás del suelo.
- [x] No colisionan, no se mueven con la cámara (no parallax) y mueren con el chunk.
- [x] Arbustos y árbol vivo cambian de color con el bioma; rocas y árbol muerto no.
- [x] Cada bioma decide cuántos decorados y de qué tipos aparecen en sus chunks.
- [x] Pradera con bastantes árboles; bosque rojo con muchos más y tintes
      mayoritariamente rojos, con naranjas y amarillos en menor cantidad.
- [x] Las rocas se leen como fondo, detrás de árboles y arbustos.
- [x] Los arbustos se inclinan al pasar el jugador y sueltan hojas.
- [x] `docs/decor.md` actualizado y enlazado desde `docs/world.md` y `AGENTS.md`.
- [ ] F5 visual con los tres biomas (densidad, escala y tonos).

## Resultado

- `scripts/world/biome.gd`: `decor_per_chunk`, `decor_kinds`, `decor_weights` y
  `decor_color_weights`.
- `scripts/world_generator.gd`: grupo **Decor** ampliado (`decor_names`,
  `decor_scales`, `decor_z_index`, `decor_sways`, `decor_sway_radius_px`),
  elección ponderada por bioma, tinte ponderado, orden de dibujo y `z_index` de
  rocas; los sprites pasan a `DecorProp` con `offset` en la base.
- `scripts/world/decor_prop.gd`: bamboleo y hojas (solo arbustos; el resto
  desactiva `_process`).
- `scripts/fx.gd`: `leaves()` reutiliza el `fx` compartido.
- `resources/world/biomes/{pradera,bosque_rojo,nieve}.tres`: densidades, tipos,
  pesos y tintes nuevos (rojo 6 / naranja 3 / amarillo 1 en el bosque rojo).
- Comprobado con script headless: pradera 32 decorados (13 árboles), bosque rojo
  52 (35 árboles, tintes 29 rojos / 15 naranjas / 5 amarillos), nieve 24; base
  alineada con la superficie, offsets correctos, 0 colisiones, rocas a `z_index`
  −1, arbusto con rotación 0.042 rad y un estallido de hojas al acercarse, y
  vuelta a 0 al alejarse.
- Tercera pasada: `WorldGenerator._decor_texture`/`_tint_foliage` generan y
  cachean una copia por textura + color donde solo cambian los píxeles verdes
  (tronco, contorno y marrones intactos), con `modulate` en blanco y
  `DecorProp.tint_color` para las hojas.
- Reparto en slots estratificados con `decor_min_gap_tiles` = 3; densidades
  20/26/10 por chunk y `Biome.decor_dead_tree_ratio` (nieve 0.4) que convierte
  el 40% exacto de los árboles del chunk en muertos.
- Comprobado headless: tronco `(0.247, 0.188, 0.176)` idéntico al original con
  tinte rojo, hojas teñidas, rocas y árbol muerto sin tocar, caché reutilizada;
  separaciones mínimas 8/5/23 tiles; 20/26/10 props por chunk; nieve 40% de
  muertos. F5 pendiente.
- Cuarta pasada: `nieve.tres` pasa a `decor_colors` `(0.98, 1, 1)`,
  `(0.88, 0.94, 0.99)` y `(0.78, 0.86, 0.94)` con pesos 3/3/2 (casi blanco con
  matiz de hielo); `docs/decor.md` y `docs/biomes.md` al día. F5 pendiente.
- Rama publicada y [PR #1](https://github.com/TontonR/GodotSintesi/pull/1)
  abierta, sin mergear.
