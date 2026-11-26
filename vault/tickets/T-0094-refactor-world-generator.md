# T-0094 — Refactor: separar responsabilidades de world_generator.gd

_Creado 2026-11-25 · actualizado 2026-11-26 · rama `refactor/world-split`_

## Problema

`world_generator.gd` tiene 1654 líneas y mezcla sin separación:
- Gestión de chunks (carga/descarga/streaming)
- Generación de terreno (noise, alturas, left wall)
- Lógica de biomas (runs, transiciones, colores)
- Lógica de decoración (pick, tinting, foliage)
- Spawning de entidades (enemigos, coins, crates, structures)

Esto dificulta el mantenimiento, la lectura y el testeo.

## Solución

Extraer tres clases auxiliares que `WorldGenerator` instancia e invoca. No hay cambio de comportamiento.

| Clase nueva | Archivo | Responsabilidad |
|---|---|---|
| `WorldBiomeManager` | `scripts/world/world_biome_manager.gd` | Runs de biomas, transiciones, colores, terreno mixto |
| `WorldDecorManager` | `scripts/world/world_decor_manager.gd` | Pick de decor, foliage tinting, dead tree ratio |
| `WorldSpawner` | `scripts/world/world_spawner.gd` | Spawn de enemigos, coins, structures, crates en un chunk |

`WorldGenerator` mantiene: chunk streaming, terrain height, left wall, `_generate_chunk`, API pública (`ground_y_at`, `biome_at_world_x`, etc.). Sin cambios de señales ni exports visibles desde escena.

## Criterios de éxito

- El mundo se genera igual con la misma semilla antes y después.
- No hay errores en el output de Godot.
- `world_generator.gd` queda < 700 líneas.
- Cada archivo nuevo < 600 líneas (el criterio inicial era 400; `WorldSpawner` son
  525 porque agrupa una sola responsabilidad —rodar y instanciar entidades— y
  partirla habría añadido una clase sin ganancia).

## Estado

- [x] Extraer `WorldBiomeManager`
- [x] Extraer `WorldDecorManager`
- [x] Extraer `WorldSpawner`
- [x] Limpiar `world_generator.gd`
- [x] Verificar sin errores (revisión estática; no hay Godot CLI en la sesión)
- [ ] F5 de Ruben con la misma semilla y sin errores en el output
- [ ] Commitear y PR (rama apilada sobre `feat/vfx-ambiente-spritefusion`)

## Resultado

Hecho el 2026-11-26 en `refactor/world-split`:

- `world_generator.gd` pasa de 1654 a 677 líneas y conserva el streaming de chunks,
  la altura del terreno, la montaña izquierda y la API pública (`ground_y_at`,
  `biome_at_world_x`, `meters_at`, `save_persistent_state`…). Los exports de escena
  no cambian.
- `WorldBiomeManager` (288 líneas), `WorldDecorManager` (211) y `WorldSpawner` (525)
  son `RefCounted` con `class_name`, se construyen en `_ready`
  (`_build_biome_manager`/`_build_decor_manager`/`_build_spawner`) y reciben sus
  dependencias por campos: el decor manager apunta al biome manager y el spawner al
  decor manager (lo usa para tints y tilesets de estructura).
- Revisión estática: 0 llamadas a funciones movidas sin cualificar, 0 funciones
  privadas inexistentes y los ids de guardado (`defeated`/`collected`/`broken`)
  idénticos a los de antes.
- **Conflicto con T-0095 (VFX) resuelto**: `ambient_weight_at_world_x()` y
  `AMBIENT_BLEND_TILES` viven ahora en `WorldBiomeManager`; `WorldGenerator` deja un
  delegado de 2 líneas porque `biome_particles.gd` lo busca por el grupo
  `world_generator`. La rama se ha rebanado encima de
  `feat/vfx-ambiente-spritefusion` para no duplicar sus commits.
- `docs/world.md` gana la sección **Architecture**; `docs/biomes.md` aclara el
  delegado.

Falta el F5 de Ruben: cargar una partida vieja y una nueva con la misma semilla y
comprobar que el mundo, el decor, las estructuras, las cajas y los enemigos salen
igual que antes del refactor.

## Archivos tocados

- `scripts/world_generator.gd`
- `scripts/world/world_biome_manager.gd` (nuevo)
- `scripts/world/world_decor_manager.gd` (nuevo)
- `scripts/world/world_spawner.gd` (nuevo)
- `docs/world.md`, `docs/biomes.md`
- `.gitignore` (los `.uid` de los managers se versionan; `assets/downloads/` se ignora)
