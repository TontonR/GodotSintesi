class_name SaveGame
extends RefCounted

# ==============================================================================
# SAVE SLOT
# ==============================================================================
# One run slot in `user://savegame.cfg`. It stores the world seed, the player
# position and stats, the inventory, the active passives and the spawn ids that
# must not come back (killed enemies, collected coins). Static on purpose: the
# pending load has to survive the `change_scene_to_file()` between menu and game.

const SAVE_PATH := "user://savegame.cfg"
const VERSION := 1

## True between `request_load()` and the game scene applying the save.
static var pending_load: bool = false
## Seed typed in the menu for the next New Game; 0 = random. Static so it
## survives the `change_scene_to_file()`, like the pending load.
static var pending_seed: int = 0
## Data read by `request_load()`, consumed by `scripts/game.gd`.
static var data: Dictionary = {}


static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)


static func save_run(world: Node, player: Node) -> bool:
	if world == null or player == null:
		return false
	var config := ConfigFile.new()
	config.set_value("run", "version", VERSION)
	config.set_value("run", "seed", int(world.call("current_seed")))
	config.set_value("run", "position", player.get("global_position"))
	config.set_value("run", "health", int(player.get("health")))
	config.set_value("run", "stamina", float(player.get("stamina")))
	config.set_value("run", "coins", int(player.get("current_coins")))
	var inventory := player.get_node_or_null("Inventory")
	config.set_value("inventory", "items", inventory.call("serialized_slots") if inventory else PackedStringArray())
	var passives := player.get_node_or_null("PlayerPassives")
	config.set_value("passives", "items", passives.call("serialized_passives") if passives else PackedStringArray())
	var state: Dictionary = world.call("save_persistent_state")
	config.set_value("world", "defeated", state.get("defeated", PackedStringArray()))
	config.set_value("world", "collected", state.get("collected", PackedStringArray()))
	return config.save(SAVE_PATH) == OK


## Reads the slot and leaves it pending for the next game scene.
static func request_load() -> bool:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return false
	data = {
		"seed": int(config.get_value("run", "seed", 0)),
		"position": config.get_value("run", "position", Vector2.ZERO),
		"health": int(config.get_value("run", "health", 100)),
		"stamina": float(config.get_value("run", "stamina", 100.0)),
		"coins": int(config.get_value("run", "coins", 0)),
		"items": Array(config.get_value("inventory", "items", PackedStringArray())),
		"passives": Array(config.get_value("passives", "items", PackedStringArray())),
		"defeated": Array(config.get_value("world", "defeated", PackedStringArray())),
		"collected": Array(config.get_value("world", "collected", PackedStringArray())),
	}
	pending_load = true
	return true


## New Game: a pending Continue must not leak into a fresh run.
static func cancel_pending_load() -> void:
	pending_load = false
	data = {}
	pending_seed = 0
