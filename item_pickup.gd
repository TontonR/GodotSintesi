class_name ItemPickup
extends Area2D

@export_group("Objeto")
## Objeto que entrega esta entidad al ser recogida
@export var item: Items

@export_group("Configuración de Interacción")
## Nombre de la acción en el Mapa de Entradas
@export var action_prompt: String = "interact"

var _player_in_range: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

	if item and item.icon and sprite:
		sprite.texture = item.icon

func _unhandled_input(event: InputEvent) -> void:
	# Si el jugador está cerca y pulsa la tecla de interacción
	if _player_in_range and event.is_action_pressed(action_prompt):
		_interact_with_item()

func _interact_with_item() -> void:
	if not is_instance_valid(_player_in_range) or item == null:
		return

	# El objeto decide dónde va al recogerlo (barra o pasivas)
	if item.has_method("on_pickup") and item.on_pickup(_player_in_range):
		queue_free()

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
