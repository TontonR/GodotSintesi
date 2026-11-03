class_name PlayerProjectile
extends Area2D
## Proyectil lanzado por las pasivas del jugador. Avanza en línea recta,
## daña a los enemigos y desaparece al impactar o al chocar con el mundo.

@export var speed: float = 300.0
@export var damage: int = 5
## Tiempo máximo de vida antes de desaparecer (s).
@export var lifetime: float = 1.5
## Si es true atraviesa a todos los enemigos en vez de parar al primero.
@export var piercing: bool = false

## Dirección normalizada de avance.
var direction: Vector2 = Vector2.RIGHT

var _shooter: Node2D = null
var _spent: bool = false
var _hit_bodies: Dictionary = {}


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	get_tree().create_timer(lifetime).timeout.connect(_on_lifetime_timeout)


## Llamado justo después de instanciarlo.
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
	# Solo contra enemigos: el terreno y los pickups no paran el disparo.
	if not body.has_method("take_damage"):
		return
	if _hit_bodies.has(body.get_instance_id()):
		return
	_hit_bodies[body.get_instance_id()] = true
	body.take_damage(damage)
	if piercing:
		return
	_spent = true
	queue_free()


func _on_area_entered(area: Area2D) -> void:
	if _spent or area == _shooter:
		return
	# Solo interactúa con áreas dañables (proyectiles enemigos); monedas y
	# pickups también viven en la capa 8 y no deben bloquear el disparo.
	if not area.has_method("take_damage"):
		return
	area.call("take_damage", damage)
	_spent = true
	queue_free()


func _on_lifetime_timeout() -> void:
	if is_instance_valid(self):
		queue_free()
