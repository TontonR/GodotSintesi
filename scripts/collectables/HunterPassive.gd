class_name HunterPassive
extends PassiveItems
## Increases the damage against enemies below a health threshold.

@export_group("Hunter")
## Extra damage against the weakened target (0.2 = +20%).
@export_range(0.0, 2.0, 0.05) var damage_bonus: float = 0.2
## Enemy health fraction below which it applies.
@export_range(0.0, 1.0, 0.05) var health_threshold: float = 0.3


func on_player_attack(target: Node, damage: float) -> float:
	if target == null or not ("health" in target) or not ("max_health" in target):
		return damage
	var max_h := float(target.get("max_health"))
	if max_h <= 0.0:
		return damage
	var health := float(target.get("health"))
	if health / max_h <= health_threshold:
		return damage * (1.0 + damage_bonus)
	return damage
