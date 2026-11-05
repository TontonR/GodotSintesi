# T-0024 · Fondos tintables y terreno por bioma

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `fix` + `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0023 (biomas por bloque), T-0016 (noche) |

## Petición

1. Regenerar los fondos de bosque y montaña: solo los colores verdes pasan a gris,
   algo más claro para que el tinte del bioma se vea. En la montaña, la punta no es
   verde y no se debe pintar.
2. El bosque rojo se veía negro de fondo en vez de rojo.
3. Que los biomas puedan exagerar la generación (ruido Perlin): por ejemplo, el bosque
   rojo con alturas más pronunciadas, con transiciones suaves.
4. Versionado y documentación al día.

## Causa

- `pine1.png` es `(27,45,45)` y `pine2.png` `(24,35,38)`: verde-teal muy oscuro. Las
  versiones `_gray` usaban el máximo de canal (~45), y `modulate` rojo sobre eso da un
  rojo casi negro. El color del bioma se aplicaba a un fondo que no estaba preparado.
- La montaña mezcla piedra clara `(161,148,147)`, sombra azulada `(107,108,122)` y
  bosque teal `(45,80,82)/(40,61,67)`. Teñir el sprite entero cambiaría también la
  punta, que no es vegetación.

## Plan

1. Script de Python temporal: detectar vegetación por hue 100–210° y saturación ≥ 0.12;
   pasar esos píxeles a `140 + 0.55 × max(R,G,B)` y dejar el resto igual.
2. `mountain2_gray.png`: solo el bosque teal, transparente en el resto; el sprite
   original se queda como piedra y la capa gris se tiñe aparte (`Sprite2DGreen`).
3. Bosques de fondo: usar `pine1_gray.png`/`pine2_gray.png` en `game.tscn`.
4. `Biome.terrain_amplitude_multiplier` y `terrain_frequency_multiplier`; el bosque rojo
   usa 1.7 y 1.25.
5. `_chunk_biome_data()` mezcla color y modificadores en la misma ventana de 256 bloques;
   `_height_at_with()` calcula la altura con los modificadores ya mezclados.

## Criterios de aceptación

- [x] En bosque rojo los pinos y el bosque de la montaña se ven rojos, no negros.
- [x] La punta/piedra de la montaña conserva su color original y no se tiñe.
- [x] El bosque rojo genera relieve más marcado y la transición es gradual.
- [x] Las alturas de dos chunks siguen coincidiendo en la costura.
- [x] `docs/world.md`, changelog, bitácora y estado actualizados.
- [ ] F5 en editor: color de fondos y relieve.

## Resultado

- Assets regenerados: `pine1_gray.png`, `pine2_gray.png`, `mountain2_gray.png`.
- `scenes/game.tscn`: pinos grises y overlay `mountains/Sprite2DGreen`.
- `scripts/world_generator.gd`: `forest_tint_paths` incluye el overlay, `_chunk_biome_data`,
  `_mixed_terrain`, `_terrain_at_tile`, `_height_at_with` y `_noise_height` con amplitud
  y frecuencia.
- `scripts/world/biome.gd` + `resources/world/biomes/bosque_rojo.tres`: modificadores de
  terreno por bioma.
- `docs/world.md` actualizado.

Verificado por inspección y revisión de las imágenes generadas; no se ha ejecutado Godot
(regla de `AGENTS.md`).
