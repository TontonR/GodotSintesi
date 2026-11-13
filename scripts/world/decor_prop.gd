class_name DecorProp
extends Sprite2D
## Decoration prop: never collides and lives with its chunk. Bushes bend and
## drop a few leaves when the player walks through them; the rest do nothing
## (the script turns its `_process` off, so a chunk full of trees costs nothing).

## Enables the bend and the leaf burst.
@export var sways: bool = false
## Horizontal reach of the bend, in pixels.
@export var sway_radius_px: float = 48.0
## Maximum bend, in radians (0.1 ≈ 6°).
@export var sway_angle: float = 0.1
## Leaves per burst.
@export var leaves_per_burst: int = 7
## Biome tint of the foliage; the leaf burst uses it so the particles match.
@export var tint_color: Color = Color.WHITE

## The sprite origin is the bottom center, so rotation pivots on the ground.
var _player: Node2D
var _time: float = 0.0
var _phase: float = 0.0
var _bend: float = 0.0
var _was_near: bool = false


func _ready() -> void:
	if not sways:
		set_process(false)
		return
	# Different phase per bush so a row of them does not sway in unison.
	_phase = fmod(absf(global_position.x + global_position.y), TAU)
	_find_player()


func _process(delta: float) -> void:
	if not is_instance_valid(_player):
		_find_player()
		if _player == null:
			return
	_time += delta
	var dx := _player.global_position.x - global_position.x
	var dy := _player.global_position.y - global_position.y
	# The player's origin sits above its feet, so vertical tolerance is wide.
	var near := absf(dx) < sway_radius_px and absf(dy) < 80.0
	var target := 0.0
	if near:
		target = clampf(1.0 - absf(dx) / sway_radius_px, 0.15, 1.0)
	_bend = lerpf(_bend, target, clampf(delta * 12.0, 0.0, 1.0))
	rotation = sin(_time * 8.5 + _phase) * sway_angle * _bend
	if near and not _was_near:
		_emit_leaves()
	_was_near = near


## Player by group, then by the usual sibling name (some scenes omit the group).
func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		# Chunk → map → game root → `player`.
		var map := get_parent()
		var root := map.get_parent() if map else null
		if root:
			_player = root.get_node_or_null("player") as Node2D


## Leaf burst from the crown, through the shared `fx` node (no particle nodes
## per bush and no particle scaling inherited from the sprite).
func _emit_leaves() -> void:
	var fx := get_tree().get_first_node_in_group("fx")
	if fx == null or texture == null:
		return
	var crown := global_position + Vector2(0.0, -texture.get_height() * scale.y * 0.55)
	fx.call("leaves", crown, tint_color.lightened(0.25), leaves_per_burst)
