class_name MocoLevelPassive
extends PassiveItems
## Moco y moco compacto: suben el nivel del emisor de moco del jugador.
## El corazón mucosil dobla el moco que ya hubiera.

@export_group("Moco")
## Niveles de moco que añade (más partículas y más defensa).
@export var level_bonus: int = 1
## Si es true, duplica el moco que ya tuviera el jugador.
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
