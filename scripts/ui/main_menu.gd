extends Node2D

# ==============================================================================
# MAIN MENU
# ==============================================================================
# Background uses the same parallax as the game: sky (clear color), clouds and
# mountains, with a fill of the mountain color below. Pressing Play
# loads `scenes/game.tscn`, which starts with the fall from the sky (`FallIntro`).

const GAME_SCENE := "res://scenes/game.tscn"

@onready var _play_button: Button = $Menu/Layout/Play

var _starting: bool = false


func _ready() -> void:
	_play_button.pressed.connect(_start_game)
	_play_button.grab_focus()


func _start_game() -> void:
	if _starting:
		return
	_starting = true
	_play_button.disabled = true
	get_tree().change_scene_to_file(GAME_SCENE)
