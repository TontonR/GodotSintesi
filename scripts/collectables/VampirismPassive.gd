class_name VampirismPassive
extends PassiveItems
## Recupera vida cada vez que el jugador mata a un enemigo.

@export_group("Vampirismo")
## Vida recuperada por enemigo muerto.
@export var heal_on_kill: int = 2


func on_enemy_killed(player: Node, _enemy: Node) -> void:
	if heal_on_kill > 0 and player.has_method("heal"):
		player.call("heal", heal_on_kill)
