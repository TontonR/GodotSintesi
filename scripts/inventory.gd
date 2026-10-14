class_name Inventory
extends Node

## Se emite cuando cambia el contenido de algún hueco
signal slots_changed

## Huecos de la barra de consumibles (sin apilamiento)
const MAX_SLOTS: int = 3

## Objetos guardados: un objeto por hueco (null = hueco vacío)
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

## Añade el objeto al primer hueco libre. Devuelve false si la barra está llena
func add_item(item: Items) -> bool:
	for i in MAX_SLOTS:
		if slots[i] == null:
			slots[i] = item
			slots_changed.emit()
			return true
	return false

## Consume el objeto del hueco indicado aplicándolo sobre el objetivo
func use_slot(index: int, target: Node) -> void:
	if index < 0 or index >= MAX_SLOTS or slots[index] == null:
		return
	var item := slots[index]
	slots[index] = null
	slots_changed.emit()
	item.use(target)

## Contenido del hueco indicado (null si está vacío)
func get_slot(index: int) -> Items:
	if index < 0 or index >= MAX_SLOTS:
		return null
	return slots[index]
