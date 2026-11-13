extends Node2D

# ==============================================================================
# GAME ROOT
# ==============================================================================
# Applies a pending save (Continue) once every child is ready: the world
# generator already used the saved seed and spawn state, and `FallIntro` skipped
# itself, so only the player state has to be put back here.
#
# It also owns the end of the run: the player emits `died`, the slot is erased
# right away (so Esc + "Save and quit" during the death animation cannot reload
# a previous state) and the death screen freezes the scene after the animation.

## Seconds the death animation gets before the screen freezes the game.
const DEATH_DELAY := 1.4
const DEATH_SCREEN_SCENE := "res://scenes/ui/death_screen.tscn"


func _ready() -> void:
	_ensure_death_screen()
	var player_node := get_node_or_null("player")
	if player_node and player_node.has_signal("died"):
		player_node.connect("died", _on_player_died)

	if not SaveGame.pending_load:
		return
	SaveGame.pending_load = false

	var intro := get_node_or_null("fall_intro")
	if intro:
		intro.queue_free()

	player_node = get_node_or_null("player")
	if player_node == null:
		return

	# Passives first: their equip effects raise maxima before health is clamped.
	var passives := player_node.get_node_or_null("PlayerPassives")
	if passives:
		passives.call("restore_from_save", SaveGame.data.get("passives", []))
	var inventory := player_node.get_node_or_null("Inventory")
	if inventory:
		inventory.call("restore_from_save", SaveGame.data.get("items", []))

	player_node.set("global_position", SaveGame.data.get("position", player_node.get("global_position")))
	player_node.set("velocity", Vector2.ZERO)
	player_node.set("control_enabled", true)
	player_node.set("camera_follow_enabled", true)
	player_node.set("fall_speed_cap", 0.0)
	# Drop the cached camera Y so the follow doesn't drag from the spawn point.
	player_node.set("_cam_y", NAN)
	player_node.call("restore_run_state", SaveGame.data.get("health", 100), SaveGame.data.get("stamina", 100.0), SaveGame.data.get("coins", 0))

	var camera := player_node.get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.reset_smoothing()

	var world := get_node_or_null("map")
	if world:
		world.call("refresh_chunks")

	var ui := get_node_or_null("UILayer")
	if ui:
		ui.visible = true


## Death ends the run: the slot disappears so there is nothing to continue and
## the death screen offers only the main menu or quitting.
func _on_player_died() -> void:
	var world := get_node_or_null("map")
	var player := get_node_or_null("player")
	var run_seed := int(world.call("current_seed")) if world else 0
	var coins := int(player.get("current_coins")) if player else 0
	SaveGame.delete_slot(SaveGame.current_slot)
	SaveGame.current_slot = -1
	SaveGame.cancel_pending_load()

	await get_tree().create_timer(DEATH_DELAY).timeout
	if not is_inside_tree():
		return
	_ensure_death_screen()
	var death := get_node_or_null("DeathScreen")
	if death:
		death.call("show_death", run_seed, coins)


## Top-center meter counter: blocks traveled from the spawn point. Only the
## text is rewritten, and only when the block changes.
func _process(_delta: float) -> void:
	var label := get_node_or_null("UILayer/Meters") as Label
	if label == null:
		return
	var player := get_node_or_null("player")
	var world := get_node_or_null("map")
	if player == null or world == null:
		return
	var position: Vector2 = player.get("global_position")
	var text := "%d m" % int(world.call("meters_at", position.x))
	if label.text != text:
		label.text = text


## The editor resaves `game.tscn` (it adds `unique_id`/`node_paths`) and can
## drop nodes added by hand, so the screen is instanced here when the scene does
## not carry it. Without this the run ended in silence: the player died and
## nothing appeared.
func _ensure_death_screen() -> void:
	if get_node_or_null("DeathScreen") != null:
		return
	var scene := load(DEATH_SCREEN_SCENE) as PackedScene
	if scene == null:
		return
	var screen := scene.instantiate()
	if screen == null:
		return
	screen.name = "DeathScreen"
	add_child(screen)
