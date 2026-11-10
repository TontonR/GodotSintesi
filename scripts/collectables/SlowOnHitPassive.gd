class_name SlowOnHitPassive
extends PassiveItems
## Frog tongue: hitting an enemy lowers its speed for a while.

@export_group("Slowdown")
## Speed multiplier left on the enemy (0.5 = half).
@export_range(0.1, 1.0, 0.05) var slow_multiplier: float = 0.5
## Seconds the slowdown lasts.
@export var slow_seconds: float = 3.0


func on_player_attack(target: Node, damage: float) -> float:
	if target == null:
		return damage
	# The hit may land on the enemy body or on a child Area2D.
	var enemy: Node = target
	if not enemy.has_method("apply_slow"):
		enemy = enemy.get_parent()
	if enemy and enemy.has_method("apply_slow"):
		enemy.call("apply_slow", slow_multiplier, slow_seconds)
	return damage
