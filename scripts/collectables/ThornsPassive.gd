class_name ThornsPassive
extends PassiveItems
## Devuelve parte del daño recibido al atacante, con cooldown y tope.

@export_group("Espinas")
## Fracción del daño recibido que se devuelve (0.2 = 20%).
@export_range(0.0, 1.0, 0.05) var damage_ratio: float = 0.2
## Daño máximo devuelto por activación.
@export var max_reflect: int = 15
## Segundos de espera entre devoluciones.
@export var cooldown: float = 2.0

var _cooldown_left: float = 0.0


func on_equip(player: Node) -> void:
	super.on_equip(player)
	_cooldown_left = 0.0


func on_update(_player: Node, delta: float) -> void:
	_cooldown_left = maxf(_cooldown_left - delta, 0.0)


func on_player_take_damage(amount: float, attacker: Node = null) -> float:
	if attacker == null or _cooldown_left > 0.0:
		return amount
	if not attacker.has_method("take_damage"):
		return amount

	var reflected := mini(roundi(amount * damage_ratio), max_reflect)
	if reflected <= 0:
		return amount

	_cooldown_left = cooldown
	attacker.call("take_damage", reflected)
	return amount
