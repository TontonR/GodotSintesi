class_name LootEntry
extends Resource
## A single item in an enemy's loot table, with its own drop chance.

## Item resource dropped when the roll succeeds.
@export var item: Items
## Probability of dropping this item (each entry rolls independently).
@export_range(0.0, 1.0, 0.01) var drop_chance: float = 0.1
## Minimum amount dropped when the roll succeeds.
@export var min_amount: int = 1
## Maximum amount dropped when the roll succeeds.
@export var max_amount: int = 1
