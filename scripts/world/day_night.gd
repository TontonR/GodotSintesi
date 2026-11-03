class_name DayNightCycle
extends Node

# ==============================================================================
# CICLO DÍA / NOCHE
# ==============================================================================
# La noche cambia el color del cielo (fondo del viewport), enciende estrellas,
# oscurece las montañas y echa un velo negro del 10% sobre toda la pantalla.
# No hay CanvasModulate: los sprites, los tiles y el HUD no se oscurecen.

## Duración del día en segundos (5 min).
@export var day_duration: float = 300.0
## Duración de la noche en segundos (3 min).
@export var night_duration: float = 180.0
## Segundos de fundido en cada cambio de fase. 0 = salto seco.
@export var fade_seconds: float = 12.0
## Color del cielo de día (el de `project.godot`: `default_clear_color`).
@export var day_color: Color = Color(0.50980395, 0.7882353, 0.99215686, 1)
## Color del cielo de noche.
@export var night_color: Color = Color(0.043137, 0.062745, 0.164706, 1)
## Noche: estrellas dibujadas en el cielo (0 = sin estrellas).
@export var star_count: int = 110
## Noche: lado de cada estrella en píxeles.
@export var star_size: int = 2
## Noche: color de las estrellas.
@export var star_color: Color = Color(0.92, 0.94, 1, 1)
## Noche: multiplicador de las montañas, para dejarlas bastante más oscuras.
@export var mountain_night_tint: Color = Color(0.33, 0.36, 0.52, 1)
## Noche: nodo de las montañas que se oscurece.
@export var mountains_path: NodePath = ^"../mountains"
## Noche: opacidad del velo negro que cubre la pantalla (0.1 = 10%).
@export_range(0.0, 0.5, 0.01) var night_veil_alpha: float = 0.1

var _elapsed: float = 0.0
## Color aplicado ahora mismo; -1 para forzar el primero en `_ready`.
var _applied: Color = Color(-1.0, -1.0, -1.0, -1.0)
var _stars: StarField
var _veil: ColorRect
var _mountains: CanvasItem


# ==============================================================================
# ESTRELLAS
# ==============================================================================
## Puntos fijos en coordenadas de pantalla (no se mueven con la cámara). Vive en
## su propio `CanvasLayer` por debajo del mundo, así que el parallax lo tapa.
class StarField extends Control:
	var points: Array[Vector2] = []
	var side: int = 2
	var tint: Color = Color(1, 1, 1, 1)


	func _draw() -> void:
		for point in points:
			draw_rect(Rect2(point, Vector2(side, side)), tint)


func _ready() -> void:
	# El ciclo empieza siempre de día.
	_elapsed = 0.0
	_mountains = get_node_or_null(mountains_path) as CanvasItem
	_build_stars()
	_build_veil()
	_apply_state(_night_factor_at(_elapsed))


func _process(delta: float) -> void:
	var cycle := day_duration + night_duration
	if cycle <= 0.0:
		return
	_elapsed = fmod(_elapsed + delta, cycle)
	_apply_state(_night_factor_at(_elapsed))


## 0 = pleno día, 1 = noche cerrada. Usa el mismo fundido que el color para que
## estrellas, montañas y velo aparezcan a la vez que el cielo.
func _night_factor_at(time: float) -> float:
	var cycle := day_duration + night_duration
	var fade := clampf(fade_seconds, 0.0, minf(day_duration, night_duration) * 0.5)
	if time < day_duration:
		# Final del día: se va fundiendo hacia la noche.
		var to_night := day_duration - time
		if fade > 0.0 and to_night < fade:
			return 1.0 - to_night / fade
		return 0.0
	# Final de la noche: se vuelve al día.
	var to_day := cycle - time
	if fade > 0.0 and to_day < fade:
		return to_day / fade
	return 1.0


## True cuando está más cerca de la noche que del día (lo usan las pasivas).
func is_night() -> bool:
	return _night_factor_at(_elapsed) >= 0.5


func _apply_state(night: float) -> void:
	var color := day_color.lerp(night_color, night)
	if color != _applied:
		_applied = color
		# Único sitio del juego donde se toca el fondo: el clear color del viewport.
		RenderingServer.set_default_clear_color(color)
	# No se llama `is_night` para no tapar el método público del mismo nombre.
	var show_night := night > 0.01
	if _stars:
		_stars.visible = show_night
		_stars.modulate.a = night
	if _veil:
		_veil.visible = show_night
		_veil.color.a = night_veil_alpha * night
	if _mountains:
		_mountains.modulate = Color.WHITE.lerp(mountain_night_tint, night)


func _build_stars() -> void:
	var layer := CanvasLayer.new()
	layer.name = "StarsLayer"
	layer.layer = -1  # detrás del mundo (capa 0), como el propio cielo.
	add_child(layer)
	_stars = StarField.new()
	_stars.name = "Stars"
	_stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stars.side = maxi(star_size, 1)
	_stars.tint = star_color
	var bounds := get_viewport().get_visible_rect().size
	_stars.size = bounds
	# Semilla fija: el cielo es el mismo en todas las partidas.
	var rng := RandomNumberGenerator.new()
	rng.seed = 20261103
	for _index in range(maxi(star_count, 0)):
		var x := roundi(rng.randf_range(0.0, maxf(bounds.x - _stars.side, 1.0)))
		var y := roundi(rng.randf_range(0.0, maxf(bounds.y * 0.9, 1.0)))
		_stars.points.append(Vector2(x, y))
	layer.add_child(_stars)


func _build_veil() -> void:
	var layer := CanvasLayer.new()
	layer.name = "NightVeilLayer"
	layer.layer = 11  # encima del HUD (`UILayer` = 10).
	add_child(layer)
	_veil = ColorRect.new()
	_veil.name = "NightVeil"
	_veil.color = Color(0, 0, 0, 0)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.size = get_viewport().get_visible_rect().size
	layer.add_child(_veil)
