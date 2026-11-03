class_name archer_projectile
extends Area2D
## Flecha del arquero: se mueve en línea recta y daña al jugador al impactar.
## La textura es un placeholder de All_Fire_Bullet (región con forma de flecha).

@export var speed: float = 240.0
@export var damage: int = 8
## Tiempo máximo de vida antes de desaparecer (s).
@export var lifetime: float = 4.0

var direction: Vector2 = Vector2.RIGHT

var _shooter: Node2D = null
var _spent: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


## Llamado por EnemyBase justo después de instanciar el proyectil.
func setup(dir: Vector2, projectile_speed: float, projectile_damage: float, shooter: Node2D) -> void:
	direction = dir.normalized()
	speed = projectile_speed
	damage = roundi(projectile_damage)
	_shooter = shooter
	# La textura original apunta a la izquierda: se compensa con PI.
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


## Permite que los proyectiles del jugador destruyan la flecha.
func take_damage(_amount: float) -> void:
	if _spent:
		return
	_spent = true
	queue_free()


func _on_lifetime_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
