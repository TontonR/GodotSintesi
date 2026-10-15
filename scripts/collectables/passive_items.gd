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

## Event: the player takes damage
func on_player_take_damage(amount: float) -> float:
	return amount # Devuelve el daño recibido modificado

## Event: per-frame processing with delta (optional)
func on_update(_player: Node, _delta: float) -> void:
	pass

## On pickup it is equipped as an active player passive
func on_pickup(player: Node) -> bool:
	# Acceso por nombre para no crear referencia cíclica con PlayerPassives
	var passives := player.get_node_or_null("PlayerPassives")
	if passives == null or not passives.has_method("add_passive"):
		return false
	passives.add_passive(self)
	return true
