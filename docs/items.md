# Objetos e inventario — diseño y estado

_2026-10-14 · rama `feat/items-demo`_

## Jerarquía

`Items` → `Collectable` (`on_pickup(player) -> bool`) → `Consumable` / `PassiveItems` → `AttackBonusPassive`, `DamageReductionPassive`, `RegenPassive`.
`Skills` sigue en `Items` (equipamiento sin cablear). Pickup genérico: `item_pickup.gd/.tscn` con `@export var item: Items`.

## Huecos y teclas (5 huecos)

| Huecos | Tipo | Teclas (`use_slot_1..5`) |
|---|---|---|
| 1-2 | **Skills** (no se gastan al usarlas) | 1, 2 |
| 3-5 | **Consumibles** (se gastan al activarse) | 3, 4, 5 |

- `Inventory.add_item` enruta por tipo: `Skills` → 1-2, resto → 3-5; barra llena de su tipo = **no pasa nada**.
- Destino fuera del inventario: pasivas → `PlayerPassives`. Las skills sin `on_pickup` entran por fallback en `item_pickup.gd`.
- Entradas nuevas: `use_slot_4` (tecla 4), `use_slot_5` (tecla 5). `interact` = F.

## HUD (2026-10-14, más compacto)

- `ConsumableBar` (`InventoryUI`) **arriba-izquierda**: huecos 18×18 (iconos 16 a 1:1), separación 2, borde 1 px; separador de 4 px entre skills (borde azulado) y consumibles.
- Vida/stamina **arriba-derecha**: barras 94×12 (antes 120×20), fuentes 10 (antes 14), borde 1 px. Monedas: fuente 10.
- **Pasivas** (`PassiveUI` en `UILayer/PassiveBar`, arriba-derecha bajo las barras): columna de iconos 12×12 con alpha 0.55 (preview estilo The Binding of Isaac). `PlayerPassives` emite `passives_changed` y enlaza la lista en `_ready` (mismo patrón que Inventory con su barra).

## Catálogo de objetos (6)

| .tres | Tipo | Efecto |
|---|---|---|
| `pocion_cura` | Consumible | +30 vida |
| `pocion_stamina` | Consumible | +40 stamina |
| `pocion_mayor` ("Elixir de vigor") | Consumible | +60 vida |
| `amuleto_ataque` | Pasiva | +6 de daño por golpe |
| `armadura_ligera` | Pasiva | −25% del daño recibido |
| `talisman_regen` | Pasiva | +1 vida/segundo |

Eliminada `heal_potion_passive.tres` + `HealPassive.gd` (2026-10-14, git lo conserva).

## Cómo salen los objetos

- **Loot de enemigos**: `LootDropItem.item_pool` con los 6 objetos; `enemy_base.gd` suelta `item_pickup.tscn` con uno **al azar** con **75% de probabilidad** (además de monedas 100%). El `item` se asigna **antes de `add_child`**.
- **Escena**: 2 drops en `game.tscn` a y=350 (x=110/150); la pasiva curación fue eliminada.

## Física de los drops (`item_pickup.gd`)

- **Gravedad** 900 px/s² → cae hasta el suelo (raycast contra capa 1, la física de los `TileMapLayer` está en `physics_layer_0/collision_layer = 1`).
- **Rebote**: restitución 0.45; por debajo de 35 px/s de impacto se asienta.
- **Vaivén**: al asentarse, `sin(t·2.5 + fase)` con amplitud 1.5 px y fase aleatoria (bucle sutil, no sincronizado).
- Si no encuentra suelo cerca, flota donde aparece (evita caer al vacío).

## Trampa de altura (BUG 2026-10-14)

El suelo generado está en `ground_level * 16` = **y=400** (`ground_level = 25`). Todo lo colocado en y=0 quedaba en el aire fuera de cámara: por eso "no spawneaban" los drops (y el editor revirtió un arreglo a y=392 antes del primer commit — ahora la gravedad lo auto-corrige). Los enemigos sueltan loot a su altura. El `coin` legacy en `game.tscn (61, 0)` sigue con ese problema (no tocado).

## Otros arreglos

- `ghost.tscn`: override de `loot_table` con entrada vacía eliminado (antes los fantasmas no soltaban nada).
- `Skills.gd`: enum `EquipSlot { NONE = 0 }` (antes el export no compilaba).
- Triggers en `player.gd`: pasivas modifican daño al atacar y al recibir.

## Pendiente

- Equipamiento (`Skills`): `use()` llama a `equip()` pero el jugador no lo tiene; bonuses sin aplicar. Huecos 1-2 funcionales pero sin objetos skill que poner.
- Prompt de interacción en pantalla ("F") y mantener-para-intercambiar con barra llena.
- `player.tscn` legacy de la raíz sin `Inventory`/`PlayerPassives` (no se usa).
