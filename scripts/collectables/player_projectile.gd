class_name PlayerProjectile
extends Area2D
## Projectile launched by the player passives. It moves in a straight line,
## damages enemies and disappears on impact or when it hits the world.

@export var speed: float = 300.0
@export var damage: int = 5
## Maximum lifetime before disappearing (s).
@export var lifetime: float = 1.5
## When true it goes through every enemy instead of stopping at the first one.
@export var piercing: bool = false
## Horizontal push applied to the enemy on hit (0 = none).
@export var knockback_force: float = 0.0
## Chance per hit to apply the push (0.25 = 25%).
@export_range(0.0, 1.0, 0.05) var knockback_chance: float = 0.0

## Normalized travel direction.
var direction: Vector2 = Vector2.RIGHT

var _shooter: Node2D = null
var _spent: bool = false
var _hit_bodies: Dictionary = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


## Called right after instantiating it.
func setup(dir: Vector2, projectile_speed: float, projectile_damage: float, shooter: Node2D) -> void:
	direction = dir.normalized()
	speed = projectile_speed
	damage = roundi(projectile_damage)
	_shooter = shooter
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	if _spent:
		return
	global_position += direction * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if _spent or body == _shooter or body.is_in_group("player"):
		return
	# Enemies only: terrain and pickups do not stop the shot.
	if not body.has_method("take_damage"):
		return
	if _hit_bodies.has(body.get_instance_id()):
		return
	_hit_bodies[body.get_instance_id()] = true
	var final_damage := damage
	if _shooter != null and _shooter.has_method("modify_projectile_damage"):
		final_damage = roundi(float(_shooter.call("modify_projectile_damage", body, float(damage))))
	if knockback_force > 0.0 and randf() < knockback_chance and body.has_method("take_damage_from"):
		body.call("take_damage_from", final_damage, global_position, knockback_force, 0.0, 0.0, _shooter)
	else:
		body.take_damage(final_damage)
	if piercing:
		return
	_spent = true
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _spent or area == _shooter:
		return
	# Only interacts with damageable areas (enemy projectiles); coins and
	# pickups also live on layer 8 and must not block the shot.
	if not area.has_method("take_damage"):
		return
	area.call("take_damage", damage)
	_spent = true
	queue_free()


func _on_lifetime_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
