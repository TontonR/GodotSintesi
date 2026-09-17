extends Sprite2D

# Velocidad de movimiento en píxeles por segundo
@export var velocity: float = 300.0

func _process(delta: float) -> void:
	# Detectamos la dirección horizontal (-1 izquierda, +1 derecha, 0 quieto)
	var direction = 0.0
	
	if Input.is_key_pressed(KEY_D):
		direction += 1.0
	if Input.is_key_pressed(KEY_A):
		direction -= 1.0
		
	# Aplicamos el movimiento directamente a la posición de este Sprite
	position.x += direction * velocity * delta
