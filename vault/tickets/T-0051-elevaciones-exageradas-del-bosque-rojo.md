# T-0051 · Elevaciones exageradas por el multiplicador de terreno del bioma

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0050, T-0049, T-0044, T-0024 |

## Problema

`humano-ruben`: siguen saliendo **montañas/elevaciones exageradas en algunos sitios**,
con el generador de antes y con el de T-0050. Sospecha del ruido o de la elevación por
bioma. Además T-0050 dejaba demasiados suelos elevados de 2 tiles: prefería la
generación anterior, así que se revierte a la de T-0049 (±1) y se busca la causa real.

## Causa

No era un bug de costuras ni del ruido base: los dos multiplicadores del **bosque rojo**
en `resources/world/biomes/bosque_rojo.tres` (`terrain_amplitude_multiplier` 1.35 y
`terrain_frequency_multiplier` 1.1) pedían un relieve más rápido y más alto del que el
tope de ±1 puede seguir. El suelo se queda atrás del ruido y, como solo puede subir 1
fila por columna, acaba dibujando **rampas de un escalón por columna** de decenas de
tiles: montañas piramidales de 30–40 tiles y tramos de hasta 123 escalones seguidos.

Medido con el generador real, 40 000 tiles y seeds 12345 / 775344231 / 777 (amplitud y
frecuencia del bosque rojo, resto igual):

| red forest | relieve máx. | peor ventana de 300 tiles | tramo de escalones seguidos |
|---|---|---|---|
| ×1.35 / ×1.1 (antes) | 37–39 | 31–36 | hasta 123 |
| amplitud 1.0 / ×1.1 | 28–29 | 26–27 | hasta 83 |
| ×1.35 / frecuencia 1.0 | 38–40 | 33–35 | 21–22 |
| **0.95 / 1.0 (ahora)** | **28–29** | **26** | **11–14** |

La frecuencia era la que fabricaba las rampas eternas (83–123 escalones) y la amplitud
la que hinchaba las montañas; con 0.95/1.0 el bosque rojo se comporta como la pradera.

## Plan

1. Revertir T-0050 (terreno con losas y suelos de 2) a la generación de T-0049.
2. Bajar el bosque rojo a `0.95 / 1.0` y dejar escrito que un bioma solo puede aplanar.
3. Verificar relieve, escalón máximo, costuras y arranque de la escena.
4. Actualizar `docs/world.md`.

## Criterios de aceptación

- [x] Escalón máximo entre columnas vecinas: 1 tile (sin suelos de 2 en ningún sitio).
- [x] Se acaban las rampas de decenas de escalones: el tramo más largo baja de
      83–123 a 11–14 columnas.
- [x] Relieve máximo por 300 tiles de 36 a 26; desaparecen las montañas de 30–40 tiles.
- [x] Costuras exactas y spawn plano (comprobado en el generador real).
- [x] `docs/world.md` actualizado.
- [ ] F5 en editor: recorrer pradera, bosque rojo y nieve y confirmar que no queda
      ninguna elevación rara.

## Resultado

`resources/world/biomes/bosque_rojo.tres`: `terrain_amplitude_multiplier` 1.35 → 0.95 y
`terrain_frequency_multiplier` 1.1 → 1.0. `scripts/world_generator.gd` vuelve al estado
de T-0049 (`git checkout`), con `max_step_tiles` 1 y `_clamped_*` de nuevo. La pradera
(0.95) y la nieve (1.0) no cambian.

Comprobado con script headless desechable sobre el generador real (seeds 12345 y
775344231, 40 000 tiles, `base_height` 50 y `safe_start_tiles` 50): escalón máximo 1,
peor ventana de 300 tiles 26, tramo más largo de escalones 11–14, costuras exactas y
spawn plano; `scenes/game.tscn` arranca 120 frames sin errores. F5 pendiente.
