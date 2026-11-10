extends Node2D

# ==============================================================================
# GAME ROOT
# ==============================================================================
# Applies a pending save (Continue) once every child is ready: the world
# generator already used the saved seed and spawn state, and `FallIntro` skipped
# itself, so only the player state has to be put back here.


func _ready() -> void:
	if not SaveGame.pending_load:
		return
	SaveGame.pending_load = false

	var intro := get_node_or_null("fall_intro")
	if intro:
		intro.queue_free()

	var player := get_node_or_null("player")
	if player == null:
		return

	# Passives first: their equip effects raise maxima before health is clamped.
	var passives := player.get_node_or_null("PlayerPassives")
	if passives:
		passives.call("restore_from_save", SaveGame.data.get("passives", []))
	var inventory := player.get_node_or_null("Inventory")
	if inventory:
		inventory.call("restore_from_save", SaveGame.data.get("items", []))

	player.set("global_position", SaveGame.data.get("position", player.get("global_position")))
	player.set("velocity", Vector2.ZERO)
	player.set("control_enabled", true)
	player.set("camera_follow_enabled", true)
	player.set("fall_speed_cap", 0.0)
	# Drop the cached camera Y so the follow doesn't drag from the spawn point.
	player.set("_cam_y", NAN)
	player.call("restore_run_state", SaveGame.data.get("health", 100), SaveGame.data.get("stamina", 100.0), SaveGame.data.get("coins", 0))

	var camera := player.get_node_or_null("Camera2D") as Camera2D
	if camera:
		camera.reset_smoothing()

	var world := get_node_or_null("map")
	if world:
		world.call("refresh_chunks")

	var ui := get_node_or_null("UILayer")
	if ui:
		ui.visible = true
