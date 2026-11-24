class_name DungeonLayer
extends Node2D
## Loads the dungeon as its own scene while the chunked world is unloaded: no
## offset and no hidden collision, and the world comes back from its seed when
## the player leaves. The player, HUD and run are never freed (only the chunks
## and their entities are), so health, coins, inventory, passives and the run
## seed survive the trip. A black fade covers both swaps.
##
## The swap itself is synchronous: the screen snaps to black, the nodes are
## replaced and the black fades out. `_dungeon != null` is the only "inside"
## state, so a cancelled tween can never leave the door locked.

const DUNGEON_SCENE := preload("res://scenes/structures/dungeon.tscn")

## Seconds the fade-in from black takes after each swap (0 = instant).
@export var fade_seconds: float = 0.25
## Radius (px) where a door shows its prompt and accepts F. The tower sprite is
## ~144 px wide, so this covers standing right next to it.
@export var door_radius_px: float = 96.0

var _dungeon: DungeonGenerator
## World spot to return to; the entrance belongs to a chunk that gets unloaded.
var _world_position := Vector2.ZERO
var _fade: ColorRect
var _prompt: Label

@onready var _player: CharacterBody2D = get_node_or_null("../player") as CharacterBody2D
@onready var _world: Node = get_node_or_null("../map")
@onready var _ambient: CanvasLayer = get_node_or_null("../biome_particles") as CanvasLayer
@onready var _meters: Label = get_node_or_null("../UILayer/Meters") as Label


func _ready() -> void:
	add_to_group("dungeon_layer")
	_build_fade()
	_build_prompt()


## Doors are just markers: the closest one in `door_radius_px` gets the prompt
## and reads F here, so a rebuilt chunk, a teleport or a scene load cannot leave
## a door without input.
func _process(_delta: float) -> void:
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if _dungeon != null or _player == null or not event.is_action_pressed("interact"):
		return
	var door := _nearest_door()
	if door != null:
		enter(door)


## Enters the dungeon behind `entrance`. Called from `_unhandled_input` with the
## closest door, and safe to call on a stale state (see the self-heal below).
func enter(entrance: DungeonEntrance) -> void:
	if _player == null:
		return
	if _dungeon != null:
		# Self-heal: with the world's chunks loaded the player is outside, so a
		# leftover dungeon is stale and must not lock the door.
		if not _world_loaded():
			return
		_dungeon.queue_free()
		_dungeon = null
	_world_position = _player.global_position
	# Read before unloading: the door is a chunk child and dies with its chunk.
	var dungeon_seed: int = entrance.dungeon_seed
	# Black on this same frame, so the world never leaks into the dungeon frame.
	_set_fade(1.0)
	_unload_world()
	_dungeon = DUNGEON_SCENE.instantiate() as DungeonGenerator
	add_child(_dungeon)
	_dungeon.exit_requested.connect(_leave)
	_dungeon.start(dungeon_seed, 0)
	if _dungeon.spawn_point == null:
		push_error("DungeonLayer: dungeon has no spawn_point.")
		_close_dungeon()
		_fade_in()
		return
	_teleport(_dungeon.spawn_point.global_position)
	_fade_in()


## `exit_requested` from the dungeon scene.
func _leave() -> void:
	if _dungeon == null:
		return
	_set_fade(1.0)
	_close_dungeon()
	_fade_in()


## Closest door to the player inside `door_radius_px`, or null.
func _nearest_door() -> DungeonEntrance:
	if _player == null:
		return null
	var best: DungeonEntrance = null
	var best_distance := door_radius_px
	for node in get_tree().get_nodes_in_group("dungeon_entrance"):
		var door := node as DungeonEntrance
		if door == null or not is_instance_valid(door):
			continue
		var distance := door.global_position.distance_to(_player.global_position)
		if distance <= best_distance:
			best_distance = distance
			best = door
	return best


## Prompt over the closest door, in screen space, so the camera and any teleport
## can never leave it behind.
func _update_prompt() -> void:
	if _prompt == null:
		return
	if _dungeon != null or _player == null:
		_prompt.visible = false
		return
	var door := _nearest_door()
	if door == null:
		_prompt.visible = false
		return
	var screen := get_viewport().get_canvas_transform() * door.global_position
	_prompt.position = Vector2(roundf(screen.x - 40.0), roundf(screen.y - 70.0))
	_prompt.visible = true


## True when the chunk under the player exists, i.e. the player is in the world.
func _world_loaded() -> bool:
	if _world == null or not _world.has_method("is_ready_at"):
		return false
	return bool(_world.call("is_ready_at", _player.global_position.x))


## Empties the world for the dungeon: the chunks are freed (their terrain would
## collide with the dungeon at the origin) and the generator stops streaming.
func _unload_world() -> void:
	if _world == null:
		return
	_world.process_mode = Node.PROCESS_MODE_DISABLED
	_world.call("unload_chunks")
	if _ambient != null:
		_ambient.visible = false
	if _meters != null:
		# The meters are world X, which means nothing inside the dungeon.
		_meters.visible = false


## Frees the dungeon and rebuilds the world around the spot the player left.
func _close_dungeon() -> void:
	if _dungeon != null:
		_dungeon.queue_free()
		_dungeon = null
	_teleport(_world_position)
	if _world != null:
		_world.process_mode = Node.PROCESS_MODE_INHERIT
		_world.call("refresh_chunks")
	if _ambient != null:
		_ambient.visible = true
	if _meters != null:
		_meters.visible = true


## Full-screen black rectangle above the HUD, transparent at rest.
func _build_fade() -> void:
	var layer := CanvasLayer.new()
	layer.name = "DungeonFade"
	layer.layer = 200
	add_child(layer)
	_fade = ColorRect.new()
	_fade.color = Color(0, 0, 0, 0)
	_fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(_fade)
	_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## "F: enter" label in its own CanvasLayer, positioned every frame over the door.
func _build_prompt() -> void:
	var layer := CanvasLayer.new()
	layer.name = "DungeonPrompt"
	# Above the HUD (1) and the particles (5), below the inventory (10), pause
	# (20) and death (30) screens, so menus always cover it.
	layer.layer = 8
	add_child(layer)
	_prompt = Label.new()
	_prompt.text = "F: enter"
	_prompt.visible = false
	_prompt.size = Vector2(80, 20)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_prompt.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	_prompt.add_theme_constant_override("shadow_offset_x", 1)
	_prompt.add_theme_constant_override("shadow_offset_y", 1)
	_prompt.add_theme_font_size_override("font_size", 10)
	layer.add_child(_prompt)


func _set_fade(alpha: float) -> void:
	if _fade != null:
		_fade.color.a = alpha


## Reveals the scene that is already swapped in; it never gates the state.
func _fade_in() -> void:
	if _fade == null or fade_seconds <= 0.0:
		_set_fade(0.0)
		return
	var tween := create_tween()
	tween.tween_property(_fade, "color:a", 0.0, fade_seconds)


## The player's debug teleport also cuts inertia, the step offset and the cached
## camera Y, so entering and leaving never drags the camera.
func _teleport(target: Vector2) -> void:
	_player.call("debug_teleport", target - _player.global_position)
