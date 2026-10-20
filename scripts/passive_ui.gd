class_name PassiveUI
extends GridContainer

## Number of columns in the passive grid
const COLUMNS: int = 6
## Maximum rows visible at once (one page)
const MAX_ROWS: int = 10
## Icons visible per page (COLUMNS × MAX_ROWS)
const PER_PAGE: int = COLUMNS * MAX_ROWS
## Size of each icon in pixels
const ICON_SIZE := Vector2(12, 12)

## Linked passive list (bound by PlayerPassives when entering the tree)
var source: PlayerPassives
## Current page (0-based); flipped with the left/right arrows
var _page: int = 0

@onready var _page_label: Label = get_parent().get_node_or_null("PassivePageLabel") as Label

func _init() -> void:
	columns = COLUMNS
	add_theme_constant_override("h_separation", 2)
	add_theme_constant_override("v_separation", 2)

func bind(passives: PlayerPassives) -> void:
	if source and source.passives_changed.is_connected(_refresh):
		source.passives_changed.disconnect(_refresh)
	source = passives
	source.passives_changed.connect(_refresh)
	_refresh()

## Left/right arrows flip the page when there is more than one
func _unhandled_input(event: InputEvent) -> void:
	if _page_count() <= 1:
		return
	if event.is_action_pressed("ui_right"):
		_set_page(_page + 1)
	elif event.is_action_pressed("ui_left"):
		_set_page(_page - 1)

## Shows the given page, wrapping around the last one
func _set_page(page: int) -> void:
	_page = wrapi(page, 0, _page_count())
	_refresh()

## Shows the page counter only when there is more than one page
func _update_page_label() -> void:
	if _page_label == null:
		return
	var pages := _page_count()
	_page_label.visible = pages > 1
	_page_label.text = "Pág. %d/%d" % [_page + 1, pages]

## Number of pages needed to show every passive
func _page_count() -> int:
	return maxi(1, (_page_list().size() + PER_PAGE - 1) / PER_PAGE)

## Passive list filtered to the ones that can be drawn (they must have an icon)
func _page_list() -> Array[PassiveItems]:
	var list: Array[PassiveItems] = []
	if source:
		for passive in source.active_passives:
			if passive and passive.icon:
				list.append(passive)
	return list

func _refresh() -> void:
	for child in get_children():
		remove_child(child)
		child.queue_free()
	if source == null:
		_update_page_label()
		return
	var list := _page_list()
	_page = clampi(_page, 0, _page_count() - 1)
	_update_page_label()
	var count := list.size()
	var start := _page * PER_PAGE
	# Más recientes primero (arriba a la izquierda) dentro de la página actual
	for j in range(start, mini(start + PER_PAGE, count)):
		var passive := list[count - 1 - j]
		var icon := TextureRect.new()
		icon.custom_minimum_size = ICON_SIZE
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture = passive.icon
		icon.modulate = Color(1, 1, 1, 0.55)
		icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
		add_child(icon)
