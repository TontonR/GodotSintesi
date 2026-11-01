class_name CritPassive
extends PassiveItems
## Pasiva: algunos golpes del jugador se vuelven críticos y pegan más.

@export_group("Critical Hit")
## Probabilidad (0-1) de que un golpe sea crítico.
@export_range(0.0, 1.0, 0.05) var crit_chance: float = 0.2
## Multiplicador de daño del golpe crítico.
@export var crit_multiplier: float = 1.8


func on_player_attack(_target: Node, damage: float) -> float:
	if randf() >= crit_chance:
		return damage
	return damage * crit_multiplier
