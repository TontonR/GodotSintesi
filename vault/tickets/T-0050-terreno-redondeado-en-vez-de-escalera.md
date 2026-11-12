# T-0050 · Terreno redondeado en vez de escalera de escalones de 1

| Campo | Valor |
|---|---|
| Estado | `cerrado` |
| Tipo | `cambio` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-12 |
| Actualizado | 2026-11-12 |
| Relacionado | T-0049, T-0044, T-0027 |

## Problema

T-0049 quitó las paredes de 4 tiles, pero el remedio se ve peor: Ruben lo describe
como **una escalera antinatural**. Con el tope de ±1 cada columna de una pendiente
baja exactamente 1 fila, así que cada ladera es una diagonal perfecta de peldaños
iguales (medido en la seed 775344231: tramos de hasta **51 columnas** seguidas
moviéndose, en el bosque rojo donde la amplitud va ×1.35).

Petición de diseño (`humano-ruben`):

- Esas partes deben verse **más redondeadas, no diagonales**.
- Paredes de **2 tiles** sí pueden existir, y **muy rara vez de 3**; nada más alto.

## Causa

`_build_clamped_heights()` (`scripts/world_generator.gd`) aplicaba
`clampi(h, prev - 1, prev + 1)` columna a columna. Es un limitador de pendiente puro:
no introduce tramos planos, así que donde el ruido pide bajar más de 1 tile por columna
el resultado es una rampa de 45° (un escalón por columna) en vez de losas y paredes.

## Plan

1. Sustituir el recorte por una **forma por columna**: `_shaped_step()` sigue el ruido,
   pero mantiene la losa mientras el desvío es pequeño y luego pega una pared entera.
2. `max_step_tiles` por defecto 2 (salto normal: ~41 px = 2.6 tiles); pared de 3 con
   `rare_step_chance` 0.06.
3. Los tramos planos los decide `tread_hold_chance` (0.65, mitad a 2 tiles de desvío,
   nada a 3): el suelo conserva la losa mientras la pendiente es suave.
4. Tirada determinista por columna (`_terrain_roll()`, hash de seed + columna) para no
   arrastrar estado entre chunks y que las costuras sigan casando.
5. Verificar con script headless desechable y actualizar `docs/world.md`.

## Criterios de aceptación

- [x] Ningún escalón entre columnas vecinas supera 3 tiles; los de 3 son ~0.2 % de las
      columnas (49 en 28k en la seed 775344231, 70 en la seed 12345).
- [x] Se acaban los tramos diagonales largos: el tramo más largo de columnas seguidas
      moviéndose baja de 51 a 20–21, y el de escalones idénticos de 21 a 9.
- [x] El terreno se lee por losas: 74–76 % de columnas planas, 14 % de 1 tile y 10–11 %
      de 2 tiles.
- [x] Costuras exactas (0 desajustes en 110 chunks de las dos seeds) y spawn plano.
- [x] `docs/world.md` actualizado con la forma del terreno y por qué existe.
- [ ] F5 en editor: recorrer pradera y bosque rojo y comprobar que se ve redondeado.

## Resultado

`scripts/world_generator.gd`: fuera el recorte ±N. `_build_shaped_heights()` encadena
`_shaped_step(tile_x, target, prev)`, que mantiene la losa con probabilidad
`tread_hold_chance × (1 - (desvío - 1) / max_step_tiles)` y si no pega pared de
`max_step_tiles` (2), con 3 cuando `rare_step_chance` sale y el desvío ya pasa de 2.
`_terrain_roll()` mezcla seed y columna (sin `RandomNumberGenerator` persistente).
Renombrados `_clamped_heights`/`_clamped_last`/`_clamped_heights_for()` a
`_shaped_*`. `max_step_tiles` pasa de 1 a 2.

Comprobado con un script headless desechable sobre el generador real (seeds 12345 y
775344231, 28 200 tiles cada una, `base_height` 50 y `safe_start_tiles` 50): máximo 3,
histograma medido, costuras exactas entre 110 chunks, banda de spawn plana, y
`scenes/game.tscn` arrancando 120 frames sin errores. F5 pendiente.

## Cierre (2026-11-12)

**Revertido a petición de `humano-ruben`**: los suelos de 2 tiles pasaron a ser demasiado
frecuentes y prefería la generación anterior, así que `scripts/world_generator.gd` vuelve
al estado de T-0049 (`max_step_tiles` 1, sin `_shaped_step()` ni `_terrain_roll()`). El
problema de las laderas exageradas no era este y se ataca en
[T-0051](T-0051-elevaciones-exageradas-del-bosque-rojo.md).
