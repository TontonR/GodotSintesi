# Objetos e inventario — estado

_2026-10-14 · rama `feat/items-demo` · 2026-10-20 · rama `feat/skills-and-complex-passives`_

## Jerarquía

`Items` → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` / `PassiveItems` → `AttackBonusPassive`, `DamageReductionPassive`, `RegenPassive`. `Skills` sigue en `Items` (equipamiento sin cablear). Pickup genérico: `item_pickup.gd/.tscn` con `@export var item: Items`.

## Huecos (5) y teclas

| Huecos | Tipo | Teclas (`use_slot_1..5`) |
|---|---|---|
| 1-2 | Skills (no se gastan) | 1, 2 |
| 3-5 | Consumibles (se gastan) | 3, 4, 5 |

- `Inventory.add_item` enruta por tipo; si la barra del tipo está llena, el objeto se queda en el suelo.
- Pasivas → `PlayerPassives`. Recogida automática al tocar (`body_entered`); F (`interact`) ya no recoge.

## Catálogo (6)

- Consumibles: `pocion_cura` +30 vida, `pocion_stamina` +40 stamina, `pocion_mayor` +60 vida.
- Pasivas: `amuleto_ataque` +6 daño, `armadura_ligera` −25% daño recibido, `talisman_regen` +1 vida/s.

## Drops

- `enemy_base.gd`: 1 objeto al azar del pool (75%) + monedas (100%); el `item` se asigna antes de `add_child`.
- Física (`item_pickup.gd`): gravedad 900, rebote 0.45 hasta <35 px/s, vaivén 1,5 px, `z_index` 1; suelo fijado en el primer tick.
- Tooltip de proximidad a 40 px (nombre + descripción); el HUD está en `docs/ui.md`.

## Debug (temporal, `scenes/inventory/inventory.gd`)

- Numpad `0` vacía inventario y pasivas; `1` añade un consumible aleatorio; `2` una pasiva aleatoria; `3` reservado para skills (aún sin objetos).
- Se añaden directamente (consumibles a los huecos 3-5, pasivas a `PlayerPassives`); si el inventario está lleno, el objeto se descarta.
- Para quitarlo: `DEBUG_TOOLS = false` (o borrar `_handle_debug_key`, `_clear_debug_items` y `_give_debug_item`).

## Pendiente

- `Skills`: `use()` llama a `equip()` pero el jugador no lo tiene; sin objetos skill.
- Intercambio con barra llena (hoy queda en el suelo).
- `player.tscn` legacy de la raíz sin `Inventory`/`PlayerPassives` (no se usa).
