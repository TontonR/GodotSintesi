class_name PassiveItems
extends Items

@export_group("Configuración Pasiva")
@export var passive_id: String = "pasiva_basica"

## Se llama automáticamente cuando el objeto entra al inventario
func on_equip(player: Node) -> void:
	print("Pasiva equipada: ", item_name)

## Se llama automáticamente cuando el objeto sale del inventario
func on_unequip(player: Node) -> void:
	print("Pasiva desequipada: ", item_name)

## Evento: cuando el jugador ataca
func on_player_attack(target: Node, damage: float) -> float:
	return damage # Devuelve el daño modificado

## Evento: cuando el jugador recibe daño
func on_player_take_damage(amount: float) -> float:
	return amount # Devuelve el daño recibido modificado

## Evento: procesamiento por frame o tiempo (opcional)
func on_update(player: Node, delta: float) -> void:
	pass
