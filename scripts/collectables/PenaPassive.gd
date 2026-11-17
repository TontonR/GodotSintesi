class_name PenaPassive
extends PassiveItems
## Sorrow: a target with more than three burns receives a special burn that
## does not count towards the normal stack limit.

@export_group("Sorrow")
## Normal burns needed to trigger the special burn.
@export var required_burns: int = 3
## Extra strength over the base burn (0.25 = +25%).
@export_range(0.0, 2.0, 0.01) var extra_ratio: float = 0.25
## Special burn duration in seconds.
@export var burn_seconds: float = 5.0


func on_player_attack(target: Node, damage: float) -> float:
	var enemy := _enemy(target)
	if enemy != null:
		# Deferred so the ashes passive has already added its burn.
		call_deferred("_apply_pena", enemy, damage)
	return damage


func _apply_pena(enemy: Node, damage: float) -> void:
	if not is_instance_valid(enemy):
		return
	if not enemy.has_method("get_burn_count") or not enemy.has_method("apply_burn"):
		return
	if int(enemy.call("get_burn_count")) <= required_burns:
		return
	if enemy.has_method("has_special_burn") and bool(enemy.call("has_special_burn")):
		return
	var base_dps := maxf(damage * 0.05, 0.5)
	enemy.call("apply_burn", base_dps * (1.0 + extra_ratio), burn_seconds, 5, true)


func _enemy(target: Node) -> Node:
	var node := target
	for _i in 4:
		if node == null:
			return null
		if node.has_method("apply_burn"):
			return node
		node = node.get_parent()
	return null
