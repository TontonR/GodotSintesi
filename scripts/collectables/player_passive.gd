class_name PlayerPassives
extends Node

# El único Array que almacena todos los objetos pasivos activos
var active_passives: Array[PassiveItems] = []

## Añadir un nuevo item pasivo al Array
func add_passive(passive: PassiveItems) -> void:
	active_passives.append(passive)
	passive.on_equip(get_parent()) # 'get_parent()' asume que es el nodo Jugador

## Quitar un item pasivo del Array
func remove_passive(passive: PassiveItems) -> void:
	if passive in active_passives:
		passive.on_unequip(get_parent())
		active_passives.erase(passive)

## Cuando el jugador ataca, ejecuta este método
func trigger_attack_passives(target: Node, base_damage: float) -> float:
	var current_damage = base_damage
	for passive in active_passives:
		current_damage = passive.on_player_attack(target, current_damage)
	return current_damage

## Cuando el jugador recibe daño, ejecuta este método
func trigger_take_damage_passives(base_damage: float) -> float:
	var current_damage = base_damage
	for passive in active_passives:
		current_damage = passive.on_player_take_damage(current_damage)
	return current_damage

## Bucle de actualización para pasivas con temporizadores/regeneración
func _process(delta: float) -> void:
	for passive in active_passives:
		passive.on_update(get_parent(), delta)
