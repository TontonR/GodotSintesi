class_name DungeonEntrance
extends Node2D
## Black placeholder door for the explorable dungeon. F inside the `Area2D`
## calls `DungeonLayer.enter()`; the layout seed comes from `WorldGenerator`.

## Dungeon layout seed for this door; set by `WorldGenerator` after instancing.
var dungeon_seed: int = 0

var _player_inside := false

@onready var _hint: Label = $Hint


func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or not event.is_action_pressed("interact"):
		return
	var layer := get_tree().get_first_node_in_group("dungeon_layer")
	if layer != null:
		layer.call("enter", self)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = true
	_hint.visible = true


func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player_inside = false
	_hint.visible = false
