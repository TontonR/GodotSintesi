class_name MocoLevelPassive
extends PassiveItems
## Slime and compact slime: they raise the player slime emitter level.
## The mucosil heart doubles the slime already present.

@export_group("Slime")
## Slime levels it adds (more particles and more defense).
@export var level_bonus: int = 1
## When true, it doubles the slime the player already had.
@export var doubles_level: bool = false

var _applied: int = 0


func on_equip(player: Node) -> void:
	super.on_equip(player)
	if not player.has_method("moco_emitter"):
		return
	var emitter: Node = player.call("moco_emitter")
	if emitter == null:
		return
	if doubles_level:
		_applied = int(emitter.call("get_level"))
		emitter.call("multiply_level", 2.0)
		_applied = int(emitter.call("get_level")) - _applied
	else:
		_applied = level_bonus
		emitter.call("add_level", level_bonus)


func on_unequip(player: Node) -> void:
	super.on_unequip(player)
	if _applied == 0 or not player.has_method("moco_emitter"):
		return
	var emitter: Node = player.call("moco_emitter")
	if emitter:
		emitter.call("add_level", -_applied)
	_applied = 0
