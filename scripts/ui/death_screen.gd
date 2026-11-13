class_name DeathScreen
extends CanvasLayer
## End-of-run screen: the run is over, so it only offers the main menu or
## quitting. It freezes the scene and shows the seed and coins of the run.

const MAIN_MENU_SCENE := "res://scenes/main_menu.tscn"

@onready var _stats: Label = $Panel/Margin/Content/Stats
@onready var _menu_button: Button = $Panel/Margin/Content/Buttons/Menu
@onready var _quit_button: Button = $Panel/Margin/Content/Buttons/Quit


func _ready() -> void:
	visible = false
	_menu_button.pressed.connect(_back_to_menu)
	_quit_button.pressed.connect(_quit)


## Called by the game root once the death animation has played.
func show_death(run_seed: int, coins: int) -> void:
	_stats.text = "Seed %d · %d coins" % [run_seed, coins]
	visible = true
	get_tree().paused = true
	_menu_button.grab_focus()


func _back_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MAIN_MENU_SCENE)


func _quit() -> void:
	get_tree().quit()


func _exit_tree() -> void:
	# Never leave the game paused if the scene is unloaded with the screen open.
	if get_tree() and get_tree().paused:
		get_tree().paused = false
