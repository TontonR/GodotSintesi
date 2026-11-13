class_name SaveGame
extends RefCounted

# ==============================================================================
# RUN SLOTS
# ==============================================================================
# Up to three runs in `user://run_slot_N.cfg` (N = 1..3). Each slot stores the
# world seed, the player position and stats, the inventory, the active passives
# and the spawn ids that must not come back (killed enemies, collected coins).
# Static on purpose: the pending load has to survive the
# `change_scene_to_file()` between menu and game.
#
# A run lives in exactly one slot: `current_slot` is set by the menu (new run or
# load) and every in-game save goes there. Death erases that slot, so a dead run
# can never be continued; starting a new run in an occupied slot erases it at
# once instead of waiting for the first save.

const SLOT_COUNT := 3
const VERSION := 1
## `user://run_slot_1.cfg` … `user://run_slot_3.cfg`.
const SLOT_FILE_FORMAT := "user://run_slot_%d.cfg"
## Spawn point in pixels (`safe_start_tiles` 50 in `game.tscn` × 16 + 8); only
## used to read the meters of saves written before `[run] meters` existed.
const SPAWN_X := 808.0

## True between `request_load()` and the game scene applying the save.
static var pending_load: bool = false
## Slot (0-based) of the run being played; -1 = none (e.g. scene run from the
## editor without the menu).
static var current_slot: int = -1
## Seed typed in the menu for the next new run; 0 = random. Static so it
## survives the `change_scene_to_file()`, like the pending load.
static var pending_seed: int = 0
## Data read by `request_load()`, consumed by `scripts/game.gd`.
static var data: Dictionary = {}


static func is_valid_slot(slot: int) -> bool:
	return slot >= 0 and slot < SLOT_COUNT


static func slot_path(slot: int) -> String:
	return SLOT_FILE_FORMAT % (slot + 1)


static func slot_exists(slot: int) -> bool:
	return is_valid_slot(slot) and FileAccess.file_exists(slot_path(slot))


## First empty slot, or -1 when the three are taken.
static func first_free_slot() -> int:
	for slot in SLOT_COUNT:
		if not slot_exists(slot):
			return slot
	return -1


## True while a new run fits without erasing anything.
static func has_free_slot() -> bool:
	return is_valid_slot(first_free_slot())


## Slot written most recently (the last run closed), or -1 when there is none.
static func latest_slot() -> int:
	var best := -1
	var best_time := -1
	for slot in SLOT_COUNT:
		if not slot_exists(slot):
			continue
		var written_at := int(FileAccess.get_modified_time(slot_path(slot)))
		if written_at > best_time:
			best_time = written_at
			best = slot
	return best


## Cheap read for the menu rows: only what the label shows.
static func slot_summary(slot: int) -> Dictionary:
	var summary := {"exists": false, "seed": 0, "coins": 0, "meters": 0}
	if not slot_exists(slot):
		return summary
	var config := ConfigFile.new()
	if config.load(slot_path(slot)) != OK:
		return summary
	summary["exists"] = true
	summary["seed"] = int(config.get_value("run", "seed", 0))
	summary["coins"] = int(config.get_value("run", "coins", 0))
	summary["meters"] = int(config.get_value("run", "meters", _meters_from_position(config)))
	return summary


## Fallback for slots saved before `[run] meters`: the counter is derived from
## the saved world position and the fixed spawn point.
static func _meters_from_position(config: ConfigFile) -> int:
	var position: Vector2 = config.get_value("run", "position", Vector2.ZERO)
	return floori((position.x - SPAWN_X) / 16.0)


## New run in `slot`: the previous save there (if any) is erased right away, so
## a crash or a death before the first save cannot bring the old run back.
static func start_new_run(slot: int) -> void:
	cancel_pending_load()
	current_slot = slot if is_valid_slot(slot) else -1
	delete_slot(current_slot)


## Ends the run stored in `slot`: the file is gone, so it cannot be continued.
static func delete_slot(slot: int) -> void:
	if not slot_exists(slot):
		return
	var dir := DirAccess.open("user://")
	if dir:
		dir.remove(slot_path(slot).get_file())


## Writes the current run into `current_slot`. A dead player is never saved.
static func save_run(world: Node, player: Node) -> bool:
	if world == null or player == null:
		return false
	if int(player.get("health")) <= 0:
		return false
	if not is_valid_slot(current_slot):
		var free := first_free_slot()
		current_slot = free if is_valid_slot(free) else 0
	var config := ConfigFile.new()
	var position: Vector2 = player.get("global_position")
	config.set_value("run", "version", VERSION)
	config.set_value("run", "seed", int(world.call("current_seed")))
	config.set_value("run", "position", position)
	config.set_value("run", "meters", int(world.call("meters_at", position.x)))
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
	return config.save(slot_path(current_slot)) == OK


## Reads `slot` and leaves it pending for the next game scene.
static func request_load(slot: int) -> bool:
	if not slot_exists(slot):
		return false
	var config := ConfigFile.new()
	if config.load(slot_path(slot)) != OK:
		return false
	current_slot = slot
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
