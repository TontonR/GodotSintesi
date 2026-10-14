class_name ItemPickup
extends Area2D

## Media altura del sprite (px): el objeto descansa con la base sobre el suelo
const MEDIO_ALTO: float = 8.0
## Capa física del mundo (suelo y plataformas)
const CAPA_MUNDO: int = 1
## Distancia máxima de búsqueda del suelo al aparecer (px)
const DISTANCIA_SUELO: float = 1024.0

@export_group("Objeto")
## Objeto que entrega esta entidad al ser recogida
@export var item: Items

@export_group("Configuración de Interacción")
## Nombre de la acción en el Mapa de Entradas
@export var action_prompt: String = "interact"

@export_group("Física")
## Gravedad al caer (px/s²)
@export var gravity: float = 900.0
## Rebote tras el impacto con el suelo (0 = sin rebote)
@export var bounce: float = 0.45
## Velocidad de impacto mínima para llegar a rebotar (px/s)
@export var min_bounce_speed: float = 35.0
## Altura del vaivén flotante en bucle (px)
@export var float_height: float = 1.5
## Velocidad del vaivén (radianes/segundo)
@export var float_speed: float = 2.5

enum Estado { CAYENDO, FLOTANDO }

var _estado: int = Estado.CAYENDO
var _velocidad_y: float = 0.0
var _y_reposo: float = 0.0
var _fase: float = 0.0
var _tiempo: float = 0.0
var _player_in_range: CharacterBody2D = null

@onready var sprite: Sprite2D = $Sprite2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_fase = randf() * TAU
	_buscar_suelo()

	if item and item.icon and sprite:
		sprite.texture = item.icon

func _physics_process(delta: float) -> void:
	if _estado == Estado.FLOTANDO:
		_tiempo += delta
		global_position.y = _y_reposo + sin(_tiempo * float_speed + _fase) * float_height
		return

	_velocidad_y += gravity * delta
	var siguiente := global_position.y + _velocidad_y * delta
	if _velocidad_y > 0.0:
		var suelo := _buscar_suelo_hacia(Vector2(global_position.x, siguiente + 6.0))
		if suelo >= 0.0:
			var reposo := suelo - MEDIO_ALTO
			global_position.y = reposo
			if absf(_velocidad_y) < min_bounce_speed:
				_asentar(reposo)
			else:
				_velocidad_y = -_velocidad_y * bounce
			return
	global_position.y = siguiente

func _unhandled_input(event: InputEvent) -> void:
	# Si el jugador está cerca y pulsa la tecla de interacción
	if _player_in_range and event.is_action_pressed(action_prompt):
		_interact_with_item()

func _interact_with_item() -> void:
	if not is_instance_valid(_player_in_range) or item == null:
		return

	# El objeto decide dónde va (barra o pasivas); si no define on_pickup
	# (p. ej. las skills), va al inventario
	if item.has_method("on_pickup"):
		if item.on_pickup(_player_in_range):
			queue_free()
		return
	var inventario := _player_in_range.get_node_or_null("Inventory")
	if inventario and inventario.call("add_item", item):
		queue_free()

## Detecta el suelo al aparecer: si ha nacido dentro o por debajo, se asienta
func _buscar_suelo() -> void:
	var suelo := _buscar_suelo_hacia(global_position + Vector2(0, DISTANCIA_SUELO))
	if suelo < 0.0:
		suelo = _buscar_suelo_hacia(global_position + Vector2(0, -64.0))
	if suelo < 0.0:
		# Sin suelo cerca: se queda flotando donde aparece
		_asentar(global_position.y)
		return
	if global_position.y >= suelo - MEDIO_ALTO:
		_asentar(suelo - MEDIO_ALTO)

## Lanza un rayo contra el mundo hasta `destino`; devuelve la altura del suelo o -1
func _buscar_suelo_hacia(destino: Vector2) -> float:
	var espacio := get_world_2d().direct_space_state
	var consulta := PhysicsRayQueryParameters2D.create(global_position, destino, CAPA_MUNDO)
	var golpe := espacio.intersect_ray(consulta)
	if golpe.is_empty():
		return -1.0
	return golpe["position"].y

## Detiene el objeto a la altura indicada y activa el vaivén
func _asentar(y: float) -> void:
	global_position.y = y
	_y_reposo = y
	_velocidad_y = 0.0
	_estado = Estado.FLOTANDO

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		_player_in_range = body as CharacterBody2D

func _on_body_exited(body: Node2D) -> void:
	if body == _player_in_range:
		_player_in_range = null
