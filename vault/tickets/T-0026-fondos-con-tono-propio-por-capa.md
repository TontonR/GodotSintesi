# T-0026 · Cada fondo con su propio tono (no los tres iguales)

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0025 (gris medio), T-0024 (fondos tintables) |

## Petición

- Tras T-0025 los tres fondos (montaña, pino lejano y pino cercano) se veían del
  mismo color porque compartían el mismo gris y el mismo `forest_color`.
- Antes cada capa era más oscura que la siguiente: mantener esa diferencia.
- Que se diferencien en todos los colores (pradera y bosque rojo).

## Qué se ha hecho

- Gris calibrado por capa en los assets:
  - `pine2_gray.png` (pino cercano): 92.
  - `pine1_gray.png` (pino lejano): 116.
  - `mountain2_gray.png`: 172 y 211, sus dos tonos de bosque (82→211, 67→172).
- El gris de cada capa se eligió para que, con el `forest_color` de la pradera
  `(0.233, 0.388, 0.388)`, el resultado devuelva el tono original de esa capa:
  cercano `(21, 36, 36)`, lejano `(27, 45, 45)`, montaña `(40, 67, 67)` y
  `(49, 82, 82)`.
- El bosque rojo `(1, 0.32, 0.28)` multiplica esos mismos grises, así que mantiene
  los tres escalones: `(92, 29, 26)`, `(116, 37, 32)`, `(172, 55, 48)` y
  `(211, 68, 59)`.
- Sin cambios de código: la diferencia va en los assets; `forest_color` y
  `_biome_tint_at_tile()` siguen igual.

## Criterios de aceptación

- [x] Los tres fondos tienen colores distintos en la pradera.
- [x] Los tres fondos tienen colores distintos en el bosque rojo.
- [x] El pino cercano sigue siendo el más oscuro y la montaña la más clara.
- [x] Comprobado con PIL: diferencia entre capas ≥ 20 sumando canales.
- [ ] F5 en editor: revisar que se distingan bien en pantalla.

## Resultado

- `assets/map/background/{pine1,pine2,mountain2}_gray.png` regenerados y
  `docs/world.md` actualizado, más vault.

Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente.
