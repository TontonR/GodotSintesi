class_name GuardianWrathPassive
extends PassiveItems
## Al bloquear un ataque, aumenta temporalmente el daño infligido.

@export_group("Ira del guardián")
## Daño extra mientras dura el enfado (0.3 = +30%).
@export_range(0.0, 2.0, 0.05) var damage_bonus: float = 0.3
## Duración del aumento de daño en segundos.
@export var duration: float = 10.0

var _time_left: float = 0.0


func on_equip(player: Node) -> void:
	super.on_equip(player)
	_time_left = 0.0


func on_player_blocked(_player: Node) -> void:
	_time_left = duration


func on_update(_player: Node, delta: float) -> void:
	_time_left = maxf(_time_left - delta, 0.0)


func on_player_attack(_target: Node, damage: float) -> float:
	if _time_left <= 0.0:
		return damage
	return damage * (1.0 + damage_bonus)
