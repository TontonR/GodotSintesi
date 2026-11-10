class_name CritPassive
extends PassiveItems
## Passive: some of the player hits become critical and deal more damage.

@export_group("Critical Hit")
## Chance (0-1) of a hit being critical.
@export_range(0.0, 1.0, 0.05) var crit_chance: float = 0.2
## Damage multiplier of the critical hit.
@export var crit_multiplier: float = 1.8


func on_player_attack(_target: Node, damage: float) -> float:
	if randf() >= crit_chance:
		return damage
	return damage * crit_multiplier
