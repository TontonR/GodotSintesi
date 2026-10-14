class_name Inventory
extends Node

## Se emite cuando cambia el contenido de algún hueco
signal slots_changed

## Huecos totales: los 2 primeros para skills, los 3 últimos para consumibles
const MAX_SLOTS: int = 5
## Cantidad de huecos reservados a skills (los primeros)
const SKILL_SLOTS: int = 2

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

## Añade el objeto según su tipo: skills → huecos 1-2, el resto → 3-5.
## Devuelve false si no queda hueco de su tipo (el objeto no se recoge)
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

## Activa el objeto del hueco indicado (teclas 1-5). Las skills permanecen
## en su hueco; los consumibles se gastan al activarse
func use_slot(index: int, target: Node) -> void:
	if index < 0 or index >= MAX_SLOTS or slots[index] == null:
		return
	var item := slots[index]
	if not item is Skills:
		slots[index] = null
		slots_changed.emit()
	item.use(target)

## Contenido del hueco indicado (null si está vacío)
func get_slot(index: int) -> Items:
	if index < 0 or index >= MAX_SLOTS:
		return null
	return slots[index]
