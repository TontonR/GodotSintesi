class_name FallIntro
extends Node

# ==============================================================================
# CAÍDA INICIAL (PANTALLA DE CARGA SIMULADA)
# ==============================================================================
# Al entrar en la partida el jugador aparece por encima del mundo y cae hasta el
# suelo generado, con el control desactivado. La cámara es hija del jugador y le
# sigue desde el primer frame: no se aparca ni se engancha a mitad de caída, así
# que no hay tirones. Mientras el chunk bajo el jugador no exista, la caída no
# termina: el propio intro hace de pantalla de carga. Sin fundidos.

@export_group("Caída")
## Altura sobre el punto de aparición desde la que empieza a caer (px).
@export var fall_height_px: float = 520.0
## Velocidad de caída (px/s). A 300 px/s el intro dura ~1,7 s.
@export var fall_speed: float = 300.0
## Tope de seguridad (s): al llegar se aterriza igual y se devuelve el control.
@export var max_seconds: float = 6.0

var _player: CharacterBody2D
var _world: Node
var _ui_layer: CanvasLayer
## Y del punto de aparición normal del jugador (donde estará el suelo).
var _target_y: float = 0.0
var _elapsed: float = 0.0
var _finished: bool = false


func _ready() -> void:
	_player = get_parent().get_node_or_null("player") as CharacterBody2D
	if _player == null:
		_finished = true
		return
	_world = get_parent().get_node_or_null("map")
	_ui_layer = get_parent().get_node_or_null("UILayer") as CanvasLayer

	# El generador ya ha colocado al jugador sobre el spawn: esa Y es el suelo.
	_target_y = _player.global_position.y
	_player.global_position = Vector2(_player.global_position.x, _target_y - fall_height_px)
	_player.velocity = Vector2.ZERO
	_player.set("control_enabled", false)
	# La cámara sigue desde el primer frame: como es hija del jugador, cualquier
	# "parqueo" se mueve con él y al enganchar daba un salto de media pantalla.
	_player.set("camera_follow_enabled", true)
	_player.set("fall_speed_cap", fall_speed)
	if _ui_layer:
		_ui_layer.visible = false


func _physics_process(delta: float) -> void:
	if _finished or not is_instance_valid(_player):
		return
	# Sin mundo debajo todavía no se puede aterrizar: la caída sigue (carga).
	if not _chunk_ready():
		_player.global_position.y = minf(_player.global_position.y, _target_y - 240.0)
		_player.velocity.y = 0.0
		return
	_elapsed += delta
	if _player.is_on_floor() or _elapsed >= max_seconds:
		_finish()


func _chunk_ready() -> bool:
	if _world == null or not _world.has_method("is_ready_at"):
		return true
	return bool(_world.call("is_ready_at", _player.global_position.x))


func _finish() -> void:
	_finished = true
	_player.set("control_enabled", true)
	_player.set("camera_follow_enabled", true)
	_player.set("fall_speed_cap", 0.0)
	if _ui_layer:
		_ui_layer.visible = true
	queue_free()
