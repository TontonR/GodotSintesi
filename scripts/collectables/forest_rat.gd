class_name ForestRat
extends Area2D
## Summoned forest rat: follows the player, damages enemies on contact and
## destroys enemy projectiles. It cannot be hurt.

@export var damage_per_tick: float = 3.0
@export var tick_seconds: float = 0.5
@export var lifetime: float = 8.0
@export var speed: float = 180.0
@export var block_projectiles: bool = true

var _player: Node2D = null
var _age: float = 0.0
var _tick: float = 0.0
var _side: float = -1.0


func _ready() -> void:
	collision_layer = 0
	collision_mask = 12
	monitoring = true
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 6.0
	shape.shape = circle
	add_child(shape)
	area_entered.connect(_on_area_entered)


func setup(player: Node, damage: float, tick: float, life: float, move_speed: float, blocks: bool) -> void:
	_player = player as Node2D
	damage_per_tick = damage
	tick_seconds = tick
	lifetime = life
	speed = move_speed
	block_projectiles = blocks
	if _player:
		_side = -1.0 if _player.global_position.x >= global_position.x else 1.0


func _physics_process(delta: float) -> void:
	if not is_instance_valid(_player):
		queue_free()
		return
	_age += delta
	if _age >= lifetime:
		queue_free()
		return
	_tick = maxf(_tick - delta, 0.0)
	var target := _player.global_position + Vector2(18.0 * _side, 10.0)
	global_position = global_position.move_toward(target, speed * delta)
	if _tick > 0.0:
		return
	_tick = tick_seconds
	for body in get_overlapping_bodies():
		if body == _player or body.is_in_group("player"):
			continue
		if body.has_method("take_damage"):
			body.call("take_damage", damage_per_tick)
	queue_redraw()


func _on_area_entered(area: Area2D) -> void:
	if not block_projectiles or area == null:
		return
	if area.has_method("take_damage"):
		area.call("take_damage", 0)


func _draw() -> void:
	# Small brown rat: body, ears, eye and tail.
	draw_circle(Vector2(0.0, 1.0), 5.0, Color(0.36, 0.24, 0.16, 1.0))
	draw_circle(Vector2(-4.0, -3.0), 2.0, Color(0.42, 0.28, 0.18, 1.0))
	draw_circle(Vector2(2.0, -3.0), 2.0, Color(0.42, 0.28, 0.18, 1.0))
	draw_circle(Vector2(3.0, 0.0), 1.0, Color(0.9, 0.85, 0.7, 1.0))
	draw_line(Vector2(-5.0, 2.0), Vector2(-10.0, 5.0), Color(0.55, 0.38, 0.24, 1.0), 1.0)
