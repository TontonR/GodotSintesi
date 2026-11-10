class_name PoisonCloud
extends Area2D
## Poison cloud of the cutaneous tubers: it stays still, damaging the
## enemies inside every `tick_seconds` and then fades away.

## Cloud radius in pixels.
@export var radius: float = 44.0
## Damage per tick to each enemy inside.
@export var damage_per_tick: float = 2.0
## Seconds between two damage ticks.
@export var tick_seconds: float = 0.5
## Seconds the cloud lasts.
@export var lifetime: float = 4.0

var _age: float = 0.0
var _tick: float = 0.0


func _ready() -> void:
	collision_layer = 0
	# Enemies live on layer 4 in the current scenes.
	collision_mask = 4
	monitoring = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = radius
	shape.shape = circle
	add_child(shape)


func _physics_process(delta: float) -> void:
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	modulate.a = clampf(1.0 - _age / lifetime, 0.0, 1.0)
	_tick -= delta
	if _tick > 0.0:
		return
	_tick = tick_seconds
	for body in get_overlapping_bodies():
		if body.is_in_group("player"):
			continue
		if body.has_method("take_damage"):
			body.call("take_damage", damage_per_tick)


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, Color(0.32, 0.62, 0.16, 0.28))
	draw_circle(Vector2.ZERO, radius * 0.6, Color(0.42, 0.75, 0.2, 0.22))
