class_name AlmaPenaPassive
extends PassiveItems
## Wandering soul: enemies affected by a damage-over-time take more damage.

@export_group("Wandering soul")
## Extra damage against a target with any DOT (0.10 = +10%).
@export_range(0.0, 1.0, 0.01) var damage_bonus: float = 0.10


func on_player_attack(target: Node, damage: float) -> float:
	if _enemy_with_dot(target) != null:
		return damage * (1.0 + damage_bonus)
	return damage


func _enemy_with_dot(target: Node) -> Node:
	var node := target
	for _i in 4:
		if node == null:
			return null
		if node.has_method("has_dot") and bool(node.call("has_dot")):
			return node
		node = node.get_parent()
	return null
