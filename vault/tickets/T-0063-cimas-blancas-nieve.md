# T-0063 · Cimas de montaña: blanco en la nieve y color original en el resto

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `media` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-13 |
| Actualizado | 2026-11-13 (tercera pasada: color de la cima por bioma) |
| Relacionado | T-0040, T-0057 |

## Problema

Ruben: la cima de las montañas del fondo en los biomas nevados se oscurece en
vez de leerse como nieve. Después: la capa de nieve no era la cima entera,
solo el brillo. Ahora: en el resto de biomas la cima debe verse como en la
imagen original, con un mini toque del color de cada bioma.

## Causa

- `mountains/Sprite2DSnow` (`mountain2_snow.png`, la capa de nieve) no estaba en
  ninguna lista de tinte: se quedaba con el blanco de la textura, que no es
  blanco puro (≈ `184, 172, 171`), sobre un risco teñido de `rock_color`
  (`0.75, 0.78, 0.82`): la cima salía gris sucia.
- El modulate solo multiplica, así que ningún tinte normal aclara la capa.
- `mountain2_snow.png` solo recogía el tono más claro de los tres de la roca
  (`184, 172, 171`, el brillo de 5.944 px): la cara iluminada
  (`161, 148, 147`, 20.474 px) y la de sombra (`107, 108, 122`, 13.136 px)
  seguían siendo roca teñida.
- Con la capa oculta por defecto (alpha 0) el resto de biomas se quedaba sin
  cima: el arte original no tenía esa capa, así que la montaña perdía el brillo.

## Plan

1. Añadir el canal `snow` a `Biome` (`snow_color`, blanco por defecto).
2. Añadir `snow_tint_paths` al generador (`mountains/Sprite2DSnow`) y aplicarlo
   en `_update_biome_tint()`, junto al resto de canales.
3. Regenerar `mountain2_snow.png` con los tres tonos de roca en tres blancos.
4. `nieve.tres`: `snow_color = (1, 1, 1)` y `rock_color` más claro.
5. Resto de biomas: `snow_color` por defecto `(0.72, 0.66, 0.65)`, que sobre los
   tres blancos devuelve el color original de la cima, con un mini toque propio
   en prado y bosque rojo.

## Criterios de aceptación

- [x] La nieve cubre los tres tonos de la roca, no solo el brillo.
- [x] La nieve de la cima queda blanca en el bioma nevado.
- [x] El resto de biomas conserva el color original de la cima (±5 % medido) con
      un mini toque de su propio color.
- [ ] F5: mirar las montañas en los tres biomas y en la transición.
- [x] `docs/biomes.md` actualizado.

## Resultado

### Primera pasada

- `scripts/world/biome.gd`: `snow_color`.
- `scripts/world_generator.gd`: `snow_tint_paths`, `_snow_tint_nodes`, canal
  `"snow"` en `_mixed_biome_color()` y aplicación en `_update_biome_tint()`.

### Segunda pasada: la cima entera

- `assets/map/background/mountain2_snow.png` regenerado: brillo `184, 172, 171`
  → blanco puro; cara iluminada `161, 148, 147` → `222, 230, 242`; cara de
  sombra `107, 108, 122` → `150, 162, 180`; la vegetación teal queda fuera
  (alpha 0). Tres tonos, 39.554 px (antes 5.944).
- `nieve.tres`: `snow_color = (1, 1, 1)` y `rock_color = (0.92, 0.94, 0.98)`.

### Tercera pasada: cima original en el resto de biomas

- `Biome.snow_color` por defecto `(0.72, 0.66, 0.65)`: multiplicado sobre los
  tres blancos reproduce la cima del arte (≈ `184, 168, 166` donde había
  `184, 172, 171`), así que un bioma que no lo defina no cambia.
- `pradera.tres` `(0.715, 0.675, 0.625)` (toque verde) y `bosque_rojo.tres`
  `(0.74, 0.65, 0.625)` (toque cálido); `nieve.tres` sigue en `(1, 1, 1)`.
- Medido sobre los tres tonos: delta máximo 12/255 (4,7 %) en prado y bosque
  rojo; en nieve 98/255 (38 %) porque la cima pasa a blanco.
- Verificado headless con script desechable (canal `snow` de los tres `.tres`),
  `--check-only` en `world_generator.gd`/`biome.gd` y comparación numérica en
  PIL de los píxeles antiguos frente a los nuevos.
- Render medido en Godot (probe desechable que captura el viewport): el brillo
  blanco con `snow_color = (0.72, 0.66, 0.65)` sale `184, 168, 166`, es decir,
  el modulate multiplica en sRGB (no en lineal) y el valor reproduce el arte.
  F5 pendiente.
