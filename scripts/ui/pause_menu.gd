class_name PauseMenu
extends CanvasLayer

# ==============================================================================
# PAUSE MENU (Esc in game)
# ==============================================================================
# Pauses the tree and offers Resume, Settings and Save and quit. It runs with
# `process_mode = ALWAYS` (set in the scene) so Esc and the buttons work while
# `get_tree().paused` is true. Esc is ignored while the inventory screen owns
# the pause: that screen closes itself with Esc first.

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var _panel: PanelContainer = $Panel
@onready var _resume_button: Button = $Panel/Margin/Content/Resume
@onready var _settings_button: Button = $Panel/Margin/Content/Settings
@onready var _save_quit_button: Button = $Panel/Margin/Content/SaveQuit
@onready var _settings_panel: SettingsPanel = $SettingsPanel

var _is_open: bool = false


func _ready() -> void:
	visible = false
	_resume_button.pressed.connect(_resume)
	_settings_button.pressed.connect(_open_settings)
	_save_quit_button.pressed.connect(_save_and_quit)
	_settings_panel.closed.connect(_back_to_pause)
	_settings_panel.hide()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	# A dead run belongs to the death screen: no pause, no "Save and quit".
	var player := get_parent().get_node_or_null("player")
	if player != null and player.has_method("is_dead") and bool(player.call("is_dead")):
		return
	if _settings_panel.visible:
		return # the panel closes itself with the same key
	if _is_open:
		_resume()
		get_viewport().set_input_as_handled()
		return
	# The inventory screen pauses the tree too: Esc belongs to it in that case.
	if get_tree().paused:
		return
	_open_pause()
	get_viewport().set_input_as_handled()


func _open_pause() -> void:
	_is_open = true
	visible = true
	_panel.show()
	get_tree().paused = true
	_resume_button.grab_focus()


func _resume() -> void:
	_is_open = false
	visible = false
	get_tree().paused = false


func _open_settings() -> void:
	_panel.hide()
	_settings_panel.open()


func _back_to_pause() -> void:
	_panel.show()
	_settings_button.grab_focus()


func _save_and_quit() -> void:
	var root := get_parent()
	var player := root.get_node_or_null("player")
	# A dead run is over: it is never written back (the death screen frees its slot).
	var dead: bool = player != null and player.has_method("is_dead") and bool(player.call("is_dead"))
	if not dead:
		SaveGame.save_run(root.get_node_or_null("map"), player)
	_is_open = false
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _exit_tree() -> void:
	# Never leave the game paused if the scene is unloaded with the menu open.
	if get_tree() and get_tree().paused:
		get_tree().paused = false
