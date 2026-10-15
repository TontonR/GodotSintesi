class_name PassiveUI
extends GridContainer

## Number of columns in the passive grid
const COLUMNS: int = 6
## Size of each icon in pixels
const ICON_SIZE := Vector2(12, 12)

## Linked passive list (bound by PlayerPassives when entering the tree)
var source: PlayerPassives

func _init() -> void:
	columns = COLUMNS
	add_theme_constant_override("h_separation", 2)
	add_theme_constant_override("v_separation", 2)

func bind(passives: PlayerPassives) -> void:
	if source and source.passives_changed.is_connected(_refresh):
		source.passives_changed.disconnect(_refresh)
	source = passives
	source.passives_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	if source == null:
		return
	# Más recientes primero (arriba a la izquierda); las filas crecen hacia abajo
	for i in range(source.active_passives.size() - 1, -1, -1):
		var passive := source.active_passives[i]
		if passive == null or passive.icon == null:
			continue
		var icon := TextureRect.new()
		icon.custom_minimum_size = ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = passive.icon
		icon.modulate = Color(1, 1, 1, 0.55)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
