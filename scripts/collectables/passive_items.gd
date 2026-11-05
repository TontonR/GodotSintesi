class_name PassiveItems
extends Collectable

@export_group("Passive Setup")
@export var passive_id: String = "pasiva_basica"

## Called automatically when the passive is equipped
func on_equip(_player: Node) -> void:
	print("Pasiva equipada: ", item_name)

## Called automatically when the passive is unequipped
func on_unequip(_player: Node) -> void:
	print("Pasiva desequipada: ", item_name)

## Event: the player attacks
func on_player_attack(_target: Node, damage: float) -> float:
	return damage # Devuelve el daño modificado

## Event: the player takes damage (attacker may be null)
func on_player_take_damage(amount: float, _attacker: Node = null) -> float:
	return amount # Devuelve el daño recibido modificado

## Event: the player starts an attack (step = 1, 2, 3... of the combo)
func on_player_attack_started(_player: Node, _step: int, _direction: Vector2) -> void:
	pass

## Event: the player blocks a frontal hit with the guard
func on_player_blocked(_player: Node) -> void:
	pass

## Event: the player kills an enemy
func on_enemy_killed(_player: Node, _enemy: Node) -> void:
	pass

## Event: per-frame processing with delta (optional)
func on_update(_player: Node, _delta: float) -> void:
	pass

## On pickup it is equipped as an active player passive; only once per run.
func on_pickup(player: Node) -> bool:
	# Acceso por nombre para no crear referencia cíclica con PlayerPassives
	var passives := player.get_node_or_null("PlayerPassives") as PlayerPassives
	if passives == null:
		return false
	return passives.add_passive(self)
