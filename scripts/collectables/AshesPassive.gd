class_name AshesPassive
extends PassiveItems
## Ashes of suffering: every hit applies a stacking burn.

@export_group("Ashes")
## Burn damage per second as a fraction of the hit (0.05 = 5%).
@export_range(0.0, 1.0, 0.01) var burn_ratio: float = 0.05
## Burn duration in seconds.
@export var burn_seconds: float = 5.0
## Maximum simultaneous normal burns.
@export var max_stacks: int = 5


func on_player_attack(target: Node, damage: float) -> float:
	var enemy := _enemy(target)
	if enemy != null:
		var dps := maxf(damage * burn_ratio, 0.5)
		enemy.call("apply_burn", dps, burn_seconds, max_stacks, false)
	return damage


func _enemy(target: Node) -> Node:
	var node := target
	for _i in 4:
		if node == null:
			return null
		if node.has_method("apply_burn"):
			return node
		node = node.get_parent()
	return null
