class_name InventoryUI
extends HBoxContainer

## Tamaño de cada hueco en píxeles
const SLOT_SIZE := Vector2(24, 24)

## Inventario enlazado (lo llama el propio Inventory al entrar en escena)
var inventory: Inventory

var _icons: Array[TextureRect] = []

func _init() -> void:
	add_theme_constant_override("separation", 4)
	for i in Inventory.MAX_SLOTS:
		_icons.append(_create_slot())

func bind(source: Inventory) -> void:
	if inventory and inventory.slots_changed.is_connected(_refresh):
		inventory.slots_changed.disconnect(_refresh)
	inventory = source
	inventory.slots_changed.connect(_refresh)
	_refresh()

func _refresh() -> void:
	if inventory == null:
		return
	for i in _icons.size():
		var item := inventory.get_slot(i)
		_icons[i].texture = item.icon if item else null

func _create_slot() -> TextureRect:
	var panel := Panel.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.176, 0.176, 0.176, 0.85)
	style.border_color = Color(0, 0, 0, 1)
	style.set_border_width_all(2)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var icon := TextureRect.new()
	icon.name = "Icono"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	add_child(panel)
	return icon
