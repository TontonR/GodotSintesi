class_name BreakableBlock
extends StaticBody2D
## Breakable crate inside the ruins: a few sword hits break it, it drops coins
## and sometimes a consumable, and it stays broken for the rest of the run (the
## generator persists the ids).

## Emitted when it breaks, with the stable id the generator assigned to it.
signal broken(spawn_id: String)

## Fallback consumable pool, one picked at random when `item_pool` is empty.
const CONSUMABLE_PATHS: Array[String] = [
	"res://resources/pocion_cura.tres",
	"res://resources/pocion_cura_menor.tres",
	"res://resources/pocion_stamina.tres",
	"res://resources/pocion_stamina_mayor.tres",
	"res://resources/pocion_mayor.tres",
	"res://resources/bebida_tonificante.tres",
	"res://resources/esencia_vital.tres",
	"res://resources/elixir_vida.tres",
	"res://resources/pocion_mocos.tres",
]

## Sword hits it takes to break it (the base hitbox deals 20 damage).
@export var max_health: float = 40.0

@export_group("Drops")
## Minimum coins dropped when it breaks.
@export var coin_min: int = 1
## Maximum coins dropped when it breaks.
@export var coin_max: int = 3
## Chance (0-1) that it also drops one consumable.
@export_range(0.0, 1.0, 0.05) var item_drop_chance: float = 0.3
## Horizontal spread of the drops, in px.
@export var drop_spread: float = 8.0
## Coin scene; the same collectable the enemies drop.
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
## Pickup scene for the consumable (the legacy root `item_pickup.tscn`).
@export var item_scene: PackedScene = preload("res://item_pickup.tscn")
## Consumables it can drop; empty uses `CONSUMABLE_PATHS`.
@export var item_pool: Array[Items] = []

## Stable id assigned by the generator (`b:chunk_x:chunk_y:tile_x`).
var spawn_id: String = ""

var _health: float


func _ready() -> void:
	_health = max_health


## Same entry point the player uses for any non-enemy target.
func take_damage(amount: float) -> void:
	_health -= amount
	if _health <= 0.0:
		_play_fx("crate_break")
		_drop_coins()
		_drop_item()
		broken.emit(spawn_id)
		queue_free()
		return
	_play_fx("crate_hit")
	_flash()


## Effects come from the shared `fx` node, through the group (no hard reference).
func _play_fx(method: String) -> void:
	var fx := get_tree().get_first_node_in_group("fx")
	if fx and fx.has_method(method):
		fx.call(method, global_position + Vector2(8.0, -8.0))


## Brief white flash so a hit reads even without a damage number.
func _flash() -> void:
	var sprite := get_node_or_null("Sprite2D") as Sprite2D
	if sprite == null:
		return
	sprite.modulate = Color(2.0, 2.0, 2.0)
	create_tween().tween_property(sprite, "modulate", Color.WHITE, 0.12)


func _drop_coins() -> void:
	if coin_scene == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	for _i in randi_range(coin_min, coin_max):
		var coin := coin_scene.instantiate() as Node2D
		if coin == null:
			continue
		parent.add_child(coin)
		coin.global_position = global_position + Vector2(
			8.0 + randf_range(-drop_spread, drop_spread),
			-8.0
		)


## One roll for a consumable, independent from the coins (like the enemies).
func _drop_item() -> void:
	if randf() >= item_drop_chance:
		return
	var pool := item_pool
	if pool.is_empty():
		pool = _default_pool()
	if pool.is_empty() or item_scene == null:
		return
	var parent := get_parent()
	if parent == null:
		return
	var pickup := item_scene.instantiate() as Node2D
	if pickup == null:
		return
	# Assigned before entering the tree so `_ready()` can paint the icon.
	pickup.set("item", pool[randi_range(0, pool.size() - 1)])
	parent.add_child(pickup)
	pickup.global_position = global_position + Vector2(
		8.0 + randf_range(-drop_spread, drop_spread),
		-8.0
	)


## Loads `CONSUMABLE_PATHS` only when the scene does not define a pool.
func _default_pool() -> Array[Items]:
	var pool: Array[Items] = []
	for path in CONSUMABLE_PATHS:
		var item := load(path) as Items
		if item != null:
			pool.append(item)
	return pool
