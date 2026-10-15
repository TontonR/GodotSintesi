class_name Inventory
extends Node

## Emitted when the content of any slot changes
signal slots_changed

## Total slots: the first 2 for skills, the last 3 for consumables
const MAX_SLOTS: int = 5
## Number of slots reserved for skills (the first ones)
const SKILL_SLOTS: int = 2

## Stored items: one item per slot (null = empty slot)
var slots: Array[Items] = []

func _init() -> void:
	slots.resize(MAX_SLOTS)

func _ready() -> void:
	# Enlaza la barra de la interfaz (mismo patrón que player.gd con sus barras)
	var player := get_parent()
	if player == null or player.get_parent() == null:
		return
	var bar := player.get_parent().get_node_or_null("UILayer/ConsumableBar")
	if bar:
		bar.call("bind", self)

func _unhandled_input(event: InputEvent) -> void:
	for i in MAX_SLOTS:
		if event.is_action_pressed("use_slot_%d" % (i + 1)):
			use_slot(i, get_parent())
			return

## Stores the item by type: skills → slots 1-2, the rest → 3-5.
## Returns false when no slot of its type is free (the item is not picked up)
func add_item(item: Items) -> bool:
	var inicio := 0
	var fin := MAX_SLOTS
	if item is Skills:
		fin = SKILL_SLOTS
	else:
		inicio = SKILL_SLOTS
	for i in range(inicio, fin):
		if slots[i] == null:
			slots[i] = item
			slots_changed.emit()
			return true
	return false

## Activates the item in the given slot (keys 1-5). Skills stay in
## their slot; consumables are consumed when activated
func use_slot(index: int, target: Node) -> void:
	if index < 0 or index >= MAX_SLOTS or slots[index] == null:
		return
	var item := slots[index]
	if not item is Skills:
		slots[index] = null
		slots_changed.emit()
	item.use(target)

## Content of the given slot (null when empty)
func get_slot(index: int) -> Items:
	if index < 0 or index >= MAX_SLOTS:
		return null
	return slots[index]
