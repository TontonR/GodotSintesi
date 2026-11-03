class_name GreedPassive
extends PassiveItems
## Otorga monedas extra cada vez que el jugador mata a un enemigo.

@export_group("Codicia")
## Monedas extra por enemigo muerto.
@export var coins_on_kill: int = 1


func on_enemy_killed(player: Node, _enemy: Node) -> void:
	if coins_on_kill > 0 and player.has_method("add_coin"):
		player.call("add_coin", coins_on_kill)
