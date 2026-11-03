class_name StatBonusPassive
extends PassiveItems

@export_group("Stat Bonus")
## Extra max health on equip. It does not heal (the new room stays empty).
@export var bonus_max_health: int = 0
## Extra max stamina on equip.
@export var bonus_max_stamina: float = 0.0
## Extra damage added to every hit.
@export var bonus_attack: int = 0
## Extra movement speed in px/s.
@export var bonus_speed: float = 0.0

var _player: Node = null


func on_equip(player: Node) -> void:
	_player = player
	_apply(1)


func on_unequip(_player: Node) -> void:
	_apply(-1)
	_player = null


## `sign` 1 equips, -1 unequips: siempre se aplica lo mismo, en un sentido u otro.
func _apply(sign: int) -> void:
	if not is_instance_valid(_player):
		return
	if bonus_max_health != 0 and _player.has_method("add_max_health"):
		_player.call("add_max_health", bonus_max_health * sign)
	if bonus_max_stamina != 0.0 and _player.has_method("add_max_stamina"):
		_player.call("add_max_stamina", bonus_max_stamina * sign)
	if bonus_attack != 0 and _player.has_method("add_attack_bonus"):
		_player.call("add_attack_bonus", bonus_attack * sign)
	if bonus_speed != 0.0 and _player.has_method("add_speed_bonus"):
		_player.call("add_speed_bonus", bonus_speed * sign)
