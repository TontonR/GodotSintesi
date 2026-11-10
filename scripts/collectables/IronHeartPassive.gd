class_name IronHeartPassive
extends PassiveItems
## Increases the player max health on pickup.

@export_group("Iron heart")
## Extra max health it grants.
@export var max_health_bonus: int = 25


func on_equip(player: Node) -> void:
	super.on_equip(player)
	if player.has_method("add_max_health"):
		player.call("add_max_health", max_health_bonus)
