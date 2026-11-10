class_name toad_projectile
extends Area2D
## Mutant toad projectile. It moves in a straight line, damages the player on
## impact and can be destroyed by the player's attacks (one hit is enough).
## Animations: inicial -> active (loop) -> disappear (on impact or expiry).

@export var speed: float = 200.0
@export var damage: int = 8
## Maximum lifetime before fading out (s).
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

var _is_dying: bool = false
var _shooter: Node2D = null


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	sprite.animation_finished.connect(_on_animation_finished)
	sprite.play(&"inicial")
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


## Called by the toad right after instantiating it.
func setup(dir: Vector2, projectile_speed: float, projectile_damage: float, shooter: Node2D) -> void:
	direction = dir.normalized()
	speed = projectile_speed
	damage = roundi(projectile_damage)
	_shooter = shooter
	if sprite and not is_zero_approx(direction.x):
		sprite.flip_h = direction.x < 0.0


func _physics_process(delta: float) -> void:
	if _is_dying:
		return
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if _is_dying or not body.is_in_group("player"):
		return

	if body.has_method("take_damage_from"):
		body.take_damage_from(damage, global_position, 0.0, 0.15, 0.0, self)
	elif body.has_method("take_damage"):
		body.take_damage(damage)
	_begin_disappear()


## Interface expected by the player's hitboxes.
func take_damage(_amount: float) -> void:
	_begin_disappear()


func _begin_disappear() -> void:
	if _is_dying:
		return
	_is_dying = true
	set_deferred("monitoring", false)
	if sprite:
		sprite.play(&"disappear")


func _on_animation_finished() -> void:
	if not sprite:
		return
	if sprite.animation == &"inicial":
		sprite.play(&"active")
	elif sprite.animation == &"disappear":
		queue_free()


func _on_lifetime_timeout() -> void:
	_begin_disappear()
