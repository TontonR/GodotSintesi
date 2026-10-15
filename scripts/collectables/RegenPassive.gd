class_name RegenPassive
extends PassiveItems

@export_group("Regeneration")
## Health restored every `interval` seconds
@export var heal_per_tick: int = 1
## Seconds elapsed between each heal tick
@export var interval: float = 1.0

var _timer: float = 0.0

func on_update(player: Node, delta: float) -> void:
	_timer += delta
	if _timer < interval:
		return
	_timer -= interval
	if heal_per_tick > 0 and player.has_method("heal"):
		player.heal(heal_per_tick)
