# T-0008 · Mundo: biomas/zonas, densidad y variedad de spawns

| Campo | Valor |
|---|---|
| Estado | `abierto` |
| Tipo | `feat` |
| Prioridad | `baja` |
| Dueño | `sin asignar` |
| Sistema | world |
| Creado | 2026-11-03 |
| Actualizado | 2026-11-03 |
| Relacionado | T-0001, T-0007 |
| Ficheros | `scripts/world_generator.gd`, `scripts/world/chunk.gd`, `scenes/game.tscn` |

## Situación

- Un solo bioma: todos los chunks usan el mismo `TileSet` y `enemy_counts_per_chunk = [4 orcos, 1 fantasma]` + 8 monedas por chunk de 256×140.
- `docs/world.md` deja el punto de extensión preparado: elegir configuración en `_generate_chunk` y pasar tiles/spawns a `WorldChunk.paint`.
- Con T-0001 entran 3 enemigos más: si se suman 1 de cada uno, el chunk pasa de 5 a 8 enemigos sin cambiar el tamaño.

## Decisiones

- ¿Zonas por índice global (como hacía la rama del compañero con `current_player_zone`) o biomas por chunk con transición? El generador por chunks ya tiene `_generate_chunk` como sitio natural.
- Densidad objetivo por chunk una vez haya 5 tipos; hoy no hay curva de dificultad por distancia.
- El inicio es plano (`safe_start_tiles` 50 + 24 de transición): decidir si el primer bioma es siempre pradera.

## Plan

1. Definir una tabla de biomas (tiles de superficie/relleno, enemigos, monedas).
2. Implementar la elección por chunk y pasar la configuración a `WorldChunk.paint`.
3. Verificar costuras entre biomas distintos (el chunk pinta una columna extra para tapar la grieta de 1 px).
4. Medir densidad real en una semilla fija y ajustar conteos.

## Criterios de aceptación

- [ ] Al menos 2 biomas distinguibles y un criterio de transición documentado.
- [ ] Spawns por bioma coherentes con `safe_start_tiles`.
- [ ] `docs/world.md` actualizado con la tabla de biomas.

## Resultado

Pendiente.
