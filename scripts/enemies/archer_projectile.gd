class_name archer_projectile
extends Area2D
## Archer's arrow: moves in a straight line and damages the player on impact.
## The texture is a placeholder from All_Fire_Bullet (arrow-shaped region).

@export var speed: float = 240.0
@export var damage: int = 8
## Maximum lifetime before disappearing (s).
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT

var _shooter: Node2D = null
var _spent: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


## Called by EnemyBase right after instantiating the projectile.
func setup(dir: Vector2, projectile_speed: float, projectile_damage: float, shooter: Node2D) -> void:
	direction = dir.normalized()
	speed = projectile_speed
	damage = roundi(projectile_damage)
	_shooter = shooter
	# The original texture points left: compensate with PI.
	rotation = direction.angle() + PI


func _physics_process(delta: float) -> void:
	if _spent:
		return
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if _spent or body == _shooter or not body.is_in_group("player"):
		return

	if body.has_method("take_damage_from"):
		body.take_damage_from(damage, global_position, 0.0, 0.15, 0.0, self)
	elif body.has_method("take_damage"):
		body.take_damage(damage)

	_spent = true
	queue_free()


## Lets the player's projectiles destroy the arrow.
func take_damage(_amount: float) -> void:
	if _spent:
		return
	_spent = true
	queue_free()


func _on_lifetime_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
