class_name DayNightCycle
extends Node

# ==============================================================================
# DAY / NIGHT CYCLE
# ==============================================================================
# Night changes the sky color (viewport background), turns on stars,
# darkens the mountains and lays a 10% black veil over the whole screen.
# There is no CanvasModulate: sprites, tiles and the HUD are not darkened.

## Day duration in seconds (5 min).
@export var day_duration: float = 300.0
## Night duration in seconds (3 min).
@export var night_duration: float = 180.0
## Fade seconds on each phase change. 0 = hard cut.
@export var fade_seconds: float = 12.0
## Day sky color (the one in `project.godot`: `default_clear_color`).
@export var day_color: Color = Color(0.50980395, 0.7882353, 0.99215686, 1)
## Night sky color.
@export var night_color: Color = Color(0.043137, 0.062745, 0.164706, 1)
## Night: stars drawn in the sky (0 = no stars).
@export var star_count: int = 110
## Night: side of each star in pixels.
@export var star_size: int = 2
## Night: star color.
@export var star_color: Color = Color(0.92, 0.94, 1, 1)
## Night: mountain multiplier, to leave them quite a bit darker.
@export var mountain_night_tint: Color = Color(0.33, 0.36, 0.52, 1)
## Night: mountains node that gets darkened.
@export var mountains_path: NodePath = ^"../mountains"
## Night: opacity of the black veil covering the screen (0.1 = 10%).
@export_range(0.0, 0.5, 0.01) var night_veil_alpha: float = 0.1

var _elapsed: float = 0.0
## Color applied right now; -1 to force the first one in `_ready`.
var _applied: Color = Color(-1.0, -1.0, -1.0, -1.0)
var _stars: StarField
var _veil: ColorRect
var _mountains: CanvasItem


# ==============================================================================
# STARS
# ==============================================================================
## Fixed points in screen coordinates (they do not move with the camera). It lives in
## its own `CanvasLayer` below the world, so the parallax covers it.
class StarField extends Control:
	var points: Array[Vector2] = []
	var side: int = 2
	var tint: Color = Color(1, 1, 1, 1)


	func _draw() -> void:
		for point in points:
			draw_rect(Rect2(point, Vector2(side, side)), tint)


func _ready() -> void:
	# The cycle always starts in daytime.
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


## 0 = full day, 1 = deep night. Uses the same fade as the color so that
## stars, mountains and veil appear at the same time as the sky.
func _night_factor_at(time: float) -> float:
	var cycle := day_duration + night_duration
	var fade := clampf(fade_seconds, 0.0, minf(day_duration, night_duration) * 0.5)
	if time < day_duration:
		# End of the day: fading towards night.
		var to_night := day_duration - time
		if fade > 0.0 and to_night < fade:
			return 1.0 - to_night / fade
		return 0.0
	# End of the night: back to daytime.
	var to_day := cycle - time
	if fade > 0.0 and to_day < fade:
		return to_day / fade
	return 1.0


## True when it is closer to night than to day (used by the passives).
func is_night() -> bool:
	return _night_factor_at(_elapsed) >= 0.5


func _apply_state(night: float) -> void:
	var color := day_color.lerp(night_color, night)
	if color != _applied:
		_applied = color
		# The only place in the game that touches the background: the viewport clear color.
		RenderingServer.set_default_clear_color(color)
	# `is_night` is not called here to avoid shadowing the public method of the same name.
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
	layer.layer = -1  # behind the world (layer 0), like the sky itself.
	add_child(layer)
	_stars = StarField.new()
	_stars.name = "Stars"
	_stars.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stars.side = maxi(star_size, 1)
	_stars.tint = star_color
	var bounds := get_viewport().get_visible_rect().size
	_stars.size = bounds
	# Fixed seed: the sky is the same in every run.
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
	layer.layer = 11  # above the HUD (`UILayer` = 10).
	add_child(layer)
	_veil = ColorRect.new()
	_veil.name = "NightVeil"
	_veil.color = Color(0, 0, 0, 0)
	_veil.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_veil.size = get_viewport().get_visible_rect().size
	layer.add_child(_veil)
