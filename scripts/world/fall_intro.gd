class_name FallIntro
extends Node

# ==============================================================================
# INITIAL FALL (SIMULATED LOADING SCREEN)
# ==============================================================================
# On entering the game the player appears above the world and falls to the
# generated ground, with control disabled. The camera is a child of the player and
# follows from the first frame: it is neither parked nor attached mid-fall, so
# there is no jitter. While the chunk under the player does not exist, the fall does not
# end: the intro itself acts as a loading screen. No fades.

@export_group("Fall")
## Height above the spawn point from which the fall starts (px).
@export var fall_height_px: float = 260.0
## Fall speed (px/s). 260 px at 620 px/s lasts ~0.4 s.
@export var fall_speed: float = 620.0
## Safety cap (s): when reached, the player lands anyway and control is returned.
@export var max_seconds: float = 3.0

var _player: CharacterBody2D
var _world: Node
var _ui_layer: CanvasLayer
## Y of the player's normal spawn point (where the ground will be).
var _target_y: float = 0.0
var _elapsed: float = 0.0
var _finished: bool = false


func _ready() -> void:
	# Continue: the run is restored at its saved position, without the fall.
	if SaveGame.pending_load:
		_finished = true
		return
	_player = get_parent().get_node_or_null("player") as CharacterBody2D
	if _player == null:
		_finished = true
		return
	_world = get_parent().get_node_or_null("map")
	_ui_layer = get_parent().get_node_or_null("UILayer") as CanvasLayer

	# The generator has already placed the player on the spawn: that Y is the ground.
	_target_y = _player.global_position.y
	_player.global_position = Vector2(_player.global_position.x, _target_y - fall_height_px)
	_player.velocity = Vector2.ZERO
	_player.set("control_enabled", false)
	# The camera follows from the first frame: since it is a child of the player, any
	# "parking" moves with him and attaching it mid-fall caused a half-screen jump.
	_player.set("camera_follow_enabled", true)
	_player.set("fall_speed_cap", fall_speed)
	if _ui_layer:
		_ui_layer.visible = false


func _physics_process(delta: float) -> void:
	if _finished or not is_instance_valid(_player):
		return
	# With no world underneath the player cannot land yet: the fall continues (loading).
	if not _chunk_ready():
		_player.global_position.y = minf(_player.global_position.y, _target_y - 240.0)
		_player.velocity.y = 0.0
		return
	_elapsed += delta
	if _player.is_on_floor() or _elapsed >= max_seconds:
		_finish()


func _chunk_ready() -> bool:
	if _world == null or not _world.has_method("is_ready_at"):
		return true
	return bool(_world.call("is_ready_at", _player.global_position.x))


func _finish() -> void:
	_finished = true
	_player.set("control_enabled", true)
	_player.set("camera_follow_enabled", true)
	_player.set("fall_speed_cap", 0.0)
	if _ui_layer:
		_ui_layer.visible = true
	queue_free()
