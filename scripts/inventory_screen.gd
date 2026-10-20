class_name InventoryScreen
extends CanvasLayer

## Size of each slot button in pixels (skills and consumables)
const SLOT_SIZE := Vector2(20, 20)
## Size of each collectible button (6 columns must fit the middle column)
const COLLECTIBLE_SLOT_SIZE := Vector2(16, 16)
## Rows of collectibles shown per page
const COLLECTIBLE_ROWS: int = 6

## Flat list of selectable entries: [{ item, button }]
var _entries: Array[Dictionary] = []
## Index of the highlighted entry (-1 = none)
var _selected: int = -1
var _signals_bound: bool = false
## Index where the consumables entries begin (0.._consumable_start-1 are skills)
var _consumable_start: int = 0
## Index where the collectibles entries begin
var _collect_start: int = 0
## Active column: 0 = skills/consumables, 1 = collectibles (preview is never selected)
var _focus_column: int = 0
## Number of collectible pages (1 when everything fits on screen)
var _collect_pages: int = 1
## Current collectibles page (0-based)
var _collect_page: int = 0

var _style_normal: StyleBoxFlat
var _style_hover: StyleBoxFlat
var _style_selected: StyleBoxFlat

@onready var _portrait_box: Control = $Window/Layout/LeftPanel/LeftColumn/PortraitBox
@onready var _portrait: AnimatedSprite2D = $Window/Layout/LeftPanel/LeftColumn/PortraitBox/Portrait
@onready var _skills_flow: FlowContainer = $Window/Layout/LeftPanel/LeftColumn/SkillsFlow
@onready var _consumables_flow: FlowContainer = $Window/Layout/LeftPanel/LeftColumn/ConsumablesFlow
@onready var _collectibles_page: Label = $Window/Layout/CollectiblesPanel/CollectiblesColumn/CollectiblesHeaderRow/CollectiblesPage
@onready var _collectibles_grid: GridContainer = $Window/Layout/CollectiblesPanel/CollectiblesColumn/CollectiblesGrid
@onready var _prev_page_button: Button = $Window/Layout/CollectiblesPanel/CollectiblesColumn/CollectiblesHeaderRow/PrevPage
@onready var _next_page_button: Button = $Window/Layout/CollectiblesPanel/CollectiblesColumn/CollectiblesHeaderRow/NextPage
@onready var _item_icon: TextureRect = $Window/Layout/RightPanel/RightColumn/ItemIcon
@onready var _item_name: Label = $Window/Layout/RightPanel/RightColumn/ItemName
@onready var _item_stats: Label = $Window/Layout/RightPanel/RightColumn/ItemStats
@onready var _item_description: Label = $Window/Layout/RightPanel/RightColumn/ItemDescription

func _ready() -> void:
	visible = false
	_style_normal = _make_style(Color(0.176, 0.176, 0.176, 0.9), Color(0, 0, 0, 1), 1)
	_style_hover = _make_style(Color(0.24, 0.24, 0.26, 0.95), Color(0.45, 0.45, 0.5, 1), 1)
	# Mismo ancho de borde que el resto: el hueco no cambia de tamaño al seleccionar
	_style_selected = _make_style(Color(0.2, 0.26, 0.36, 0.95), Color(0.31, 0.51, 0.86, 1), 1)
	for button in [_prev_page_button, _next_page_button]:
		button.add_theme_stylebox_override("normal", _style_normal)
		button.add_theme_stylebox_override("hover", _style_hover)
		button.add_theme_stylebox_override("pressed", _style_hover)
		button.add_theme_stylebox_override("disabled", _style_normal)
	_prev_page_button.pressed.connect(_change_page.bind(-1))
	_next_page_button.pressed.connect(_change_page.bind(1))
	_portrait_box.resized.connect(_layout_portrait)

func _unhandled_input(event: InputEvent) -> void:
	var key := _event_key(event)
	# Tab alterna columnas con la pantalla abierta; si no, sigue abriendo el inventario
	if visible and key == KEY_TAB:
		_toggle_column()
		return
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
	elif event.is_action_pressed("ui_right"):
		_change_page(1)
	elif event.is_action_pressed("ui_left"):
		_change_page(-1)
	else:
		match key:
			KEY_Q:
				_change_page(-1)
			KEY_E:
				_change_page(1)
			KEY_W:
				_move_row(-1)
			KEY_S:
				_move_row(1)
			KEY_A:
				_move_selection(-1)
			KEY_D:
				_move_selection(1)

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
	_clear_flow(_collectibles_grid)
	_consumable_start = 0
	_collect_start = 0

	var inventory := _inventory()
	if inventory:
		_fill_slots(_skills_flow, inventory, 0, Inventory.SKILL_SLOTS)
		_consumable_start = _entries.size()
		_fill_slots(_consumables_flow, inventory, Inventory.SKILL_SLOTS, Inventory.MAX_SLOTS)
	_collect_start = _entries.size()

	# Solo los coleccionables de la página actual (6 filas de 6)
	var list: Array[PassiveItems] = []
	var passives := _passives()
	if passives:
		for passive in passives.active_passives:
			if passive and passive.icon:
				list.append(passive)
	var per_page := COLLECTIBLE_ROWS * _collectibles_grid.columns
	_collect_pages = maxi(1, (list.size() + per_page - 1) / per_page)
	_collect_page = clampi(_collect_page, 0, _collect_pages - 1)
	var start := _collect_page * per_page
	for i in range(start, mini(start + per_page, list.size())):
		_add_slot(_collectibles_grid, list[i], COLLECTIBLE_SLOT_SIZE)
	_update_collectibles_header()

## Crea los botones de un tramo del inventario (huecos vacío incluidos)
func _fill_slots(container: Container, inventory: Inventory, from: int, to: int) -> void:
	for i in range(from, to):
		_add_slot(container, inventory.get_slot(i))

## Añade un hueco al contenedor; registra la entrada solo si lleva objeto
func _add_slot(container: Container, item: Items, size: Vector2 = SLOT_SIZE) -> void:
	var button := Button.new()
	button.custom_minimum_size = size
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
	container.add_child(button)

func _clear_flow(container: Container) -> void:
	for child in container.get_children():
		container.remove_child(child)
		child.queue_free()

## Resalta la entrada indicada y muestra su información en el panel derecho
func _select(index: int) -> void:
	if _entries.is_empty():
		_selected = -1
		_focus_column = 0
		_clear_detail()
		return
	_selected = wrapi(index, 0, _entries.size())
	_focus_column = 0 if _selected < _collect_start else 1
	for entry in _entries:
		var button: Button = entry.button
		var is_selected: bool = button == _entries[_selected].button
		var style := _style_selected if is_selected else _style_normal
		button.add_theme_stylebox_override("normal", style)
		# El seleccionado conserva el azul también al pasar el ratón por encima
		button.add_theme_stylebox_override("hover", style if is_selected else _style_hover)
		button.add_theme_stylebox_override("pressed", style if is_selected else _style_hover)
	var item: Items = _entries[_selected].item
	_item_icon.texture = item.icon
	_item_name.text = item.item_name
	_item_stats.text = _stats_text(item)
	_item_description.text = item.description

func _move_selection(step: int) -> void:
	if _entries.is_empty():
		return
	if _focus_column == 0:
		if _collect_start > 0:
			_select(wrapi(_selected + step, 0, _collect_start))
		return
	var count := _entries.size() - _collect_start
	if count > 0:
		_select(_collect_start + wrapi(_selected - _collect_start + step, 0, count))

## Moves one row up/down inside the active column (stays on the current page)
func _move_row(step: int) -> void:
	if _entries.is_empty():
		return
	if _focus_column == 0:
		_move_left_row(step)
		return
	if _selected < _collect_start:
		return
	var target := _selected + step * _collectibles_grid.columns
	if target >= _collect_start and target < _entries.size():
		_select(target)

## In the left column W/S jumps between the skills and consumables rows
func _move_left_row(step: int) -> void:
	if step < 0:
		if _selected >= _consumable_start and _consumable_start > 0:
			_select(mini(_selected - _consumable_start, _consumable_start - 1))
	elif _selected < _consumable_start and _consumable_start < _collect_start:
		_select(_consumable_start + mini(_selected, _collect_start - _consumable_start - 1))

## Tab toggles between the skills/consumables and collectibles columns
func _toggle_column() -> void:
	if _focus_column == 0:
		if _collect_start < _entries.size():
			_select(_collect_start)
	elif _collect_start > 0:
		_select(0)

func _event_key(event: InputEvent) -> int:
	if not event is InputEventKey:
		return KEY_NONE
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return KEY_NONE
	return key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode

## Cambia de página de coleccionables y selecciona el primero de la nueva
func _change_page(step: int) -> void:
	if _collect_pages <= 1:
		return
	_collect_page = wrapi(_collect_page + step, 0, _collect_pages)
	_refresh()
	_select(_collect_start)

func _clear_detail() -> void:
	_item_icon.texture = null
	_item_name.text = ""
	_item_stats.text = ""
	_item_description.text = ""

## Updates the collectibles header and the pager buttons
func _update_collectibles_header() -> void:
	_collectibles_page.text = "%d/%d" % [_collect_page + 1, _collect_pages]
	var multiple := _collect_pages > 1
	_prev_page_button.disabled = not multiple
	_next_page_button.disabled = not multiple

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
