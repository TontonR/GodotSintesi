# T-0025 · Gris medio y verde original en la pradera

| Campo | Valor |
|---|---|
| Estado | `revision` (pendiente de F5) |
| Tipo | `fix` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-05 |
| Actualizado | 2026-11-05 |
| Relacionado | T-0024 (fondos tintables) |

## Petición

- El gris de los fondos de T-0024 quedó demasiado claro: bajarlo.
- Que el bioma de bosque normal (pradera) use el verde de antes.

## Qué se ha hecho

- Script de Python: el gris pasa de `140 + 0.55 × max(R,G,B)` (~165) a
  `100 + 0.35 × max(R,G,B)` (~113–129) para píxeles verdes/teal (hue 100–210°,
  saturación ≥ 0.12). Mismo criterio de vegetación; piedra y punta de la montaña
  siguen intactas.
- `Biome.forest_color` nuevo: tiñe solo `far_forest`, `near_forest` y
  `mountains/Sprite2DGreen`. La pradera usa `(0.233, 0.388, 0.388)`, que sobre el
  gris 116 da `(27, 45, 45)`, el verde-teal original del pino. El bosque rojo usa
  `(1, 0.32, 0.28)` para que el rojo se vea.
- El césped no cambia: sigue con `grass_color` `(0.72, 1, 0.28)` en la pradera.
- `_biome_tint_at_tile()` usa `forest_color`; `_chunk_biome_data()` sigue usando
  `grass_color` para los 257 colores del césped.

## Criterios de aceptación

- [x] El fondo del bosque normal recupera el verde oscuro anterior.
- [x] El gris ya no es tan claro (≈113–129 en vez de ≈165).
- [x] El bosque rojo sigue viéndose rojo, no negro.
- [x] Piedra y punta de la montaña siguen sin teñirse.
- [ ] F5 en editor: comparar pradera y bosque rojo.

## Resultado

- `assets/map/background/{pine1,pine2,mountain2}_gray.png` regenerados.
- `scripts/world/biome.gd`, `scripts/world_generator.gd`,
  `resources/world/biomes/{pradera,bosque_rojo}.tres` y `docs/world.md`.
- Comprobado con PIL que el tinte de pradera sobre el gris 116 da el color original
  (diferencia ≤ 1 por canal) y que el rojo conserva un canal ≥ 100.

Sin ejecutar Godot (regla de `AGENTS.md`): F5 pendiente.
