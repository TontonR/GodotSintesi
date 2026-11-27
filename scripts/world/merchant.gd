class_name Merchant
extends Node2D
## Merchant stall of the chunked world (type 1 structure): the sprite plus its
## prompt and the shop window.
##
## The stock is rolled from the stall's world position, so the same stall always
## sells the same items after a chunk reload. It lives inside a chunk, so it dies
## with it: the shop window is added to the game scene instead, and the sold
## items are remembered here for as long as this node lives.

## Radius (px) where the prompt shows and F opens the shop.
const PROMPT_RADIUS_PX := 56.0
## Consumables a stall can sell; the roll picks three different ones.
const CATALOG: Array[String] = [
	"res://resources/pocion_cura.tres",
	"res://resources/pocion_cura_menor.tres",
	"res://resources/elixir_vida.tres",
	"res://resources/pocion_stamina.tres",
	"res://resources/pocion_mayor.tres",
	"res://resources/pocion_stamina_mayor.tres",
	"res://resources/bebida_tonificante.tres",
	"res://resources/esencia_vital.tres",
	"res://resources/pocion_mocos.tres",
	"res://resources/capa_inv.tres",
	"res://resources/teleport.tres",
	"res://resources/cadena_perpetua.tres",
]
## Different items a stall sells.
const STOCK_SIZE := 3

## Items on sale, in order. Filled by `_ready()`.
var stock: Array[Items] = []
## `resource_path` of every item already bought here.
var sold: Array[String] = []

var _prompt: Label
var _layer: CanvasLayer
## Untyped on purpose: `ShopScreen` types `Merchant` too, and two `class_name`
## scripts pointing at each other is a cyclic reference.
var _shop


func _ready() -> void:
	add_to_group("merchant")
	_build_stock()
	_build_prompt()


func _process(_delta: float) -> void:
	_update_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and _player_in_range():
		_open()
		get_viewport().set_input_as_handled()


## Price of one unit, derived from the stats so retuning a potion retunes its
## price: 20 points of heal/stamina cost 5, 50 cost 13, 100 cost 25. Items with
## a special effect (no numbers) cost a flat 20.
func price_of(item: Items) -> int:
	var consumable := item as Consumable
	if consumable == null:
		return 20
	var power := consumable.heal_amount + consumable.stamina_amount
	if power <= 0:
		return 20
	return maxi(5, roundi(power / 4.0))


## Marks an item as bought, so reopening the shop shows it sold out.
func mark_sold(item: Items) -> void:
	if item == null or item.resource_path.is_empty():
		return
	if not sold.has(item.resource_path):
		sold.append(item.resource_path)


## True when this stall has already sold that item.
func is_sold(item: Items) -> bool:
	return item != null and sold.has(item.resource_path)


## Three different consumables, picked with a hash of the world position: the
## same stall rolls the same list without touching the chunk RNG.
func _build_stock() -> void:
	stock.clear()
	var rng := RandomNumberGenerator.new()
	rng.seed = int(hash("merchant:%d:%d" % [roundi(global_position.x), roundi(global_position.y)]))
	var pool: Array[int] = []
	for i in CATALOG.size():
		pool.append(i)
	for i in range(pool.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var swap := pool[i]
		pool[i] = pool[j]
		pool[j] = swap
	for k in mini(STOCK_SIZE, pool.size()):
		var item := load(CATALOG[pool[k]]) as Items
		if item != null:
			stock.append(item)


func _open() -> void:
	if _shop != null and is_instance_valid(_shop):
		return
	var scene := get_tree().current_scene
	if scene == null or stock.is_empty():
		return
	# Outside the chunk on purpose: unloading it must not free the window with
	# the tree paused.
	_shop = ShopScreen.new()
	# The tree pauses with the window open, so this node stops processing: hide the
	# prompt here or it stays frozen over the panel.
	_prompt.visible = false
	scene.add_child(_shop)
	_shop.closed.connect(_on_shop_closed)
	_shop.open(self)


func _on_shop_closed() -> void:
	_shop = null


func _player() -> Node2D:
	return get_tree().get_first_node_in_group("player") as Node2D


func _player_in_range() -> bool:
	var player := _player()
	if player == null:
		return false
	return player.global_position.distance_to(global_position) <= PROMPT_RADIUS_PX


## "F: shop" over the stall, in screen space, only when the player is close and
## the window is not open.
func _update_prompt() -> void:
	if _prompt == null:
		return
	var shop_open := _shop != null and is_instance_valid(_shop)
	var player := _player()
	if shop_open or player == null or not _player_in_range():
		_prompt.visible = false
		return
	var screen := get_viewport().get_canvas_transform() * global_position
	_prompt.position = Vector2(roundf(screen.x - 40.0), roundf(screen.y - 104.0))
	_prompt.visible = true


func _build_prompt() -> void:
	_layer = CanvasLayer.new()
	_layer.name = "MerchantPrompt"
	# Same layer as the other world prompts: above the HUD, below the menus.
	_layer.layer = 8
	add_child(_layer)
	_prompt = Label.new()
	_prompt.text = "F: shop"
	_prompt.visible = false
	_prompt.size = Vector2(80, 20)
	_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_prompt.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	_prompt.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
	_prompt.add_theme_constant_override("shadow_offset_x", 1)
	_prompt.add_theme_constant_override("shadow_offset_y", 1)
	_prompt.add_theme_font_size_override("font_size", 10)
	_layer.add_child(_prompt)
