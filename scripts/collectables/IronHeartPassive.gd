class_name IronHeartPassive
extends PassiveItems
## Aumenta la vida máxima del jugador al recogerla.

@export_group("Corazón de hierro")
## Vida máxima extra que otorga.
@export var max_health_bonus: int = 25


func on_equip(player: Node) -> void:
	super.on_equip(player)
	if player.has_method("add_max_health"):
		player.call("add_max_health", max_health_bonus)
