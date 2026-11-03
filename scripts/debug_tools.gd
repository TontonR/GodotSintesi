class_name DebugTools
extends Node

# ==============================================================================
# HERRAMIENTAS DE PRUEBA (temporal)
# ==============================================================================
# Numpad: 7/8/9 cambian la velocidad del juego (x1/x5/x20) y 4/6 hacen un viaje
# rápido a izquierda/derecha + algo hacia arriba, para no quedarse encerrado
# dentro de una montaña al probar. Los ítems de prueba (KP0-KP3) siguen en
# `scenes/inventory/inventory.gd`, que es del inventario.

const TILE_SIZE := 16
## Factores de `Engine.time_scale` para KP7, KP8 y KP9.
const SPEEDS: Array[float] = [1.0, 5.0, 20.0]
const SPEED_LABELS: Array[String] = ["x1", "x5", "x20"]
const HINT := "velocidad %s · KP7/KP8/KP9 x1/x5/x20 · KP4/KP6 viaje rápido"

## Velocidad del juego al arrancar (también se cambia en caliente con el numpad).
@export_enum("x1", "x5", "x20") var game_speed: int = 0
## Tiles que avanza el viaje rápido de KP4/KP6.
@export var teleport_distance_tiles: int = 64
## Tiles que sube el viaje rápido: deja al jugador por encima del terreno.
@export var teleport_lift_tiles: int = 10

var _label: Label


func _ready() -> void:
	_apply_speed(game_speed)
	_build_label()


func _exit_tree() -> void:
	# Nunca dejar el juego acelerado al salir de la escena.
	Engine.time_scale = 1.0


func _unhandled_input(event: InputEvent) -> void:
	var key_event := event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	var key := key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
	match key:
		KEY_KP_4:
			_teleport(-1.0)
		KEY_KP_6:
			_teleport(1.0)
		KEY_KP_7:
			_apply_speed(0)
		KEY_KP_8:
			_apply_speed(1)
		KEY_KP_9:
			_apply_speed(2)
		_:
			return
	get_viewport().set_input_as_handled()


## Aplica el factor de velocidad `index` (0 = x1, 1 = x5, 2 = x20).
func _apply_speed(index: int) -> void:
	game_speed = clampi(index, 0, SPEEDS.size() - 1)
	Engine.time_scale = SPEEDS[game_speed]
	_update_label()


## Salto seco del jugador: `direction` -1 va a la izquierda y 1 a la derecha.
func _teleport(direction: float) -> void:
	var player := get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		player = get_parent().get_node_or_null("player") as Node2D
	if player == null:
		return
	var offset := Vector2(
		direction * teleport_distance_tiles * TILE_SIZE,
		-teleport_lift_tiles * TILE_SIZE
	)
	if player.has_method("debug_teleport"):
		player.call("debug_teleport", offset)
	else:
		player.global_position += offset


func _build_label() -> void:
	var ui_layer := get_parent().get_node_or_null("UILayer") as CanvasLayer
	if ui_layer == null:
		return
	_label = Label.new()
	_label.name = "DebugHint"
	_label.anchor_top = 1.0
	_label.anchor_bottom = 1.0
	_label.offset_left = 8.0
	_label.offset_top = -22.0
	_label.offset_right = 520.0
	_label.offset_bottom = -6.0
	_label.add_theme_font_size_override("font_size", 11)
	_label.add_theme_color_override("font_color", Color(1, 1, 1, 0.75))
	_label.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 0.9))
	ui_layer.add_child(_label)
	_update_label()


func _update_label() -> void:
	if _label:
		_label.text = HINT % SPEED_LABELS[game_speed]
