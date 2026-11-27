class_name ShopScreen
extends CanvasLayer
## Buy window of a merchant stall.
##
## Built in code on purpose: it is a handful of rows, so there is no `.tscn` for
## the editor to reserialize. The tree is paused while it is open and this layer
## runs with `PROCESS_MODE_ALWAYS`, so the keys keep working.
##
## Keys: W/S or up/down to pick, E/Enter or click to buy, F or Esc to leave.

## Emitted when the window closes and the tree is not paused any more.
signal closed

const PANEL_SIZE := Vector2(232, 156)
const FONT_SMALL := 9
const FONT_TITLE := 11

## Untyped on purpose (see `Merchant._shop`): avoids a cyclic `class_name`
## reference between the stall and its window.
var _merchant
## One entry per item on sale: `{item, price, button}`.
var _rows: Array[Dictionary] = []
var _selected := 0
## Ignores input for a moment after opening: the F that opened it must not buy.
var _input_lock := 0.0

var _root: Control
var _coins_label: Label
var _message_label: Label
var _list: VBoxContainer


func _init() -> void:
	layer = 12
	process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false


func _process(delta: float) -> void:
	_input_lock = maxf(_input_lock - delta, 0.0)


func _unhandled_input(event: InputEvent) -> void:
	if not visible or _input_lock > 0.0:
		return
	var key := _event_key(event)
	if event.is_action_pressed("ui_cancel") or key == KEY_F:
		close()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_up") or key == KEY_W:
		_move(-1)
	elif event.is_action_pressed("ui_down") or key == KEY_S:
		_move(1)
	elif event.is_action_pressed("ui_accept") or key == KEY_E:
		_buy(_selected)
	else:
		return
	get_viewport().set_input_as_handled()


## Opens the window for `merchant` and pauses the game.
func open(merchant) -> void:
	_merchant = merchant
	_build()
	_build_rows()
	visible = true
	get_tree().paused = true
	_input_lock = 0.2
	_selected = 0
	_refresh()


func close() -> void:
	if not visible:
		return
	visible = false
	get_tree().paused = false
	closed.emit()
	queue_free()


func _exit_tree() -> void:
	# Never leave the tree paused if the scene goes away with the shop open.
	if get_tree() and get_tree().paused:
		get_tree().paused = false


func _build() -> void:
	if _root != null:
		return
	_root = Control.new()
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var dim := ColorRect.new()
	dim.color = Color(0, 0, 0, 0.55)
	dim.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_root.add_child(dim)
	dim.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var center := CenterContainer.new()
	_root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = PANEL_SIZE
	panel.add_theme_stylebox_override("panel", _panel_style())
	center.add_child(panel)

	var column := VBoxContainer.new()
	column.add_theme_constant_override("separation", 4)
	panel.add_child(column)

	var title := Label.new()
	title.text = "Merchant"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", FONT_TITLE)
	column.add_child(title)

	_coins_label = Label.new()
	_coins_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_coins_label.add_theme_font_size_override("font_size", FONT_SMALL)
	column.add_child(_coins_label)

	_list = VBoxContainer.new()
	_list.add_theme_constant_override("separation", 2)
	column.add_child(_list)

	_message_label = Label.new()
	_message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_message_label.add_theme_font_size_override("font_size", FONT_SMALL)
	column.add_child(_message_label)

	var hint := Label.new()
	hint.text = "W/S pick · E buy · F leave"
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.add_theme_font_size_override("font_size", FONT_SMALL)
	hint.add_theme_color_override("font_color", Color(0.72, 0.72, 0.78, 1))
	column.add_child(hint)


func _build_rows() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	_rows.clear()
	if _merchant == null:
		return
	for item in _merchant.stock:
		var button := Button.new()
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.focus_mode = Control.FOCUS_NONE
		button.icon = item.icon
		button.expand_icon = false
		button.icon_max_width = 16
		button.add_theme_font_size_override("font_size", FONT_SMALL)
		button.pressed.connect(_buy.bind(_rows.size()))
		_list.add_child(button)
		_rows.append({
			"item": item,
			"price": _merchant.price_of(item),
			"button": button,
		})


func _refresh() -> void:
	var player := _player()
	var coins := int(player.get("current_coins")) if player != null else 0
	_coins_label.text = "%d coins" % coins
	for i in _rows.size():
		var row: Dictionary = _rows[i]
		var item: Items = row["item"]
		var button: Button = row["button"]
		# Explicitly typed: `_merchant` is untyped, so `:=` cannot infer a bool.
		var sold: bool = _merchant != null and bool(_merchant.call("is_sold", item))
		button.text = "  %s — %s" % [item.item_name, "sold" if sold else "%d" % int(row["price"])]
		button.disabled = sold
		button.modulate = Color(0.55, 0.55, 0.6, 1) if sold else Color.WHITE
		button.add_theme_color_override(
			"font_color",
			Color(0.72, 1, 0.28, 1) if i == _selected and not sold else Color(1, 1, 1, 1)
		)
	if not _rows.is_empty():
		_selected = clampi(_selected, 0, _rows.size() - 1)


func _move(step: int) -> void:
	if _rows.size() < 2:
		return
	_selected = wrapi(_selected + step, 0, _rows.size())
	_refresh()


func _buy(index: int) -> void:
	if _merchant == null or index < 0 or index >= _rows.size():
		return
	var row: Dictionary = _rows[index]
	var item: Items = row["item"]
	if _merchant.is_sold(item):
		_message_label.text = "Sold out"
		return
	var player := _player()
	if player == null:
		return
	var price := int(row["price"])
	if int(player.get("current_coins")) < price:
		_message_label.text = "Not enough coins"
		return
	var inventory := player.get_node_or_null("Inventory") as Inventory
	if inventory == null or not _has_room(inventory):
		_message_label.text = "No free slot"
		return
	if not bool(player.call("spend_coins", price)):
		_message_label.text = "Not enough coins"
		return
	inventory.add_item(item)
	_merchant.mark_sold(item)
	_selected = index
	_message_label.text = "Bought %s" % item.item_name
	_refresh()


func _has_room(inventory: Inventory) -> bool:
	for i in Inventory.MAX_SLOTS:
		if inventory.get_slot(i) == null:
			return true
	return false


func _player() -> Node:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	return scene.get_node_or_null("player")


func _event_key(event: InputEvent) -> int:
	if not event is InputEventKey:
		return KEY_NONE
	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return KEY_NONE
	return key_event.physical_keycode if key_event.physical_keycode != 0 else key_event.keycode


func _panel_style() -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(0.08, 0.07, 0.11, 0.97)
	box.border_color = Color(0.55, 0.45, 0.3, 1)
	box.set_border_width_all(1)
	box.set_corner_radius_all(2)
	box.set_content_margin_all(8)
	return box
