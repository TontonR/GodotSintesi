extends Area2D

## Emitted on pickup; the world generator uses it so it does not respawn.
signal collected

# World 2D layer (floor and platforms).
const WORLD_LAYER: int = 1
## Maximum distance (px) searched downwards for the ground on spawn.
const GROUND_SEARCH_DISTANCE: float = 1024.0
## Search attempts before giving up (the TileMap may take a frame to
## register the collision of the freshly painted chunk).
const GROUND_SEARCH_TRIES: int = 30

# Value this coin adds to the player counter
@export var coin_value: int = 1

@export_group("Physics")
## Fall acceleration (px/s²).
@export var fall_gravity: float = 900.0
## Bounce when touching the ground (0 = no bounce).
@export var bounce: float = 0.4
## Minimum impact speed (px/s) to bounce; below it the coin settles.
@export var min_bounce_speed: float = 40.0
## Bob height once resting (px).
@export var float_height: float = 1.0
## Bob speed (rad/s).
@export var float_speed: float = 2.5

var _velocity_y: float = 0.0
var _ground_y: float = -1.0
var _ground_tries: int = 0
var _rest_y: float = 0.0
var _settled: bool = false
var _phase: float = 0.0
var _time: float = 0.0

@onready var _shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# The group lets the zone generator locate them to delete them on unload
	add_to_group("coins")
	body_entered.connect(_on_body_entered)
	_phase = randf() * TAU

func _physics_process(delta: float) -> void:
	if _settled:
		_time += delta
		global_position.y = _rest_y + sin(_time * float_speed + _phase) * float_height
		return

	# The ground is searched with the real position already assigned; if the chunk
	# has no collision yet, it retries on the following frames.
	if _ground_y < 0.0:
		_find_ground()
		if _ground_y < 0.0:
			return

	_velocity_y += fall_gravity * delta
	var next_y := global_position.y + _velocity_y * delta
	if _velocity_y > 0.0 and next_y >= _ground_y - _half_height():
		global_position.y = _ground_y - _half_height()
		if absf(_velocity_y) < min_bounce_speed:
			_settle(_ground_y - _half_height())
		else:
			_velocity_y = -_velocity_y * bounce
		return
	global_position.y = next_y

func _on_body_entered(body: Node2D) -> void:
	# The detected body may be the player or one of its child nodes
	var target: Node = body if body.has_method("add_coin") else body.get_parent()
	if target == null or not target.has_method("add_coin"):
		return
	target.add_coin(coin_value)
	var fx := get_tree().get_first_node_in_group("fx")
	if fx:
		fx.call("coin_pickup", global_position)
	collected.emit()
	queue_free()

## Real half height of the sprite (node scale included): the base stays on the ground.
func _half_height() -> float:
	if _shape and _shape.shape is RectangleShape2D:
		var rect := _shape.shape as RectangleShape2D
		return rect.size.y * 0.5 * _shape.scale.y * scale.y
	return 7.0

## Searches the ground below; after several failed attempts it stays floating.
func _find_ground() -> void:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0.0, GROUND_SEARCH_DISTANCE),
		WORLD_LAYER
	)
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		_ground_tries += 1
		if _ground_tries >= GROUND_SEARCH_TRIES:
			_settle(global_position.y)
		return
	_ground_y = hit["position"].y
	if global_position.y >= _ground_y - _half_height():
		_settle(_ground_y - _half_height())

func _settle(y: float) -> void:
	global_position.y = y
	_rest_y = y
	_velocity_y = 0.0
	_settled = true
