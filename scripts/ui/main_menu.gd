extends Node2D

# ==============================================================================
# MAIN MENU
# ==============================================================================
# Background uses the same parallax as the game: sky (clear color), clouds and
# mountains, with a fill of the mountain color below. New Game loads
# `scenes/game.tscn`, which starts with the fall from the sky (`FallIntro`).
#
# The menu Camera2D sits where the in-game camera rests on the spawn point
# (`position` 808, 773 in the .tscn): x = `safe_start_tiles` 50 * 16 + 8, and
# y = ground row (`base_height` 50) * 16 minus half the player collider
# (17 * 3.2 / 2 = 27.2). Parallax2D offsets depend on the camera position, so
# from (0, 0) the two pine layers were 116 px apart relative to each other and
# sky showed between them (T-0047). Keep these numbers in sync with
# `scenes/game.tscn`'s map exports and `scenes/player.tscn`'s collider.
#
# Continue only appears when `SaveGame` has a slot; Settings is the same
# `SettingsPanel` scene used by the in-game pause menu. New Game asks for a seed
# first (`Menu/SeedDialog`): empty or not a number means random, which is the
# generator's own `world_seed` 0. The seed travels in `SaveGame.pending_seed`
# and the debug overlay shows it in-game, so any world can be reproduced.

const GAME_SCENE := "res://scenes/game.tscn"

@onready var _layout: VBoxContainer = $Menu/Layout
@onready var _new_game_button: Button = $Menu/Layout/NewGame
@onready var _continue_button: Button = $Menu/Layout/Continue
@onready var _settings_button: Button = $Menu/Layout/Settings
@onready var _quit_button: Button = $Menu/Layout/Quit
@onready var _settings_panel: SettingsPanel = $Menu/SettingsPanel
@onready var _seed_dialog: PanelContainer = $Menu/SeedDialog
@onready var _seed_input: LineEdit = $Menu/SeedDialog/Margin/Content/SeedInput
@onready var _seed_start_button: Button = $Menu/SeedDialog/Margin/Content/Buttons/SeedStart
@onready var _seed_back_button: Button = $Menu/SeedDialog/Margin/Content/Buttons/SeedBack

var _starting: bool = false


func _ready() -> void:
	_continue_button.visible = SaveGame.has_save()
	_new_game_button.pressed.connect(_start_new_game)
	_continue_button.pressed.connect(_continue_game)
	_settings_button.pressed.connect(_open_settings)
	_quit_button.pressed.connect(_quit)
	_settings_panel.closed.connect(_close_settings)
	_settings_panel.hide()
	_seed_start_button.pressed.connect(_confirm_new_game)
	_seed_back_button.pressed.connect(_close_seed_dialog)
	_seed_input.text_submitted.connect(_on_seed_submitted)
	_seed_dialog.hide()
	_new_game_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if _seed_dialog.visible and event.is_action_pressed("ui_cancel"):
		_close_seed_dialog()
		get_viewport().set_input_as_handled()


func _open_settings() -> void:
	_layout.hide()
	_settings_panel.open()


func _close_settings() -> void:
	_layout.show()
	_settings_button.grab_focus()


## New Game first asks for the seed instead of generating the world right away.
func _start_new_game() -> void:
	_layout.hide()
	_seed_input.text = ""
	_seed_dialog.show()
	_seed_input.grab_focus()


func _on_seed_submitted(_text: String) -> void:
	_confirm_new_game()


func _close_seed_dialog() -> void:
	_seed_dialog.hide()
	_layout.show()
	_new_game_button.grab_focus()


func _confirm_new_game() -> void:
	if _starting:
		return
	SaveGame.cancel_pending_load()
	SaveGame.pending_seed = _parse_seed(_seed_input.text)
	_seed_dialog.hide()
	_change_to_game()


## Seed from the dialog: 0 (random) for empty text or anything that is not an integer.
func _parse_seed(text: String) -> int:
	var trimmed := text.strip_edges()
	return int(trimmed) if trimmed.is_valid_int() else 0


func _continue_game() -> void:
	if not SaveGame.request_load():
		_continue_button.visible = false
		return
	_change_to_game()


func _change_to_game() -> void:
	if _starting:
		return
	_starting = true
	_new_game_button.disabled = true
	_continue_button.disabled = true
	_seed_start_button.disabled = true
	get_tree().change_scene_to_file(GAME_SCENE)


func _quit() -> void:
	get_tree().quit()
