class_name DungeonLayer
extends Node2D
## Swaps the chunked world for an explorable dungeon without changing scenes:
## the world stays loaded but hidden and paused, so health, coins, inventory and
## run seed survive the trip. `exit_requested` brings the player back.

const DUNGEON_SCENE := preload("res://scenes/structures/dungeon.tscn")

var _dungeon: DungeonGenerator
var _world_position := Vector2.ZERO

@onready var _player: CharacterBody2D = get_node_or_null("../player") as CharacterBody2D
@onready var _world: Node = get_node_or_null("../map")
@onready var _ambient: CanvasLayer = get_node_or_null("../biome_particles") as CanvasLayer


func _ready() -> void:
	add_to_group("dungeon_layer")


## Called by `DungeonEntrance` when F is pressed inside its area.
func enter(entrance: DungeonEntrance) -> void:
	if _dungeon != null or _player == null:
		return
	_world_position = _player.global_position
	if _world != null:
		_set_world_visible(false)
		_world.process_mode = Node.PROCESS_MODE_DISABLED
	if _ambient != null:
		_ambient.visible = false
	_dungeon = DUNGEON_SCENE.instantiate() as DungeonGenerator
	add_child(_dungeon)
	_dungeon.exit_requested.connect(_leave)
	_dungeon.start(entrance.dungeon_seed, 0)
	_teleport(_dungeon.spawn_point.global_position)


func _leave() -> void:
	if _dungeon == null:
		return
	_dungeon.queue_free()
	_dungeon = null
	_teleport(_world_position)
	if _world != null:
		_world.process_mode = Node.PROCESS_MODE_INHERIT
		_set_world_visible(true)
		_world.call("refresh_chunks")
	if _ambient != null:
		_ambient.visible = true


## `map` is a plain Node (chunks are its children), so visibility is toggled on
## each chunk instead of on the generator itself.
func _set_world_visible(is_visible: bool) -> void:
	if _world == null:
		return
	for child in _world.get_children():
		if child is CanvasItem:
			(child as CanvasItem).visible = is_visible


## The player's debug teleport also cuts inertia, the step offset and the cached
## camera Y, so entering and leaving never drags the camera.
func _teleport(target: Vector2) -> void:
	_player.call("debug_teleport", target - _player.global_position)
