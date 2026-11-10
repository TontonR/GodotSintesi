class_name LightFeetPassive
extends PassiveItems
## Increases the player movement speed on pickup.

@export_group("Light feet")
## Speed multiplier (1.15 = +15%).
@export var speed_multiplier: float = 1.15


func on_equip(player: Node) -> void:
	super.on_equip(player)
	if player.has_method("multiply_move_speed"):
		player.call("multiply_move_speed", speed_multiplier)
