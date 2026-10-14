# Objetos e inventario — diseño y estado

_2026-10-14 · rama `feat/items-demo`_

## Jerarquía

`Items` → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` / `PassiveItems` → `HealPassive`, `AttackBonusPassive`, `DamageReductionPassive`, `RegenPassive`.
`Skills` sigue en `Items` (equipamiento sin cablear). Pickup genérico: `item_pickup.gd/.tscn` con `@export var item: Items`.

## Decisiones cerradas

- **Consumibles: 3 huecos sueltos** en la barra (sin apilamiento; `max_stack` sin usar). **Barra llena: no pasa nada.**
- Destino según objeto: consumible → `Inventory`, pasiva → `PlayerPassives`.

## Catálogo de objetos (7)

| .tres | Tipo | Efecto |
|---|---|---|
| `pocion_cura` | Consumible | +30 vida (tecla 1/2/3) |
| `pocion_stamina` | Consumible | +40 stamina |
| `pocion_mayor` ("Elixir de vigor") | Consumible | +60 vida |
| `heal_potion_passive` | Pasiva | Cura 25 al recogerla |
| `amuleto_ataque` | Pasiva | +6 de daño por golpe |
| `armadura_ligera` | Pasiva | −25% del daño recibido |
| `talisman_regen` | Pasiva | +1 vida/segundo |

Texturas nuevas de `assets/items/` (16×16, aleatorias: item183/467/579/912).

## Cómo salen los objetos

- **Loot de enemigos (principal)**: `LootDropItem` tiene `item_pool: Array[Items]`; `enemy_base.gd` suelta `item_pickup.tscn` con un objeto **al azar** con **75% de probabilidad** al morir (además de monedas 100%). El `item` se asigna **antes de `add_child`** (si no, `_ready` no pinta el sprite).
- **Por zona**: `world_generator` solo spawnea orcos (4/zona) y fantasmas (1/zona).
- **Escena**: 3 drops fijos en `game.tscn` a **y=392** (x=110/150/190).

## Trampa de altura (BUG ENCONTRADO 2026-10-14)

El suelo generado está en `ground_level * 16` = **y=400** (`ground_level = 25`). Todo lo colocado en y=0 **queda en el aire, fuera de cámara** — por eso "no spawneaban" los drops. Los enemigos sueltan loot en su posición (sobre el suelo) por eso funciona. El `coin` legacy en `game.tscn (61, 0)` tiene el mismo problema (no tocado).

## Otros arreglos de hoy

- `ghost.tscn` tenía `loot_table` con una entrada **vacía** (override del editor) → los fantasmas no soltaban **nada**; eliminado, usan el default.
- Inputs: `interact` = **F**, `use_slot_1..3` = **1/2/3** (E ya era guardar).
- `Skills.gd`: enum `EquipSlot { NONE = 0 }` (antes el export no compilaba).
- Triggers en `player.gd`: pasivas modifican daño al atacar y al recibir.

## Pendiente

- Equipamiento (`Skills`): `use()` llama a `equip()` pero el jugador no lo tiene; bonuses sin aplicar.
- Prompt de interacción en pantalla ("F") y mantener-para-intercambiar con barra llena.
- `player.tscn` legacy de la raíz sin `Inventory`/`PlayerPassives` (no se usa).
