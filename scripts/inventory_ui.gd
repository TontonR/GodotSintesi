class_name InventoryUI
extends HBoxContainer

## Size of each slot in pixels
const SLOT_SIZE := Vector2(18, 18)

## Linked inventory (bound by Inventory itself when entering the tree)
var inventory: Inventory

var _icons: Array[TextureRect] = []

func _init() -> void:
	add_theme_constant_override("separation", 2)
	for i in Inventory.MAX_SLOTS:
		_icons.append(_create_slot(i))
		# Separador visual entre skills (1-2) y consumibles (3-5)
		if i == Inventory.SKILL_SLOTS - 1:
			_add_separator()

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

func _add_separator() -> void:
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(4, 0)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sep)

func _create_slot(index: int) -> TextureRect:
	var panel := Panel.new()
	panel.custom_minimum_size = SLOT_SIZE
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.176, 0.176, 0.176, 0.85)
	# Los huecos de skills se distinguen con un borde azulado
	style.border_color = Color(0.31, 0.51, 0.86) if index < Inventory.SKILL_SLOTS else Color(0, 0, 0, 1)
	style.set_border_width_all(1)
	style.set_corner_radius_all(4)
	panel.add_theme_stylebox_override("panel", style)

	var icon := TextureRect.new()
	icon.name = "Icon"
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(icon)
	icon.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	add_child(panel)
	return icon
