class_name InventoryScreen
extends CanvasLayer

## Size of each slot button in pixels
const SLOT_SIZE := Vector2(20, 20)

## Flat list of selectable entries: [{ item, button }]
var _entries: Array[Dictionary] = []
## Index of the highlighted entry (-1 = none)
var _selected: int = -1
var _signals_bound: bool = false

var _style_normal: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_selected: StyleBoxFlat

@onready var _portrait_box: Control = $Window/Layout/LeftColumn/PortraitBox
@onready var _portrait: AnimatedSprite2D = $Window/Layout/LeftColumn/PortraitBox/Portrait
@onready var _skills_flow: FlowContainer = $Window/Layout/LeftColumn/SkillsFlow
@onready var _consumables_flow: FlowContainer = $Window/Layout/LeftColumn/ConsumablesFlow
@onready var _collectibles_flow: FlowContainer = $Window/Layout/LeftColumn/CollectiblesFlow
@onready var _item_icon: TextureRect = $Window/Layout/RightColumn/ItemIcon
@onready var _item_name: Label = $Window/Layout/RightColumn/ItemName
@onready var _item_stats: Label = $Window/Layout/RightColumn/ItemStats
@onready var _item_description: Label = $Window/Layout/RightColumn/ItemDescription

func _ready() -> void:
	visible = false
	_style_normal = _make_style(Color(0.176, 0.176, 0.176, 0.9), Color(0, 0, 0, 1), 1)
	_style_hover = _make_style(Color(0.24, 0.24, 0.26, 0.95), Color(0.45, 0.45, 0.5, 1), 1)
	_style_selected = _make_style(Color(0.2, 0.26, 0.36, 0.95), Color(0.31, 0.51, 0.86, 1), 2)
	_portrait_box.resized.connect(_layout_portrait)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("inventory"):
		if visible:
			close()
		else:
			open()
		return
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		close()
	elif event.is_action_pressed("ui_right") or event.is_action_pressed("ui_down"):
		_move_selection(1)
	elif event.is_action_pressed("ui_left") or event.is_action_pressed("ui_up"):
		_move_selection(-1)

## Opens the screen and pauses the game
func open() -> void:
	visible = true
	get_tree().paused = true
	_bind_signals()
	_refresh()
	_select(0)
	_update_portrait()

## Closes the screen and resumes the game
func close() -> void:
	visible = false
	get_tree().paused = false

func _exit_tree() -> void:
	# Nunca dejar el árbol pausado si la escena se descarga con la pantalla abierta
	if get_tree() and get_tree().paused:
		get_tree().paused = false

func _bind_signals() -> void:
	if _signals_bound:
		return
	_signals_bound = true
	var inventory := _inventory()
	if inventory:
		inventory.slots_changed.connect(_on_data_changed)
	var passives := _passives()
	if passives:
		passives.passives_changed.connect(_on_data_changed)

func _on_data_changed() -> void:
	if visible:
		_refresh()
		_select(_selected)

func _refresh() -> void:
	_entries.clear()
	_clear_flow(_skills_flow)
	_clear_flow(_consumables_flow)
	_clear_flow(_collectibles_flow)

	var inventory := _inventory()
	if inventory:
		_fill_slots(_skills_flow, inventory, 0, Inventory.SKILL_SLOTS)
		_fill_slots(_consumables_flow, inventory, Inventory.SKILL_SLOTS, Inventory.MAX_SLOTS)

	var passives := _passives()
	if passives:
		for passive in passives.active_passives:
			_add_slot(_collectibles_flow, passive)

## Crea los botones de un tramo del inventario (huecos vacío incluidos)
func _fill_slots(flow: FlowContainer, inventory: Inventory, from: int, to: int) -> void:
	for i in range(from, to):
		_add_slot(flow, inventory.get_slot(i))

## Añade un hueco al flujo; registra la entrada solo si lleva objeto
func _add_slot(flow: FlowContainer, item: Items) -> void:
	var button := Button.new()
	button.custom_minimum_size = SLOT_SIZE
	button.focus_mode = Control.FOCUS_NONE
	button.icon_alignment = HORIZONTAL_ALIGNMENT_CENTER
	button.add_theme_stylebox_override("normal", _style_normal)
	button.add_theme_stylebox_override("hover", _style_hover)
	button.add_theme_stylebox_override("pressed", _style_hover)
	button.add_theme_stylebox_override("disabled", _style_normal)
	if item:
		button.icon = item.icon
		var index := _entries.size()
		_entries.append({"item": item, "button": button})
		button.pressed.connect(_select.bind(index))
	else:
		button.disabled = true
	flow.add_child(button)

func _clear_flow(flow: FlowContainer) -> void:
	for child in flow.get_children():
		flow.remove_child(child)
		child.queue_free()

## Resalta la entrada indicada y muestra su información en el panel derecho
func _select(index: int) -> void:
	if _entries.is_empty():
		_selected = -1
		_clear_detail()
		return
	_selected = wrapi(index, 0, _entries.size())
	for entry in _entries:
		var button: Button = entry.button
		var style := _style_selected if button == _entries[_selected].button else _style_normal
		button.add_theme_stylebox_override("normal", style)
	var item: Items = _entries[_selected].item
	_item_icon.texture = item.icon
	_item_name.text = item.item_name
	_item_stats.text = _stats_text(item)
	_item_description.text = item.description

func _move_selection(step: int) -> void:
	if _entries.is_empty():
		return
	_select(_selected + step)

func _clear_detail() -> void:
	_item_icon.texture = null
	_item_name.text = ""
	_item_stats.text = ""
	_item_description.text = ""

## Línea de estadísticas del objeto (vacía si no expone valores)
func _stats_text(item: Items) -> String:
	var lines := PackedStringArray()
	if item is Consumable:
		var consumable := item as Consumable
		if consumable.heal_amount > 0:
			lines.append("+%d vida" % consumable.heal_amount)
		if consumable.stamina_amount > 0:
			lines.append("+%d stamina" % consumable.stamina_amount)
	elif item is Skills:
		var skill := item as Skills
		if skill.attack_bonus != 0:
			lines.append("Ataque: %+d" % int(skill.attack_bonus))
		if skill.armor_bonus != 0:
			lines.append("Armadura: %+d" % int(skill.armor_bonus))
		if skill.attack_speed_bonus != 0:
			lines.append("Vel. ataque: %+d" % int(skill.attack_speed_bonus))
		if skill.crit_chance_bonus != 0:
			lines.append("Crítico: %+d%%" % int(skill.crit_chance_bonus))
		if skill.crit_dmg_bonus != 0:
			lines.append("Daño crítico: %+d%%" % int(skill.crit_dmg_bonus))
		if skill.cooldown > 0:
			lines.append("Enfriamiento: %s s" % skill.cooldown)
	elif item is PassiveItems:
		# Propiedades de subclases (bonus/reduction/heal_per_tick): acceso dinámico
		if "bonus" in item:
			lines.append("Daño extra por golpe: +%g" % float(item.get("bonus")))
		if "reduction" in item:
			lines.append("Reducción de daño: %d%%" % roundi(float(item.get("reduction")) * 100))
		if "heal_per_tick" in item:
			lines.append("Regenera %d vida / %g s" % [
				int(item.get("heal_per_tick")),
				float(item.get("interval")),
			])
	return "  ·  ".join(lines)

## Copia el retrato del jugador (SpriteFrames + animación) en el panel izquierdo
func _update_portrait() -> void:
	var player := _player()
	if player == null:
		return
	var source := player.get_node_or_null("SpritePivot/AnimatedSprite2D") as AnimatedSprite2D
	if source == null or source.sprite_frames == null:
		return
	_portrait.sprite_frames = source.sprite_frames
	_portrait.scale = source.scale
	var names := _portrait.sprite_frames.get_animation_names()
	if names.is_empty():
		return
	var animation := "idle" if _portrait.sprite_frames.has_animation("idle") else names[0]
	_portrait.play(animation)
	_layout_portrait()

func _layout_portrait() -> void:
	_portrait.position = _portrait_box.size / 2.0

func _make_style(bg: Color, border: Color, width: int) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.set_border_width_all(width)
	style.set_corner_radius_all(4)
	return style

func _player() -> Node:
	return get_parent().get_node_or_null("player")

func _inventory() -> Inventory:
	var player := _player()
	if player == null:
		return null
	return player.get_node_or_null("Inventory") as Inventory

func _passives() -> PlayerPassives:
	var player := _player()
	if player == null:
		return null
	return player.get_node_or_null("PlayerPassives") as PlayerPassives
