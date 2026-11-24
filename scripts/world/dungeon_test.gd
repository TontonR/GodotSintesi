extends Node2D
## F6 harness for `dungeon.tscn` (T-0079). Not part of the game: it drops the
## player on the dungeon spawn point, lets 1/2 switch floors and prints the exit
## request. The world hook will do this from the world generator in a later ticket.

@onready var dungeon: DungeonGenerator = $Dungeon
@onready var player: CharacterBody2D = $player


func _ready() -> void:
	dungeon.exit_requested.connect(_on_exit_requested)
	_place_player()


func _unhandled_input(event: InputEvent) -> void:
	if not (event is InputEventKey) or not event.pressed or event.echo:
		return
	match event.keycode:
		KEY_1:
			_enter_floor(0)
		KEY_2:
			_enter_floor(1)


func _enter_floor(floor_index: int) -> void:
	dungeon.start(dungeon.current_seed(), floor_index)
	_place_player()


func _place_player() -> void:
	player.global_position = dungeon.spawn_point.global_position
	player.velocity = Vector2.ZERO
	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera != null:
		camera.reset_smoothing()


func _on_exit_requested() -> void:
	print("Dungeon: exit requested on floor %d." % dungeon.current_floor())
