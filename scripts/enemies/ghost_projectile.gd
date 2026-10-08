extends Node2D

@export var speed: float = 300.0
@export var damage: int = 5

var direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $AnimatedSprite2D/hitbox if has_node("AnimatedSprite2D/hitbox") else find_child("hitbox", true, false)

func _ready() -> void:
	# Activar la animación en cuanto aparece el proyectil
	if animated_sprite:
		animated_sprite.play("default")
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		print("¡Hitbox del proyectil conectada correctamente!")
	else:
		print("ERROR: No se encontró la Area2D 'hitbox'.")

	get_tree().create_timer(5.0).timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("ghost") or body.name.begins_with("ghost"):
		return

	print("Proyectil impactó con: ", body.name)

	if body.is_in_group("player") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("¡Daño realizado al jugador!")
		queue_free()
	else:
		queue_free()
