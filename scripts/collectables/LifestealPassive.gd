class_name LifestealPassive
extends PassiveItems
## Pasiva: el jugador recupera vida cada vez que acierta un golpe.

@export_group("Lifesteal")
## Vida recuperada por cada golpe acertado.
@export var heal_per_hit: int = 2

## Se guarda el jugador porque `on_player_attack` no lo recibe.
var _player: Node = null


func on_equip(player: Node) -> void:
	_player = player


func on_unequip(_player: Node) -> void:
	_player = null


func on_player_attack(_target: Node, damage: float) -> float:
	if heal_per_hit > 0 and is_instance_valid(_player) and _player.has_method("heal"):
		_player.heal(heal_per_hit)
	return damage
