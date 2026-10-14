class_name PassiveUI
extends VBoxContainer

## Tamaño de cada icono en píxeles
const ICON_SIZE := Vector2(12, 12)

## Lista de pasivas enlazada (lo llama PlayerPassives al entrar en escena)
var source: PlayerPassives

func _init() -> void:
	add_theme_constant_override("separation", 2)

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
	for passive in source.active_passives:
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
