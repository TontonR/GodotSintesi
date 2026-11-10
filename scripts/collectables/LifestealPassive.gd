class_name LifestealPassive
extends PassiveItems
## Passive: the player restores health every time they land a hit.

@export_group("Lifesteal")
## Health restored per landed hit.
@export var heal_per_hit: int = 2

## The player is stored because `on_player_attack` does not receive it.
var _player: Node = null


func on_equip(player: Node) -> void:
	_player = player


func on_unequip(_player: Node) -> void:
	_player = null


func on_player_attack(_target: Node, damage: float) -> float:
	if heal_per_hit > 0 and is_instance_valid(_player) and _player.has_method("heal"):
		_player.heal(heal_per_hit)
	return damage
