# Shop — merchant stalls

_2026-11-27 · branch `feat/estructuras-detras-castillo-grande` · T-0078_

## What it does and where it lives

- `scenes/shop/merchant.tscn` + `scripts/world/merchant.gd` (`Merchant`): type 1 world
  structure (`resources/world/structures/shop_test.tres`, `display_name` **Test Shop**),
  listed in `WorldGenerator.structures` and placed by the biomes' `structure_kinds`
  (Meadow and Red Forest, chance 0.2).
- It is a `scene` structure: `pixel_size` 96 / `size_tiles` 6 → drawn at 96 px with
  `assets/map/structures/merchant_stall.png`, `flatten_ground`, 4 px sunk and `z_index` −1
  (behind the ground and the player, like every sprite structure).
- `scripts/ui/shop_screen.gd` (`ShopScreen`, `CanvasLayer` 12): **built in code**, there is
  no `.tscn` for the editor to reserialize.

## The stall

- `Merchant._ready()` joins the `merchant` group and rolls `STOCK_SIZE` (3) different
  consumables from `CATALOG` with `hash("merchant:x:y")`: the same stall always sells the
  same items after a chunk reload, and the chunk RNG is never touched.
- Prompt `F: shop` (its own `CanvasLayer` 8 label) when the player is within
  `PROMPT_RADIUS_PX` (56 px); F builds the window and opens it.
- The window is added to the game scene, not to the merchant, so unloading the chunk with
  the shop open cannot free it while the tree is paused.
- Sold items live in `Merchant.sold` while the node lives. A chunk unload forgets them:
  **there is no per-stall save yet**.

## Prices and stock

- `Merchant.price_of()` derives the price from the stats: `max(5, round((heal + stamina) / 4))`
  → 20 points cost 5, 50 cost 13, 100 cost 25; special effects without numbers cost 20.
  Retuning a potion retunes its price, no table to keep in sync.
- Buying checks, in this order: coins (`Player.current_coins`), a free slot
  (`Inventory.MAX_SLOTS`), charge (`Player.spend_coins()`), `Inventory.add_item()`.
  Failures say `Not enough coins` / `No free slot`; nothing is charged twice.
- **No re-buy**: a bought row stays disabled as `sold` (the planning's fallback scope).

## Window

- Pauses the tree (`get_tree().paused = true`) and runs `PROCESS_MODE_ALWAYS`; `_exit_tree`
  unpauses, so a freed scene never leaves the game frozen.
- Keys: W/S or up/down to pick, E/Enter or a click to buy, F or Esc to leave. `_input_lock`
  (0.2 s) stops the F that opened the window from buying anything.
- `docs/ui.md` conventions still apply: the panel is 232×156 px so it fits the 384×216
  viewport, small fonts (9/11) and the meadow green (`0.72, 1, 0.28`) marks the selection.

## Not done yet

- Safe zone: enemies keep walking and can hit you at the stall, and the hit waits while the
  tree is paused. Pending in **T-0101** along with the sold stock below.
- Stock is the same catalogue for every biome; no rarity tiers, no exclusive items (T-0083,
  T-0084) and no art from Jorge (T-0085).
- Reopening a stall after its chunk was unloaded gives the stock back (**T-0101**: `[world]
  sold` keyed by `spawn_id`, like `broken`).

## Safe zone and sold stock (2026-11-27, T-0104)

- **Safe zone:** while an enemy is within `SHOP_SAFE_RADIUS` (96 px) of a node in the
  `merchant` group it stops chasing and attacking: `EnemyBase._in_shop_zone()` runs before the
  attack branch and just brakes, so the stall can be used without a fight on top of it.
- **No re-buy:** the stock is deterministic (`hash("merchant:x:y")`), so a chunk reload would
  hand the same three items again. `Merchant.mark_sold()` now reports the purchase to the
  generator (`mark_item_sold(spawn_id, resource_path)`), which keeps it in `_sold_spawns` and
  writes it in `save_persistent_state()["sold"]`. On spawn, `restore_sold()` re-marks what the
  run already bought.
- The world link is resolved through the chunk (`get_parent().get_parent()`), so the stall
  keeps no hard reference to `WorldGenerator`.
