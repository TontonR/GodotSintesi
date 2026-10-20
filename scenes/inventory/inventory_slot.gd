class_name InventorySlot
extends Button

@export var style_normal: StyleBox
@export var style_hover: StyleBox
@export var style_selected: StyleBox

func set_item(item: Items) -> void:
	icon = item.icon if item else null
	disabled = item == null

func set_selected(value: bool) -> void:
	var style := style_selected if value else style_normal
	add_theme_stylebox_override("normal", style)
	add_theme_stylebox_override("hover", style if value else style_hover)
	add_theme_stylebox_override("pressed", style if value else style_hover)