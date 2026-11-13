extends Node2D

# ==============================================================================
# MAIN MENU
# ==============================================================================
# Background uses the same parallax as the game: sky (clear color), clouds and
# mountains, with a fill of the mountain color below. New Game starts with the
# fall from the sky (`FallIntro`).
#
# The menu Camera2D sits where the in-game camera rests on the spawn point
# (`position` 808, 773 in the .tscn): x = `safe_start_tiles` 50 * 16 + 8, and
# y = ground row (`base_height` 50) * 16 minus half the player collider
# (17 * 3.2 / 2 = 27.2). Parallax2D offsets depend on the camera position, so
# from (0, 0) the two pine layers were 116 px apart relative to each other and
# sky showed between them (T-0047). Keep these numbers in sync with
# `scenes/game.tscn`'s map exports and `scenes/player.tscn`'s collider.
#
# Buttons: New Game (seed dialog, then the first free slot; with the three slots
# taken it shows the overwrite prompt instead of erasing anything by surprise),
# Continue (the slot written most recently, i.e. the last run closed) and Load
# (`Menu/LoadDialog`), which lists each run with its meters and coins and lets
# you erase slots. Settings is the same `SettingsPanel` scene used by the pause
# menu. The seed travels in `SaveGame.pending_seed` and the debug overlay shows
# it in-game, so any world can be reproduced.

const GAME_SCENE := "res://scenes/game.tscn"
## `Menu/LoadDialog` is reused: pick a run to load, or the run a new one replaces.
const DIALOG_LOAD := 0
const DIALOG_OVERWRITE := 1

@onready var _layout: VBoxContainer = $Menu/Layout
@onready var _new_game_button: Button = $Menu/Layout/NewGame
@onready var _continue_button: Button = $Menu/Layout/Continue
@onready var _load_button: Button = $Menu/Layout/Load
@onready var _settings_button: Button = $Menu/Layout/Settings
@onready var _quit_button: Button = $Menu/Layout/Quit
@onready var _settings_panel: SettingsPanel = $Menu/SettingsPanel
@onready var _seed_dialog: PanelContainer = $Menu/SeedDialog
@onready var _seed_input: LineEdit = $Menu/SeedDialog/Margin/Content/SeedInput
@onready var _seed_start_button: Button = $Menu/SeedDialog/Margin/Content/Buttons/SeedStart
@onready var _seed_back_button: Button = $Menu/SeedDialog/Margin/Content/Buttons/SeedBack
@onready var _load_dialog: PanelContainer = $Menu/LoadDialog
@onready var _load_title: Label = $Menu/LoadDialog/Margin/Content/LoadTitle
@onready var _load_slots: Array[HBoxContainer] = [
	$Menu/LoadDialog/Margin/Content/Slots/Slot1,
	$Menu/LoadDialog/Margin/Content/Slots/Slot2,
	$Menu/LoadDialog/Margin/Content/Slots/Slot3,
]
@onready var _load_back_button: Button = $Menu/LoadDialog/Margin/Content/LoadBack

var _starting: bool = false
var _dialog_mode: int = DIALOG_LOAD
## Seed typed in the seed dialog, kept while the overwrite prompt is open.
var _pending_seed: int = 0


func _ready() -> void:
	_new_game_button.pressed.connect(_start_new_game)
	_continue_button.pressed.connect(_continue_game)
	_load_button.pressed.connect(_open_load_dialog)
	_settings_button.pressed.connect(_open_settings)
	_quit_button.pressed.connect(_quit)
	_settings_panel.closed.connect(_close_settings)
	_settings_panel.hide()
	for slot in SaveGame.SLOT_COUNT:
		_slot_button(slot).pressed.connect(_on_slot_pressed.bind(slot))
		_erase_button(slot).pressed.connect(_on_slot_erase.bind(slot))
	_load_back_button.pressed.connect(_close_load_dialog)
	_load_dialog.hide()
	_seed_start_button.pressed.connect(_confirm_new_game)
	_seed_back_button.pressed.connect(_close_seed_dialog)
	_seed_input.text_submitted.connect(_on_seed_submitted)
	_seed_dialog.hide()
	_refresh_menu()
	_new_game_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("ui_cancel"):
		return
	if _load_dialog.visible:
		_close_load_dialog()
		get_viewport().set_input_as_handled()
	elif _seed_dialog.visible:
		_close_seed_dialog()
		get_viewport().set_input_as_handled()


func _slot_button(slot: int) -> Button:
	return _load_slots[slot].get_node("Play") as Button


func _erase_button(slot: int) -> Button:
	return _load_slots[slot].get_node("Erase") as Button


## Continue only exists with a saved run; each row shows its meters and coins.
## While picking a run to overwrite every slot is enabled and Erase is hidden.
func _refresh_menu() -> void:
	_continue_button.visible = SaveGame.latest_slot() >= 0
	for slot in SaveGame.SLOT_COUNT:
		var summary := SaveGame.slot_summary(slot)
		var occupied := bool(summary["exists"])
		var play := _slot_button(slot)
		if occupied:
			play.text = "Slot %d — %d m · %d coins" % [slot + 1, summary["meters"], summary["coins"]]
		else:
			play.text = "Slot %d — Empty" % (slot + 1)
		play.disabled = not occupied and _dialog_mode == DIALOG_LOAD
		_erase_button(slot).visible = occupied and _dialog_mode == DIALOG_LOAD


## New Game asks for the seed first; the slot is decided on Start.
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


## Start: straight into the first free slot, or ask which run to overwrite when
## the three slots are taken (nothing is erased without the player picking it).
func _confirm_new_game() -> void:
	if _starting:
		return
	_pending_seed = _parse_seed(_seed_input.text)
	if SaveGame.has_free_slot():
		_begin_run(SaveGame.first_free_slot())
		return
	_open_overwrite_dialog()


## Clears the chosen slot and loads the game; the seed goes after
## `start_new_run()`, which cancels any pending new-run state.
func _begin_run(slot: int) -> void:
	SaveGame.start_new_run(slot)
	SaveGame.pending_seed = _pending_seed
	_seed_dialog.hide()
	_load_dialog.hide()
	_change_to_game()


## Continue: the slot written most recently, i.e. the last run closed.
func _continue_game() -> void:
	var slot := SaveGame.latest_slot()
	if slot < 0 or not SaveGame.request_load(slot):
		_refresh_menu()
		return
	_change_to_game()


func _open_load_dialog() -> void:
	_dialog_mode = DIALOG_LOAD
	_load_title.text = "Load run"
	_refresh_menu()
	_layout.hide()
	_load_dialog.show()
	_focus_first_slot()


func _open_overwrite_dialog() -> void:
	_dialog_mode = DIALOG_OVERWRITE
	_load_title.text = "No free slots — overwrite which run?"
	_refresh_menu()
	_seed_dialog.hide()
	_layout.hide()
	_load_dialog.show()
	_focus_first_slot()


func _close_load_dialog() -> void:
	_load_dialog.hide()
	if _dialog_mode == DIALOG_OVERWRITE:
		# Back to the seed dialog, which keeps the seed that was typed.
		_seed_dialog.show()
		_seed_input.grab_focus()
		return
	_layout.show()
	_load_button.grab_focus()


func _focus_first_slot() -> void:
	for slot in SaveGame.SLOT_COUNT:
		if not _slot_button(slot).disabled:
			_slot_button(slot).grab_focus()
			return
	_load_back_button.grab_focus()


func _on_slot_pressed(slot: int) -> void:
	if _starting:
		return
	if _dialog_mode == DIALOG_OVERWRITE:
		_begin_run(slot)
		return
	if not SaveGame.slot_exists(slot):
		return
	if SaveGame.request_load(slot):
		_change_to_game()
	else:
		_refresh_menu()


func _on_slot_erase(slot: int) -> void:
	if _starting:
		return
	SaveGame.delete_slot(slot)
	_refresh_menu()
	_focus_first_slot()


## Seed from the dialog: 0 (random) for empty text or anything that is not an integer.
func _parse_seed(text: String) -> int:
	var trimmed := text.strip_edges()
	return int(trimmed) if trimmed.is_valid_int() else 0


func _open_settings() -> void:
	_layout.hide()
	_settings_panel.open()


func _close_settings() -> void:
	_layout.show()
	_settings_button.grab_focus()


func _change_to_game() -> void:
	if _starting:
		return
	_starting = true
	_new_game_button.disabled = true
	_continue_button.disabled = true
	_load_button.disabled = true
	for slot in SaveGame.SLOT_COUNT:
		_slot_button(slot).disabled = true
		_erase_button(slot).disabled = true
	_seed_start_button.disabled = true
	get_tree().change_scene_to_file(GAME_SCENE)


func _quit() -> void:
	get_tree().quit()
