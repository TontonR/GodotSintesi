class_name DebugTools
extends Node

# ==============================================================================
# TEST TOOLS (temporary)
# ==============================================================================
# Numpad: 7 halves the game speed, 9 doubles it (no cap) and 8 resets it to
# x1; 4/6 make a quick
# trip left/right + a bit upward, to avoid getting stuck
# inside a mountain while testing, and 5 toggles player immortality.
# Test items (KP0-KP3) remain in `scenes/inventory/inventory.gd`, which
# belongs to the inventory.
# The bottom-left label always shows the speed, immortality, the player
# position (pixels and tiles) and the seed of the run, so a world can be
# reproduced from the menu's seed dialog.

const TILE_SIZE := 16
const HINT := "speed %s · immortal %s · KP7/KP8/KP9 speed half/reset/double · KP4/KP6 quick travel · KP5 immortal"
const IMMORTAL_LABELS: Array[String] = ["no", "yes"]
## Floor for KP7: halving never reaches x0, which would freeze the game.
const MIN_SPEED := 0.001

## Game speed at startup (also changed live with the numpad).
@export var start_speed: float = 1.0
## Tiles the KP4/KP6 quick travel advances.
@export var teleport_distance_tiles: int = 64
## Tiles above the ground the quick travel leaves the player at the destination,
## whatever the height it started from.
@export var teleport_above_ground_tiles: int = 4

var _label: Label
## Current `Engine.time_scale`; KP9 doubles it and KP7 halves it, without a cap.
var _speed: float = 1.0
## Debug immortality state (toggled by KP5).
var _immortal: bool = false
## Player and world are looked up lazily: the generator joins its group in `_ready`.
var _player: Node2D
var _world: Node
## Position + seed line, rebuilt only when it changes.
var _info: String = ""


func _ready() -> void:
	_apply_speed(start_speed)
	_build_label()


func _process(_delta: float) -> void:
	_refresh_info()


func _exit_tree() -> void:
	# Never leave the game sped up when leaving the scene.
	Engine.time_scale = 1.0


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	var key := key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
	match key:
		KEY_KP_4:
			_teleport(-1.0)
		KEY_KP_5:
			_toggle_immortal()
		KEY_KP_6:
			_teleport(1.0)
		KEY_KP_7:
			_apply_speed(_speed * 0.5)
		KEY_KP_8:
			_apply_speed(1.0)
		KEY_KP_9:
			_apply_speed(_speed * 2.0)
		_:
			return
	get_viewport().set_input_as_handled()


## Sets `Engine.time_scale` to `value` (no upper cap; KP7 can go down to x0.001).
func _apply_speed(value: float) -> void:
	_speed = maxf(value, MIN_SPEED)
	Engine.time_scale = _speed
	_update_label()


## "x2", "x0.5": `String.num` already drops the trailing zeros.
func _speed_label() -> String:
	return "x" + String.num(_speed, 4)


## Toggles player immortality with KP5 (takes no damage while active).
func _toggle_immortal() -> void:
	var player := get_tree().get_first_node_in_group("player")
	if player == null:
		player = get_parent().get_node_or_null("player")
	if player == null or not player.has_method("toggle_immortal"):
		return
	_immortal = bool(player.call("toggle_immortal"))
	_update_label()


## Quick travel: `direction` -1 goes left and 1 goes right. The height is not an
## offset from the current one: the player lands `teleport_above_ground_tiles`
## above the ground at the destination, so it ever ends up buried in a slope.
func _teleport(direction: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		player = get_parent().get_node_or_null("player") as Node2D
	if player == null:
		return
	var target_x := player.global_position.x + direction * teleport_distance_tiles * TILE_SIZE
	var target_y := player.global_position.y
	var world := get_tree().get_first_node_in_group("world_generator")
	if world and world.has_method("ground_y_at"):
		target_y = float(world.call("ground_y_at", target_x)) - teleport_above_ground_tiles * TILE_SIZE
	var offset := Vector2(target_x - player.global_position.x, target_y - player.global_position.y)
	if player.has_method("debug_teleport"):
		player.call("debug_teleport", offset)
	else:
		player.global_position += offset
	# Generate the destination chunks now, or the landing would fall through the
	# ground for a frame.
	if world and world.has_method("refresh_chunks"):
		world.call("refresh_chunks")


func _build_label() -> void:
	var ui_layer := get_parent().get_node_or_null("UILayer") as CanvasLayer
	if ui_layer == null:
		return
	_label = Label.new()
	_label.name = "DebugHint"
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = 8.0
	# Two lines: the hint on top and position + seed below it.
	_label.offset_top = -40.0
	_label.offset_right = 620.0
	_label.offset_bottom = -6.0
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	ui_layer.add_child(_label)
	_refresh_info()


func _update_label() -> void:
	if _label:
		_label.text = (HINT % [_speed_label(), IMMORTAL_LABELS[1 if _immortal else 0]]) + "\n" + _info


## Rebuilds the position + seed line and only redraws the label when it changed.
func _refresh_info() -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _world == null or not is_instance_valid(_world):
		_world = get_tree().get_first_node_in_group("world_generator")
	var info := _info_text()
	if info == _info:
		return
	_info = info
	_update_label()


## `pos px,py · tile tx,ty · seed N`; the seed is the one the generator is using
## (random when the run was started with an empty seed).
func _info_text() -> String:
	var seed_value := 0
	if _world and _world.has_method("current_seed"):
		seed_value = int(_world.call("current_seed"))
	if _player == null:
		return "pos -, - · tile -, - · seed %d" % seed_value
	var pos := _player.global_position
	var tile := Vector2i(floori(pos.x / TILE_SIZE), floori(pos.y / TILE_SIZE))
	return "pos %d, %d · tile %d, %d · seed %d" % [
		roundi(pos.x), roundi(pos.y), tile.x, tile.y, seed_value
	]
