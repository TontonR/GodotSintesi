class_name AttackBonusPassive
extends PassiveItems

@export_group("Attack Bonus")
## Extra damage added to every hit
@export var bonus: float = 6.0

func on_player_attack(_target: Node, damage: float) -> float:
	return damage + bonus
