class_name LootDropItem
extends Resource

@export var item_scene: PackedScene
@export_range(0.0, 1.0, 0.05) var drop_chance: float = 1.0
@export var min_amount: int = 1
@export var max_amount: int = 1
## Si la escena tiene la propiedad `item` (ItemPickup), aquí va el objeto:
## se elige uno al azar del pool en cada suelta.
@export var item_pool: Array[Items] = []

func _init(
	p_scene: PackedScene = null,
	p_chance: float = 1.0,
	p_min: int = 1,
	p_max: int = 1,
	p_items: Array[Items] = []
) -> void:
	item_scene = p_scene
	drop_chance = p_chance
	min_amount = p_min
	max_amount = p_max
	item_pool = p_items
