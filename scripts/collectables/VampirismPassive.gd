class_name VampirismPassive
extends PassiveItems
## Restores health every time the player kills an enemy.

@export_group("Vampirism")
## Health restored per killed enemy.
@export var heal_on_kill: int = 2


func on_enemy_killed(player: Node, _enemy: Node) -> void:
	if heal_on_kill > 0 and player.has_method("heal"):
		player.call("heal", heal_on_kill)
