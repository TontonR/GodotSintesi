class_name HunterPassive
extends PassiveItems
## Aumenta el daño contra enemigos que están por debajo de un umbral de vida.

@export_group("Cazador")
## Daño extra contra el objetivo debilitado (0.2 = +20%).
@export_range(0.0, 2.0, 0.05) var damage_bonus: float = 0.2
## Fracción de vida del enemigo por debajo de la cual se aplica.
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
