extends Node2D

@export var speed: float = 250.0
@export var damage: int = 5

var direction: Vector2 = Vector2.RIGHT

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $AnimatedSprite2D/hitbox if has_node("AnimatedSprite2D/hitbox") else find_child("hitbox", true, false)

func _ready() -> void:
	# Enable the animation as soon as the projectile appears
	if animated_sprite:
		animated_sprite.play("default")
	
	if hitbox:
		hitbox.body_entered.connect(_on_hitbox_body_entered)
		print("Projectile hitbox connected successfully!")
	else:
		print("ERROR: Area2D 'hitbox' was not found.")

	get_tree().create_timer(5.0).timeout.connect(func():
		if is_instance_valid(self):
			queue_free()
	)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("ghost") or body.name.begins_with("ghost"):
		return

	print("Projectile hit: ", body.name)

	if body.is_in_group("player") or body.has_method("take_damage"):
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("Damage dealt to the player!")
		queue_free()
	else:
		queue_free()
