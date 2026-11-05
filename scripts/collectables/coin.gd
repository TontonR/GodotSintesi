extends Area2D

## Se emite al recogerla; el generador del mundo lo usa para no reaparecerla.
signal collected

# Capa 2D del mundo (suelo y plataformas).
const WORLD_LAYER: int = 1
## Distancia máxima (px) que se busca el suelo al aparecer.
const GROUND_SEARCH_DISTANCE: float = 1024.0
## Intentos de búsqueda antes de rendirse (el TileMap puede tardar un frame en
## registrar la colisión del chunk recién pintado).
const GROUND_SEARCH_TRIES: int = 30

# Valor que suma esta moneda al contador del jugador
@export var coin_value: int = 1

@export_group("Física")
## Aceleración de caída (px/s²).
@export var fall_gravity: float = 900.0
## Rebote al tocar el suelo (0 = sin rebote).
@export var bounce: float = 0.4
## Velocidad mínima de impacto (px/s) para rebotar; por debajo se asienta.
@export var min_bounce_speed: float = 40.0
## Altura del vaivén una vez apoyada (px).
@export var float_height: float = 1.0
## Velocidad del vaivén (rad/s).
@export var float_speed: float = 2.5

var _velocity_y: float = 0.0
var _ground_y: float = -1.0
var _ground_tries: int = 0
var _rest_y: float = 0.0
var _settled: bool = false
var _phase: float = 0.0
var _time: float = 0.0

@onready var _shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	# El grupo permite al generador de zonas localizarlas para borrarlas al descargar
	add_to_group("coins")
	body_entered.connect(_on_body_entered)
	_phase = randf() * TAU

func _physics_process(delta: float) -> void:
	if _settled:
		_time += delta
		global_position.y = _rest_y + sin(_time * float_speed + _phase) * float_height
		return

	# El suelo se busca con la posición real ya asignada; si el chunk aún no
	# tiene colisión, se reintenta en los siguientes frames.
	if _ground_y < 0.0:
		_find_ground()
		if _ground_y < 0.0:
			return

	_velocity_y += fall_gravity * delta
	var next_y := global_position.y + _velocity_y * delta
	if _velocity_y > 0.0 and next_y >= _ground_y - _half_height():
		global_position.y = _ground_y - _half_height()
		if absf(_velocity_y) < min_bounce_speed:
			_settle(_ground_y - _half_height())
		else:
			_velocity_y = -_velocity_y * bounce
		return
	global_position.y = next_y

func _on_body_entered(body: Node2D) -> void:
	# El cuerpo detectado puede ser el jugador o un nodo hijo suyo
	var target: Node = body if body.has_method("add_coin") else body.get_parent()
	if target == null or not target.has_method("add_coin"):
		return
	target.add_coin(coin_value)
	var fx := get_tree().get_first_node_in_group("fx")
	if fx:
		fx.call("coin_pickup", global_position)
	collected.emit()
	queue_free()

## Media altura real del sprite (escala del nodo incluida): la base queda en el suelo.
func _half_height() -> float:
	if _shape and _shape.shape is RectangleShape2D:
		var rect := _shape.shape as RectangleShape2D
		return rect.size.y * 0.5 * _shape.scale.y * scale.y
	return 7.0

## Busca el suelo por debajo; tras varios intentos fallidos se queda flotando.
func _find_ground() -> void:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(
		global_position,
		global_position + Vector2(0.0, GROUND_SEARCH_DISTANCE),
		WORLD_LAYER
	)
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		_ground_tries += 1
		if _ground_tries >= GROUND_SEARCH_TRIES:
			_settle(global_position.y)
		return
	_ground_y = hit["position"].y
	if global_position.y >= _ground_y - _half_height():
		_settle(_ground_y - _half_height())

func _settle(y: float) -> void:
	global_position.y = y
	_rest_y = y
	_velocity_y = 0.0
	_settled = true
