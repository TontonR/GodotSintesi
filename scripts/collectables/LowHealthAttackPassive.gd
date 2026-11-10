class_name LowHealthAttackPassive
extends PassiveItems

@export_group("Low Health Bonus")
## Health fraction below which the bonus applies (0.3 = 30% of max health).
@export_range(0.0, 1.0, 0.01) var health_threshold: float = 0.3
## Attack multiplier applied while the player is below the threshold.
@export var damage_multiplier: float = 1.2

var _player: Node = null
## Extra damage currently added to the player's hitbox.
var _applied: int = 0


func on_equip(player: Node) -> void:
	_player = player
	_refresh()


func on_unequip(_player: Node) -> void:
	_set_bonus(0)


func on_update(_player: Node, _delta: float) -> void:
	_refresh()


func _refresh() -> void:
	if not is_instance_valid(_player) or not ("health" in _player and "max_health" in _player):
		return
	var ratio := float(_player.health) / float(maxi(int(_player.max_health), 1))
	_set_bonus(_bonus_for(_base_attack()) if ratio < health_threshold else 0)


## Damage without our bonus, so the flat bonuses of other passives are not overwritten.
func _base_attack() -> int:
	return int(_player.hitbox_damage) - _applied


func _bonus_for(base: int) -> int:
	return roundi(float(base) * (damage_multiplier - 1.0))


func _set_bonus(bonus: int) -> void:
	if not is_instance_valid(_player) or not ("hitbox_damage" in _player):
		return
	if bonus == _applied:
		return
	_player.hitbox_damage += bonus - _applied
	_applied = bonus
