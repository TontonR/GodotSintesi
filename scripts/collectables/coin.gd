extends Area2D

# Valor que suma esta moneda al contador del jugador
@export var coin_value: int = 1

func _ready() -> void:
	# El grupo permite al generador de zonas localizarlas para borrarlas al descargar
	add_to_group("coins")
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# El cuerpo detectado puede ser el jugador o un nodo hijo suyo
	var target: Node = body if body.has_method("add_coin") else body.get_parent()
	if target == null or not target.has_method("add_coin"):
		return
	target.add_coin(coin_value)
	queue_free()