extends Node2D
# Dibuja en pantalla la hitbox activa durante el ataque (para ajustar en pruebas)

@export var fill_color: Color = Color(1.0, 0.15, 0.15, 0.35)
@export var outline_color: Color = Color(1.0, 0.4, 0.4, 0.95)
@export var outline_width: float = 1.0

var _rect: Rect2 = Rect2()

func set_rect(rect: Rect2) -> void:
	if _rect == rect:
		return
	_rect = rect
	queue_redraw()

func clear() -> void:
	set_rect(Rect2())

func get_rect() -> Rect2:
	return _rect

func _draw() -> void:
	if _rect.size.x <= 0.0 or _rect.size.y <= 0.0:
		return
	draw_rect(_rect, fill_color, true)
	draw_rect(_rect, outline_color, false, outline_width)
