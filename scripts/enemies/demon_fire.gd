class_name demon_fire
extends Area2D
## Demon's fire jet. It is born at its mouth and falls to the ground with a
## slight forward lean (as in the attack art). It damages the
## player at intervals. If the player blocks it with the shield, it notifies the
## demon so that it is stunned.

## Damage per fire jet tick.
@export var damage_per_tick: int = 5
## Seconds between two hits while the player is inside.
@export var tick_interval: float = 0.5
## Maximum length if no ground is found.
@export var max_length: float = 220.0
## Width of the damage area (px). With the lean, it must cover the player
## standing right under the mouth.
@export var beam_width: float = 48.0
## Forward lean of the jet relative to vertical (degrees).
@export var lean_degrees: float = 12.0
## Duration (s) of the visual growth when lit.
@export var grow_time: float = 0.12
## Length of the visible content of the jet art (texture px).
@export var visual_content_length: float = 129.0

var _demon: Node2D = null
var _lifetime: float = 0.0
var _active: bool = false
var _closing: bool = false
var _player_inside: bool = false
var _player: Node2D = null
var _tick_timer: float = 0.0
## Direction of the jet (downwards and slightly forwards).
var _direction: Vector2 = Vector2.DOWN

@onready var beam: Node2D = $beam
@onready var sprite: AnimatedSprite2D = $beam/sprite
@onready var ray: RayCast2D = $RayCast2D
@onready var shape_node: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if sprite:
		sprite.animation_finished.connect(_on_animation_finished)


## Called by the demon right after placing it at the mouth.
func setup(demon: Node2D, duration: float, facing_left: bool) -> void:
	_demon = demon
	_lifetime = duration
	_direction = _get_direction(facing_left)
	_configure_beam()
	_active = true
	_start_grow()
	if sprite:
		sprite.play(&"start")


func _physics_process(delta: float) -> void:
	if not _active:
		return

	_lifetime -= delta
	if _lifetime <= 0.0:
		stop_breath()
		return

	if not _player_inside or not is_instance_valid(_player):
		return

	_tick_timer -= delta
	if _tick_timer <= 0.0:
		_tick_timer = tick_interval
		_damage_player()


## Turns the jet off with its final animation and removes it.
func stop_breath() -> void:
	if _closing:
		return
	_closing = true
	_active = false
	_player_inside = false
	set_deferred("monitoring", false)
	if sprite:
		sprite.play(&"end")
		await get_tree().create_timer(0.18).timeout
	queue_free()


# ---------------------------------------------------------------------------
# Jet geometry
# ---------------------------------------------------------------------------

## Vertical slightly leaned forward (the direction it faces).
func _get_direction(facing_left: bool) -> Vector2:
	var lean := deg_to_rad(lean_degrees)
	var sign_x := -1.0 if facing_left else 1.0
	return Vector2(sign_x * sin(lean), cos(lean)).normalized()


## Orients the ray, scales the art and adjusts the damage area to the ground.
func _configure_beam() -> void:
	if ray:
		ray.rotation = _direction.angle()
		ray.target_position = Vector2(max_length, 0.0)
		ray.force_raycast_update()

	var length := _get_beam_length()
	if beam:
		# The art grows toward its -x, so the node faces the opposite way.
		beam.rotation = _direction.angle() + PI
		beam.scale = Vector2(length / maxf(visual_content_length, 1.0), beam.scale.y)

	if shape_node:
		var rect := RectangleShape2D.new()
		rect.size = Vector2(beam_width, length)
		shape_node.shape = rect
		# The rectangle is width × height: it is rotated so its height follows the jet.
		shape_node.rotation = _direction.angle() - PI * 0.5
		shape_node.position = _direction * (length * 0.5)


## Distance to the ground (or to max_length if none is found).
func _get_beam_length() -> float:
	if ray and ray.is_colliding():
		var distance := global_position.distance_to(ray.get_collision_point()) - 2.0
		return clampf(distance, 24.0, max_length)
	return minf(150.0, max_length)


## The art comes out of the mouth point growing fast, instead of appearing whole.
func _start_grow() -> void:
	if not beam:
		return
	var target := beam.scale.x
	beam.scale.x = target * 0.1
	var tween := create_tween()
	tween.tween_property(beam, "scale:x", target, grow_time)


# ---------------------------------------------------------------------------
# Damage and blocking
# ---------------------------------------------------------------------------

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	_player = body
	_player_inside = true
	_tick_timer = tick_interval


func _on_body_exited(body: Node2D) -> void:
	if body == _player:
		_player_inside = false


func _damage_player() -> void:
	if not is_instance_valid(_player) or not overlaps_body(_player):
		return

	var origin := global_position
	if is_instance_valid(_demon):
		origin = _demon.global_position

	# Frontal block with the shield: the demon is stunned.
	if _player.has_method("is_guarding") and _player.is_guarding():
		if not _player.has_method("is_attack_from_front") or _player.is_attack_from_front(origin):
			_parried()
			return

	if _player.has_method("take_damage_from"):
		_player.take_damage_from(damage_per_tick, origin, 0.0, 0.15, 0.0, self)
	elif _player.has_method("take_damage"):
		_player.take_damage(damage_per_tick)


func _parried() -> void:
	_active = false
	_player_inside = false
	if is_instance_valid(_demon) and _demon.has_method("on_fire_parried"):
		_demon.on_fire_parried()
	else:
		stop_breath()


func _on_animation_finished() -> void:
	if sprite and sprite.animation == &"start":
		sprite.play(&"loop")
