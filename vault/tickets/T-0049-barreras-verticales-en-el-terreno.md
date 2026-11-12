# T-0049 · Barreras verticales de 4+ tiles en el terreno

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | mundo |
| Creado | 2026-11-10 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0044, T-0027 |

## Problema

De vez en cuando el terreno pega un salto de **4 bloques** que no se puede subir andando
(el auto-escalón sube 1 tile) ni con el salto normal: hace falta la poción que multiplica el
salto (`jump_velocity × 1.3`). Es raro en general, pero hay puntos donde se acumula.

Caso reportado:

- Seed **775344231**.
- Coordenadas **451640, 933** px → tile **28227, 58** (suelo en la fila 58, dentro del
  chunk 110, no en una costura).

## Causa (hipótesis principal, ya localizada en código)

`_noise_height()` (`scripts/world_generator.gd`) suma 3 muestras de `FastNoiseLite` 1D
Perlin con `height_amplitude` 20, `noise_octaves` 4, `noise_gain` 0.45 y
`noise_frequency` 0.007. Cada octava añade pendiente: el paso entre dos tiles vecinos
puede salir de 2–3 filas y, con el multiplicador de amplitud del bioma (bosque rojo ×1.35),
llega a 4. `_height_at_with()` redondea **cada columna de forma independiente**
(`clampi(roundi(...), 5, 110)`), así que nunca limita la diferencia con la columna anterior:
el mundo acepta cualquier escalón que salga del ruido.

No es un bug de costuras ni de chunks: `_chunk_biome_data()` mezcla con la misma ventana en
los dos lados y `edge_left`/`edge_right` usan `_height_at()` con la misma fórmula. El
problema es la pendiente máxima del campo de altura.

## Plan

1. Añadir un tope de pendiente por columna al generar (export `max_step_tiles`, por defecto
   1 o 2): al construir `heights[]`, acotar
   `heights[i] = clampi(prev + delta, prev - max_step, prev + max_step)` en vez de usar el
   ruido en bruto. Al ser un filtro de izquierda a derecha y determinista (mismo seed →
   mismas alturas), las costuras entre chunks siguen coincidiendo, pero hay que aplicar el
   mismo clamp a `edge_right`/`edge_right_next` y a `_height_at()` para que el chunk
   siguiente arranque donde lo dejó el anterior (el generador ya guarda la última altura
   por chunk).
2. Alternativa/complemento si el relieve queda demasiado plano: bajar `noise_gain` a 0.35
   o reducir `height_amplitude` en el bioma rojo (1.35 → 1.15).
3. Verificar con la seed 775344231 en el tile 28227 que la pared máxima es de 2 tiles, y
   recorrer varios chunks comprobando que no aparecen ni costuras ni suelo flotante.

## Criterios de aceptación

- [x] Ningún escalón entre tiles vecinos supera `max_step_tiles` (≤ 2, saltable).
- [x] La seed 775344231 en el tile 28227 ya no tiene la barrera de 4 bloques.
- [x] Las costuras de chunk siguen casando (sin 1 px de suelo desplazado) y el spawn
      (tile 50, fila 50) sigue plano.
- [x] `docs/world.md` actualizado con el tope de pendiente y por qué existe.

## Resultado

`WorldGenerator.max_step_tiles` (export, por defecto 1) acota cada columna a ±1 fila
respecto de la anterior en `_build_clamped_heights()`; `_height_at()` y `_generate_chunk()`
leen esas alturas ya filtradas. Cadena por chunks cacheada (`_clamped_heights` se poda como
`_chunk_data`, `_clamped_last` guarda la última columna para poder reconstruir). La columna
compartida y la extra de la derecha se heredan del vecino en vez de recalcularse: con otro
modificador de bioma la costura se desviaba 1 fila. Muere `_terrain_at_tile()` (sin usos).

Comprobado con un script headless desechable (seed 775344231, tiles 0–28229): escalón
máximo 1, sin barreras en 28227; `edge_left`/`edge_right`/`edge_right_next` coinciden con
`_height_at()` en las costuras; `scenes/game.tscn` arranca 180 frames sin errores. F5 en
editor pendiente.
