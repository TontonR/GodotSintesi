class_name SkullPassive
extends PassiveItems
## Skull: trades max health for a small reflection on every hit taken.

@export_group("Skull")
## Max health removed while equipped.
@export var max_health_penalty: int = 20
## Fraction of the player's current health reflected (0.05 = 5%).
@export_range(0.0, 1.0, 0.01) var reflect_ratio: float = 0.05

var _player: Node = null
var _applied: bool = false


func on_equip(player: Node) -> void:
	_player = player
	_applied = false
	if player.has_method("add_max_health"):
		player.call("add_max_health", -max_health_penalty)
		_applied = true


func on_unequip(_player: Node) -> void:
	if _applied and is_instance_valid(_player) and _player.has_method("add_max_health"):
		_player.call("add_max_health", max_health_penalty)
	_applied = false
	_player = null


func on_player_take_damage(amount: float, attacker: Node = null) -> float:
	if not is_instance_valid(_player) or attacker == null or not attacker.has_method("take_damage"):
		return amount
	var current_health_value = _player.get("health")
	var current_health: float = float(current_health_value) if current_health_value != null else 0.0
	var reflected := maxi(roundi(current_health * reflect_ratio), 1)
	attacker.call("take_damage", reflected)
	return amount
