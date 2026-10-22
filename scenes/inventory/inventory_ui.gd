class_name InventoryUI
extends HBoxContainer

## Size of each slot in pixels
const SLOT_SIZE := Vector2(18, 18)
## Reusable slot scene (same one used by InventoryScreen)
const SLOT_SCENE := preload("res://scenes/inventory/inventory_slot.tscn")

## Linked inventory (bound by Inventory itself when entering the tree)
var inventory: Inventory

var _slots: Array[InventorySlot] = []

func _init() -> void:
	add_theme_constant_override("separation", 2)
	for i in Inventory.MAX_SLOTS:
		var slot: InventorySlot = SLOT_SCENE.instantiate()
		slot.custom_minimum_size = SLOT_SIZE
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(slot)
		_slots.append(slot)
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
	for i in _slots.size():
		_slots[i].set_item(inventory.get_slot(i))

func _add_separator() -> void:
	var sep := Control.new()
	sep.custom_minimum_size = Vector2(4, 0)
	sep.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(sep)

