# T-0037 · Loot por enemigo sin presets

| Campo | Valor |
|---|---|
| Estado | `revision` |
| Tipo | `cambio` |
| Prioridad | `alta` |
| Dueño | `opencode-jorge` |
| Sistema | enemies |
| Creado | 2026-11-09 |
| Actualizado | 2026-11-09 |
| Relacionado | T-0019 |

## Problema

El loot se elegía con `loot_preset` + `PRESET_POOLS` en `EnemyBase`, con una única
probabilidad global de objeto (`item_drop_chance`) y pesos por calidad
(`rare_loot_weight`). Ruben quiere control por enemigo: cada escena con su tabla y
cada objeto con su propia probabilidad, sin presets compartidos.

## Plan

1. Nuevo `LootEntry` (`item`, `drop_chance`, `min_amount`, `max_amount`).
2. `EnemyBase`: `@export var item_drops: Array[LootEntry]`; `_build_loot_table()` crea
   una entrada de `ItemPickup` por objeto. Fuera `PRESET_POOLS`, `loot_preset`,
   `loot_pool`, `item_drop_chance`, `rare_loot_weight` y `_pick_loot`.
3. Pasar los pools actuales a `item_drops` en `orc.tscn`, `werewolf.tscn`,
   `mutant_toad.tscn` y `slime.tscn`.

## Criterios de aceptación

- [ ] En F5 cada enemigo suelta según su propia tabla y cada objeto tira por separado.
- [x] `docs/items.md` y `docs/enemies.md` actualizados.
- [x] Entrada en `changelog.md` y `estado.md`.

## Resultado

`scripts/resources/loot_entry.gd` nuevo. `enemy_base.gd` simplificado: `_drop_loot()`
hace dos tiradas separadas. Monedas: `coin_drop_chance` + `coin_drop_amount` (puede ser
más de una). Objetos: las `drop_chance` se suman en una única tirada y, si sale, se elige
un objeto ponderado por su probabilidad (30 % + 10 % = 40 %). En las cuatro escenas, los
objetos quedan con 10 % (Normal) y 2 % (Raro); la moneda sigue con 45 %.

Trampa: una `Array[LootEntry]` escrita tal cual en el `.tscn` carga vacía. El
elemento de un array tipado de script se serializa como
`Array[ExtResource("<id_del_script>")]([...])`; así ya aparece en el inspector.
F5 pendiente.
