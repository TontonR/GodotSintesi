class_name RangedMasteryPassive
extends PassiveItems
## Ranged mastery: hits against distant targets deal extra damage.

@export_group("Ranged mastery")
## Minimum distance to the target (px).
@export var min_distance: float = 80.0
## Extra damage (0.15 = +15%).
@export_range(0.0, 2.0, 0.01) var damage_bonus: float = 0.15

var _player: Node2D = null


func on_equip(player: Node) -> void:
	_player = player as Node2D


func on_unequip(_player: Node) -> void:
	_player = null


func on_player_attack(target: Node, damage: float) -> float:
	if _player == null or not is_instance_valid(_player) or not target is Node2D:
		return damage
	var target_2d := target as Node2D
	if _player.global_position.distance_to(target_2d.global_position) >= min_distance:
		return damage * (1.0 + damage_bonus)
	return damage
