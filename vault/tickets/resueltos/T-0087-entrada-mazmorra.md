# T-0087 · Entrada a la mazmorra desde el mundo (bloque negro + F)

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0079, [`planning-estructuras.md`](../planning-estructuras.md) |

## Problema

T-0079 dejó la mazmorra autónoma y sin puerta: en el mapa no hay nada que indique
dónde entrar. Este ticket la engancha al mundo sin cambiar de escena, con un
placeholder (bloque negro) y la tecla F (acción `interact`).

## Plan

1. `scenes/structures/dungeon_entrance.tscn` + `scripts/world/dungeon_entrance.gd`
   (`DungeonEntrance`): bloque negro de 48×96, `Area2D` y aviso "F: enter"; F llama
   a `DungeonLayer.enter()`.
2. `scripts/world_generator.gd`: una puerta fija en el chunk 0 (`safe_start_tiles + 8`)
   y una tirada por chunk (`dungeon_entrance_chance` 0.2). La tirada va **después** de
   enemigos, monedas y decor para no moverlos.
3. `scenes/game.tscn`: nodo `DungeonLayer` + `scripts/world/dungeon_layer.gd`, que
   oculta y pausa `map`, instancia `dungeon.tscn` y teletransporta al jugador; la salida
   (`exit_requested`) devuelve al mundo en el mismo punto.
4. `docs/dungeon.md` y vault.

## Criterios de aceptación

- [x] Hay una puerta negra visible junto al spawn y otras repartidas por chunk.
- [x] F dentro del área entra en la mazmorra; la salida vuelve al mundo sin cambiar de escena.
- [x] La vida, monedas, inventario y semilla sobreviven al viaje (no se recarga la escena).
- [x] La generación existente (enemigos, monedas, decor) no cambia de posición.
- [ ] F5/F6 de Ruben (pendiente; sin Godot en la sesión).
- [x] `docs/dungeon.md` actualizado y entradas en changelog/estado.

## Resultado

Hecho el 2026-11-24 (`buffy`) en `feat/estructura-explorable`; falta F5.

- `scripts/world/dungeon_entrance.gd` + `scenes/structures/dungeon_entrance.tscn`.
- `scripts/world_generator.gd`: `dungeon_entrance_scene`, `dungeon_entrance_chance` 0.2,
  `first_dungeon_entrance_offset_tiles` 8; datos `entrances` por chunk con semilla
  `_seed ^ (tile * 7919)`; instanciación al final de `_spawn_chunk_entities`.
- `scripts/world/dungeon_layer.gd` + nodo `DungeonLayer` en `scenes/game.tscn`.
- Pendiente: guardar dentro de la mazmorra sigue guardando coordenadas de mazmorra
  (T-0080); F5/F6 de Ruben.
