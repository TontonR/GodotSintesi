class_name PlayerPassives
extends Node

## Se emite cuando cambia la lista de pasivas activas
signal passives_changed

# El único Array que almacena todos los objetos pasivos activos
var active_passives: Array[PassiveItems] = []

func _ready() -> void:
	# Enlaza la lista de la interfaz (mismo patrón que Inventory con su barra)
	var player := get_parent()
	if player == null or player.get_parent() == null:
		return
	var bar := player.get_parent().get_node_or_null("UILayer/PassiveBar")
	if bar:
		bar.call("bind", self)

## Añadir un nuevo item pasivo al Array
func add_passive(passive: PassiveItems) -> void:
	active_passives.append(passive)
	passive.on_equip(get_parent()) # 'get_parent()' asume que es el nodo Jugador
	passives_changed.emit()

## Quitar un item pasivo del Array
func remove_passive(passive: PassiveItems) -> void:
	if passive in active_passives:
		passive.on_unequip(get_parent())
		active_passives.erase(passive)
		passives_changed.emit()

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
