class_name GreedPassive
extends PassiveItems
## Grants extra coins every time the player kills an enemy.

@export_group("Greed")
## Extra coins per killed enemy.
@export var coins_on_kill: int = 1


func on_enemy_killed(player: Node, _enemy: Node) -> void:
	if coins_on_kill > 0 and player.has_method("add_coin"):
		player.call("add_coin", coins_on_kill)
