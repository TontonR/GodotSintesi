class_name ItemPickup
extends Area2D

# Estructura para definir ítems y su probabilidad de aparición
@export_group("Lista de Pociones y Probabilidades")
## Lista de objetos pasivos (.tres) que pueden aparecer aquí
@export var possible_items: Array[PassiveItems] = [ ]
## Probabilidad de cada ítem (deben coincidir en cantidad con possible_items). Ej: [70, 20, 10]
@export var spawn_weights: Array[float] = []

@export_group("Configuración de Interacción")
@export var action_prompt: String = "interact" # Nombre de la acción en el Map de Entradas

var current_item: PassiveItems = null
var _player_in_range: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	# Determina qué poción se genera en esta instancia basada en porcentajes
	_generate_random_item()

func _unhandled_input(event: InputEvent) -> void:
	# Si el jugador está cerca y pulsa la tecla de interacción
	if _player_in_range and event.is_action_pressed(action_prompt):
		_interact_with_item()

func _generate_random_item() -> void:
	if possible_items.is_empty():
		return

	# Si no configuraste pesos/porcentajes, elige una totalmente al azar
	if spawn_weights.size() != possible_items.size():
		current_item = possible_items.pick_random()
	else:
		current_item = _get_weighted_random_item()

	# Asigna el icono del ítem elegido al Sprite
	if current_item and current_item.icon and sprite:
		sprite.texture = current_item.icon

func _get_weighted_random_item() -> PassiveItems:
	var total_weight: float = 0.0
	for w in spawn_weights:
		total_weight += w

	var roll := randf_range(0.0, total_weight)
	var accumulated: float = 0.0

	for i in range(possible_items.size()):
		accumulated += spawn_weights[i]
		if roll <= accumulated:
			return possible_items[i]

	return possible_items[0]

func _interact_with_item() -> void:
	if not is_instance_valid(_player_in_range) or not current_item:
		return

	# Busca el nodo de pasivas en el jugador
	var passives_node = _player_in_range.get_node_or_null("PlayerPassives") as PlayerPassives
	if passives_node:
		passives_node.add_passive(current_item)
		print("Poción recogida: ", current_item.item_name)
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
