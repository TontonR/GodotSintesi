class_name AttackBonusPassive
extends PassiveItems

@export_group("Bonificación de Ataque")
## Daño extra añadido a cada golpe
@export var bonus: float = 6.0

func on_player_attack(_target: Node, damage: float) -> float:
	return damage + bonus
