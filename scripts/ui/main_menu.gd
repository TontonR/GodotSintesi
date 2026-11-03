extends Node2D

# ==============================================================================
# MENÚ PRINCIPAL
# ==============================================================================
# De fondo, el mismo parallax que la partida: cielo (clear color), nubes y
# montañas, con un relleno del color de la montaña por debajo. Al pulsar Jugar se
# carga `scenes/game.tscn`, que arranca con la caída desde el cielo (`FallIntro`).

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
