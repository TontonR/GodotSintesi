# T-0079 · Interior explorable (tipo 3): mazmorra de 2 pisos con semilla

| Campo | Valor |
|---|---|
| Estado | `resuelto` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `buffy` |
| Sistema | world |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-27 |
| Relacionado | T-0075, [`planning-estructuras.md`](../planning-estructuras.md) |

## Problema

El tipo 3 del planning (interiores explorables) no tiene nada montado: hoy las estructuras
solo se estampan en el chunk. Este ticket hace el MVP autónomo de la mazmorra, sin tocar
`world_generator.gd`: se prueba sola en F6 y la puerta desde el mundo queda para un ticket
posterior. Boss, enemigos, loot y tienda están fuera de alcance.

## Plan

1. `scripts/world/dungeon_generator.gd` (`DungeonGenerator`): 2 pisos con semilla
   (`RandomNumberGenerator` propio, nunca `randi()`), salas de anchos variables separadas por
   muros con puerta, suelo y techo sólidos.
2. `scenes/structures/dungeon.tscn`: capas `Back`/`Walls`/`Floor` (TileSet construido en
   código desde el atlas de ruinas), `Exit` (`Area2D` + panel ámbar) y `spawn_point`.
3. `scenes/structures/dungeon_test.tscn` + `scripts/world/dungeon_test.gd`: harness de F6;
   coloca `player.tscn` en `spawn_point`, teclas 1/2 cambian de piso y la salida imprime.
4. `save_state()` / `load_state()` puros (`{seed, floor}`); sin tocar `scripts/save_game.gd`.
5. `docs/dungeon.md` y fila en el índice de `AGENTS.md`.

## Criterios de aceptación

- [x] `dungeon.tscn` genera 2 pisos con `start(seed, floor)` y la misma pareja repite el
      mismo layout.
- [x] API mínima: `start()`, `Marker2D` `spawn_point`, señal `exit_requested`.
- [x] La escena no instancia ni posee al jugador; `dungeon_test.tscn` lo coloca y la salida
      emite `exit_requested`.
- [x] `save_state()`/`load_state()` puros y sin tocar `scripts/save_game.gd`.
- [x] `docs/dungeon.md` (≤30 líneas) y fila en el índice de `AGENTS.md`.
- [ ] F6 de Ruben sobre `dungeon_test.tscn` (pendiente; no hay Godot en la sesión).
- [x] Entrada en `changelog.md` y `estado.md` al cerrar.

## Resultado

Hecho el 2026-11-24 (`buffy`) en `feat/estructura-explorable`; queda F5/F6 de Ruben.

- `scripts/world/dungeon_generator.gd`: 2 pisos (`rooms_per_floor` = [7, 9]), salas de
  8–22 tiles separadas por muros con puerta de 6 tiles, RNG `seed ^ (floor * 7919)`.
- `scenes/structures/dungeon.tscn`: `Back`/`Walls`/`Floor` con TileSet de código
  (atlas de ruinas `ruin_tiles_dark.png`/`ruin_tiles.png`, física de cuadro completo en
  suelo y muros, capa 1), `Exit` y `spawn_point` (30 px sobre el suelo de la primera sala).
- `scenes/structures/dungeon_test.tscn` + `scripts/world/dungeon_test.gd`: F6, teclas 1/2,
  imprime `Dungeon: exit requested on floor N.`.
- `save_state()`/`load_state()`: `{seed, floor}`; sin tocar `save_game.gd`.
- La puerta mundo→mazmorra se hizo en T-0087 (misma rama y PR); el estado por piso
  sigue pendiente (T-0080).
- **2026-11-24 (T-0088)**: tras el F5, el interior deja `ground_tile.png`; fondo, techo y
  muros usan ladrillo oscuro y el suelo piedra clara del atlas de ruinas.
- **No hay Godot CLI en la sesión**: no se pudo ejecutar F6 ni comparar layouts; el repaso
  fue de código. F6/F5 pendiente de Ruben.
