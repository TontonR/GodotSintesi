# T-0076 · Cajas rompibles (vida, drop y "ya roto")

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `feat` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | world |
| Rama | `feat/bloques-rompibles` |
| Creado | 2026-11-24 |
| Actualizado | 2026-11-24 |
| Relacionado | T-0074, T-0075, [`planning-estructuras.md`](../planning-estructuras.md) |

## Problema

Las ruinas de T-0075 son decorado sólido: se saltan, pero no hay nada que se pueda
romper. El planning (fase A, 24 nov) pide **bloques rompibles con vida, drop y estado
persistido** para que las estructuras den algo más que un muro de fondo.

## Plan

1. `scripts/world/breakable_block.gd` (`BreakableBlock`, `StaticBody2D`): `max_health`,
   `take_damage(amount)`, drop de monedas al romperse y señal `broken(id)`. Capa de
   colisión 5 (mundo 1 + enemigos 4) para que el ataque del jugador (máscara 12) lo
   alcance; sin máscara, no colisiona con nada.
2. `scenes/world/breakable_block.tscn`: sprite de 16×16 con el origen en la base y caja
   de 16×16. Textura **placeholder** (madera dibujada); el arte definitivo lo genera
   PixelForge en T-0086 y solo cambia el PNG.
3. `WorldGenerator`: `crate_scene` + `crates_per_ruin`; `_roll_structures()` sortea
   columnas libres dentro de la ruina (fuera de piedras del frente, vigas, X de enemigos
   y chunk 0, que es el spawn) y guarda `crates` en la entrada.
4. `_spawn_chunk_entities()` instancia las cajas en `Entities`, les pone el id estable
   `b:x:y:tile` y conecta `broken` para marcarlas.
5. Persistencia: `_broken_blocks` → clave `broken` en `save_persistent_state()` y
   `_restore_persistent_state()` (mismo patrón que `defeated`/`collected`).
6. `docs/world.md` § Breakable blocks.

## Criterios de aceptación

- [x] Hay cajas dentro de las ruinas, sólidas y a la altura del suelo (ni flotan ni se
      entierran).
- [x] Dos golpes del jugador (40 de vida con 20 de daño) las rompen y sueltan 1–3
      monedas.
- [x] Una caja rota no reaparece al recargar la partida; la misma semilla pone las mismas
      cajas.
- [x] No pisa piedras del frente, vigas, enemigos ni el spawn del chunk 0.
- [x] `docs/world.md` actualizado, más `changelog.md` y `estado.md` al cerrar.

## Resultado

Hecho el 2026-11-24 (`opencode-jorge`); falta F5.

- `scripts/world/breakable_block.gd` (`BreakableBlock`, `StaticBody2D`): 40 de vida
  (`max_health`), `take_damage()` con destello y polvo, drop de 1–3 monedas
  (`coin.tscn`) y señal `broken(id)`. Capa 5 (mundo + enemigos) para que el ataque del
  jugador (máscara 12) lo alcance; máscara 0, así que no empuja a nadie.
- `scenes/world/breakable_block.tscn`: sprite 16×16 con el origen en la base y caja de
  16×16. Textura `assets/map/structures/crate.png` (placeholder de madera).
- `WorldGenerator`: `crate_scene` + `crates_per_ruin` (2). `_crate_tiles()` sortea
  columnas dentro de la ruina, sobre la fila de suelo, descartando piedras del frente,
  sus vecinas, la X de los enemigos y el chunk 0 (spawn). Id `b:chunk_x:chunk_y:tile_x`.
- `_spawn_chunk_entities()` instancia las cajas en `Entities` (delante del muro oscuro),
  salta las rotas y conecta `broken`.
- Persistencia: `_broken_blocks` → `save_persistent_state()`/`_restore_persistent_state()`
  y clave `world/broken` en `save_game.gd` (las partidas viejas cargan vacío).

Comprobado en headless con la semilla 775344231 (chunks 1–40): 10 ruinas con cajas, 18
cajas, 0 fuera del ancho de la ruina, encima de una piedra o fuera del chunk; la ruta real
de spawn monta una caja en la fila de suelo del chunk 4; la escena instancia con sprite,
caja, capa 5 y 40 de vida; `scenes/game.tscn` arranca 180 frames sin errores. F5 pendiente
(romper una caja, ver las monedas y recargar partida). El arte definitivo llega en T-0086.
