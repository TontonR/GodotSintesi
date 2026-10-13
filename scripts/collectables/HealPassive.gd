class_name HealPassive
extends PassiveItems

@export_group("Curación")
@export var heal_amount: float = 25.0

func on_equip(player: Node) -> void:
	super.on_equip(player)
	# Si es de consumo inmediato al recoger/equipar:
	if player.has_method("heal"):
		player.heal(heal_amount)
	elif "health" in player and "max_health" in player:
		player.health = minf(player.health + heal_amount, player.max_health)
