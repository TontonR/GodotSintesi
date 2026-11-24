class_name BreakableBlock
extends StaticBody2D
## Breakable crate inside the ruins: a few sword hits break it, it drops coins
## and it stays broken for the rest of the run (the generator persists the ids).

## Emitted when it breaks, with the stable id the generator assigned to it.
signal broken(spawn_id: String)

## Sword hits it takes to break it (the base hitbox deals 20 damage).
@export var max_health: float = 40.0
## Minimum coins dropped when it breaks.
@export var coin_min: int = 1
## Maximum coins dropped when it breaks.
@export var coin_max: int = 3
## Horizontal spread of the dropped coins, in px.
@export var drop_spread: float = 8.0
## Coin scene; the same collectable the enemies drop.
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")

## Stable id assigned by the generator (`b:chunk_x:chunk_y:tile_x`).
var spawn_id: String = ""

var _health: float


func _ready() -> void:
	_health = max_health


## Same entry point the player uses for any non-enemy target.
func take_damage(amount: float) -> void:
	_health -= amount
	if _health <= 0.0:
		_dust(8, 1.2)
		_drop_coins()
		broken.emit(spawn_id)
		queue_free()
		return
	_dust(3, 0.8)
	_flash()


func _dust(amount: int, strength: float) -> void:
	var fx := get_tree().get_first_node_in_group("fx")
	if fx:
		fx.call("dust", global_position + Vector2(8.0, -8.0), amount, strength)


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
