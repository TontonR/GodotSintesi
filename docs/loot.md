# Loot — coins, item drops and pickups

_2026-11-09 · 2026-11-12_

## Where it lives

- `EnemyBase._drop_loot()` (`scripts/enemies/enemy_base.gd`) runs on death and makes
  **two independent rolls**: coins and items.
- `EnemyBase._spawn_pickup()` instantiates `scenes/collectables/coin.tscn` for coins or
  the legacy root `item_pickup.tscn` for items (still alive, see `AGENTS.md`).
- `scripts/resources/loot_entry.gd` (`class_name LootEntry`, `Resource`): one item per
  table row with `item`, `drop_chance` (default 0.1), `min_amount` and `max_amount`
  (both 1).
- Data is **per enemy scene**, in its `item_drops: Array[LootEntry]` export. There are no
  shared pools or presets.

## Coin roll

- `coin_drop_chance` (default **0.45**) + luck + coin passives; the result is clamped to 1.
- If it succeeds, `coin_drop_amount` coins (default 1) are spawned. Each coin is worth
  `coin_value` 1.
- Luck: `EnemyBase._luck_drop_bonus()` returns `player.luck × 0.01`, so 5 luck = +5
  percentage points.
- Coin passives: every active passive with `get_coin_drop_bonus()` adds its percentage
  (`piedra_oro` = +10 %).
- The world generator also spawns **2 coins per chunk** (`coins_per_chunk`) directly, 40 px
  above the ground; those are independent from the enemy roll.

## Item roll

- One single roll for the whole table: the total chance is the **sum** of every entry's
  `drop_chance` (orc: 10+10+10+10+2 = **42 %**). If the roll fails, nothing drops.
- If it succeeds, exactly **one** item type is chosen weighted by its `drop_chance`; two
  different items from the same enemy cannot drop together. Then
  `randi_range(min_amount, max_amount)` copies are spawned (all of the same item).
- `_available_drops()` filters out: null entries, entries without an item, entries with
  `drop_chance <= 0` and **passives the player already owns** (collectables do not repeat;
  consumables are not filtered).
- Luck is added **again** to the item roll (`minf(total + luck, 1)`), even though the
  probabilities are already summed.

## Current tables (scene `item_drops`)

| Enemy | Entries (chance) | Total |
|---|---|---|
| Orc | Loincloth 10 %, Mace 10 %, Ogre Nail 10 %, Iron Pendant 10 %, Gold Stone 2 % | 42 % |
| Werewolf | Wolf Pelt 10 %, Wolf Fang 10 %, Wolf Claws 10 %, Werewolf DNA 2 % | 32 % |
| Mutant toad | Frog Saliva 10 %, Frog Tongue 10 %, Frog Bubble 10 %, Skin Tubercles 2 % | 32 % |
| Slime | Mucus 10 %, Mucus Potion 10 %, Compact Mucus 10 %, Mucus Heart 2 % | 32 % |
| Skeleton, archer, ghost, demon | — (no `item_drops`) | 0 |

The items themselves (stats, effects, quality) are catalogued in
[`docs/passives.md`](passives.md) and [`docs/items.md`](items.md).

## Spawn position

- The pickup is parented to the enemy's parent **first** and then receives
  `global_position`: assigning it before parenting added the chunk offset twice.
- Offset of ±15 px in X and Y (`loot_drop_spread` / `loot_drop_y`) around the corpse.
- Items get the item assigned before entering the tree (`pickup.set("item", item)`), so
  `_ready()` can already paint the icon.

## Pickup physics

- **Items** (`item_pickup.gd`): gravity 900, initial hop 150 px/s, bounce 0.45 while the
  impact exceeds 35 px/s, idle bob 1.5 px at 2.5 rad/s, `z_index` 1. Ground is searched
  **once** by raycast on the first physics tick (1024 px down). Auto pickup on
  `body_entered` with the player; the item's `on_pickup()` decides slot/passive and returns
  false if the inventory is full (the pickup stays).
- Lifetime: 60 s since spawn, but the 30 s "seen" clock only runs while the pickup is
  inside the camera; it blinks for the last 5 s (`BLINK_START` 25, `SEEN_LIFETIME` 30).
  A tooltip with name and description appears when the player is near.
- **Coins** (`scripts/collectables/coin.gd`): gravity 900, bounce 0.4 while > 40 px/s,
  settle + 1 px bob; ground searched by raycast with up to 30 retries while the freshly
  painted chunk registers its collision. Touching gives `add_coin(coin_value)` and fires
  `fx.coin_pickup()`.
- Both live on the chunk node and are freed with it (after `KEEP_CHUNKS_SIDE` = 2 chunks).

## Persistence

- Enemy deaths and coin pickups emit `died` / `collected`; the generator stores the stable
  spawn ids (`e:x:y:index`, `c:x:y:index`) and does not instantiate them again.
- `save_persistent_state()` returns those ids and `SaveGame` writes them under `[world]`;
  `_ready()` restores them before instancing chunks on Continue.
- Item pickups have no id: a dropped item that was not picked up is not saved and will not
  come back (the enemy that dropped it is already dead).

## Traps

- Ground is at y≈800: anything spawned at y=0 needs gravity to reach it (and the legacy
  `coin` node in `game.tscn` is still wrong).
- A drop that flickers at ~7 Hz means the ground ray is being cast every frame instead of
  once: keep the cached `_ground_y` comparison.
- Don't use `loot_table`: the field is `item_drops`, and an empty array is valid.
