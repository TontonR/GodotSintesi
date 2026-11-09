class_name Inventory
extends Node

## Emitted when the content of any slot changes
signal slots_changed

## Total slots: all 3 for consumables (keys 1-3)
const MAX_SLOTS: int = 3

# DEBUG temporal: teclas del numpad para generar objetos (0 limpia, 1 consumible,
# 2 pasiva). Borrar este bloque y `_handle_debug_key` cuando ya no haga falta.
const DEBUG_TOOLS: bool = true
const _DEBUG_CONSUMABLES: Array[String] = [
	"res://resources/pocion_mocos.tres",
	"res://resources/pocion_cura.tres",
	"res://resources/pocion_stamina.tres",
	"res://resources/pocion_mayor.tres",
	"res://resources/pocion_cura_menor.tres",
	"res://resources/pocion_stamina_mayor.tres",
	"res://resources/bebida_tonificante.tres",
	"res://resources/elixir_vida.tres",
	"res://resources/esencia_vital.tres",
]
const _DEBUG_PASSIVES: Array[String] = [
	"res://resources/tapoarrabos.tres",
	"res://resources/maza.tres",
	"res://resources/una_ogro.tres",
	"res://resources/colgante_hierro.tres",
	"res://resources/piedra_oro.tres",
	"res://resources/piel_lobo.tres",
	"res://resources/colmillo_lobo.tres",
	"res://resources/garras_lobo.tres",
	"res://resources/adn_hombre_lobo.tres",
	"res://resources/saliva_rana.tres",
	"res://resources/lengua_rana.tres",
	"res://resources/burbuja_rana.tres",
	"res://resources/tuberculos_cutaneos.tres",
	"res://resources/moco.tres",
	"res://resources/pocion_mocos.tres",
	"res://resources/moco_compacto.tres",
	"res://resources/corazon_mucosil.tres",
	"res://resources/cazador.tres",
	"res://resources/codicia.tres",
	"res://resources/corazon_hierro.tres",
	"res://resources/espinas.tres",
	"res://resources/guantelete.tres",
	"res://resources/ira_guardian.tres",
	"res://resources/pies_ligeros.tres",
	"res://resources/proyectil_tercer_golpe.tres",
	"res://resources/rafaga.tres",
	"res://resources/segundo_aliento.tres",
	"res://resources/vampirismo.tres",
	"res://resources/amuleto_ataque.tres",
	"res://resources/armadura_ligera.tres",
	"res://resources/talisman_regen.tres",
	"res://resources/amuleto_furia.tres",
	"res://resources/amuleto_critico.tres",
	"res://resources/armadura_pesada.tres",
	"res://resources/anillo_vigor.tres",
	"res://resources/pulso_vampirico.tres",
]

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
	if DEBUG_TOOLS and _handle_debug_key(event):
		get_viewport().set_input_as_handled()
		return
	for i in MAX_SLOTS:
		if event.is_action_pressed("use_slot_%d" % (i + 1)):
			use_slot(i, get_parent())
			return

## Debug: numpad 0 clears everything, 1 gives a random consumable, 2 a random passive
func _handle_debug_key(event: InputEvent) -> bool:
	if not event is InputEventKey:
		return false
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return false
	var key := key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode
	match key:
		KEY_KP_0:
			_clear_debug_items()
		KEY_KP_1:
			_give_debug_item(_DEBUG_CONSUMABLES.pick_random())
		KEY_KP_2:
			_give_debug_item(_DEBUG_PASSIVES.pick_random())
		_:
			return false
	return true

## Debug: empties both the inventory and the active passives
func _clear_debug_items() -> void:
	for i in MAX_SLOTS:
		slots[i] = null
	slots_changed.emit()
	var passives := get_parent().get_node_or_null("PlayerPassives") as PlayerPassives
	if passives:
		while not passives.active_passives.is_empty():
			passives.remove_passive(passives.active_passives.back())

## Debug: gives the item directly (inventory for consumables, list for passives)
func _give_debug_item(path: String) -> void:
	var item := load(path) as Items
	if item is PassiveItems:
		var passives := get_parent().get_node_or_null("PlayerPassives") as PlayerPassives
		if passives:
			passives.add_passive(item as PassiveItems)
	else:
		add_item(item)

## Stores the item in the first free slot.
## Returns false when all slots are full (the item is not picked up)
func add_item(item: Items) -> bool:
	for i in MAX_SLOTS:
		if slots[i] == null:
			slots[i] = item
			slots_changed.emit()
			return true
	return false

## Activates the item in the given slot (keys 1-3). Consumables are consumed.
func use_slot(index: int, target: Node) -> void:
	if index < 0 or index >= MAX_SLOTS or slots[index] == null:
		return
	var item := slots[index]
	slots[index] = null
	slots_changed.emit()
	item.use(target)

## Content of the given slot (null when empty)
func get_slot(index: int) -> Items:
	if index < 0 or index >= MAX_SLOTS:
		return null
	return slots[index]
