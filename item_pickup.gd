class_name ItemPickup
extends Area2D

## Half the sprite height (px): the item rests with its base on the ground
const HALF_HEIGHT: float = 16.0
## Physics layer of the world (ground and platforms)
const WORLD_LAYER: int = 1
## Maximum distance (px) searched downwards for the ground when spawning
const GROUND_SEARCH_DISTANCE: float = 1024.0
## Seconds the pickup exists since it spawns (even if nobody sees it).
const SPAWN_LIFETIME: float = 60.0
## Seconds since first seen until the pickup starts blinking.
const BLINK_START: float = 25.0
## Seconds since first seen until the pickup disappears.
const SEEN_LIFETIME: float = 30.0
## Blink interval in seconds (sprite on/off).
const BLINK_INTERVAL: float = 0.2

@export_group("Item")
## Item this entity gives when picked up
@export var item: Items

@export_group("Physics")
## Falling acceleration (px/s²)
@export var fall_gravity: float = 900.0
## Bounce restitution on ground impact (0 = no bounce)
@export var bounce: float = 0.45
## Minimum impact speed (px/s) allowed to bounce; below it the item settles
@export var min_bounce_speed: float = 35.0
## Height of the idle bob (px)
@export var float_height: float = 1.5
## Idle bob speed (radians/second)
@export var float_speed: float = 2.5

enum State { FALLING, FLOATING }

var _state: int = State.FALLING
var _velocity_y: float = 0.0
var _rest_y: float = 0.0
## Known ground surface height; negative until the spawn search succeeds
var _ground_y: float = -1.0
var _ground_searched: bool = false
var _phase: float = 0.0
var _time: float = 0.0
## Time alive since spawn (`SPAWN_LIFETIME` safety net).
var _spawn_age: float = 0.0
## Time the pickup has been visible on screen (`BLINK_START`/`SEEN_LIFETIME`).
var _seen_age: float = 0.0
var _blink_timer: float = 0.0
var _blink_visible: bool = true

@onready var sprite: Sprite2D = $Sprite2D
@onready var _proximity_area: Area2D = get_node_or_null("ProximityArea")
@onready var _tooltip: Control = get_node_or_null("Tooltip")

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_phase = randf() * TAU
	# Siempre por encima de los tiles: el vaivén nunca queda medio oculto
	z_index = 1
	if item and item.icon and sprite:
		sprite.texture = item.icon
	_setup_tooltip()
	if _proximity_area:
		_proximity_area.body_entered.connect(_on_proximity_body_entered)
		_proximity_area.body_exited.connect(_on_proximity_body_exited)

func _physics_process(delta: float) -> void:
	if _update_expiry(delta):
		return

	# El suelo se busca una sola vez en el primer tick (con la posición real ya
	# asignada) y el aterrizaje se compara contra esa altura fija. Antes se
	# lanzaba un rayo corto por frame: los impactos lentos no lo detectaban y
	# min_bounce_speed era inalcanzable, así que el objeto nunca asentaba.
	if not _ground_searched:
		_ground_searched = true
		_find_ground()

	if _state == State.FLOATING:
		_time += delta
		global_position.y = _rest_y + sin(_time * float_speed + _phase) * float_height
		return

	if _ground_y < 0.0:
		return

	_velocity_y += fall_gravity * delta
	var next_y := global_position.y + _velocity_y * delta
	if _velocity_y > 0.0 and next_y >= _ground_y - HALF_HEIGHT:
		global_position.y = _ground_y - HALF_HEIGHT
		if absf(_velocity_y) < min_bounce_speed:
			_settle(_ground_y - HALF_HEIGHT)
		else:
			_velocity_y = -_velocity_y * bounce
		return
	global_position.y = next_y

## Caducidad: `SPAWN_LIFETIME` desde que aparece y `SEEN_LIFETIME` desde que se
## ve por primera vez (parpadea desde `BLINK_START`). Devuelve true cuando el
## objeto ya se ha liberado y no debe seguir procesándose.
func _update_expiry(delta: float) -> bool:
	_spawn_age += delta
	if _spawn_age >= SPAWN_LIFETIME:
		queue_free()
		return true
	if not _is_seen():
		return false
	_seen_age += delta
	if _seen_age >= SEEN_LIFETIME:
		queue_free()
		return true
	if _seen_age >= BLINK_START:
		_blink_timer += delta
		if _blink_timer >= BLINK_INTERVAL:
			_blink_timer = 0.0
			_blink_visible = not _blink_visible
			if sprite:
				sprite.visible = _blink_visible
	return false

## True cuando el pickup cae dentro de la cámara (el reloj de 30 s no corre
## para lo que todavía no se ha visto; las monedas no usan este script).
func _is_seen() -> bool:
	if not is_inside_tree():
		return false
	var viewport := get_viewport()
	var camera := viewport.get_camera_2d()
	if camera == null:
		return true
	var half := viewport.get_visible_rect().size * 0.5 / camera.zoom
	var offset := global_position - camera.get_screen_center_position()
	return absf(offset.x) <= half.x + HALF_HEIGHT and absf(offset.y) <= half.y + HALF_HEIGHT


## Auto pickup: touching the item is enough (no key press)
func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player") or item == null:
		return
	# El objeto decide dónde va (barra o pasivas); si no define on_pickup
	# (p. ej. las skills), va al inventario
	if item.has_method("on_pickup"):
		if item.on_pickup(body):
			_pickup_fx()
			queue_free()
		return
	var inventory := body.get_node_or_null("Inventory")
	if inventory and inventory.call("add_item", item):
		_pickup_fx()
		queue_free()


## Chispas al recoger el objeto; el FX del juego las dibuja en el mundo.
func _pickup_fx() -> void:
	var fx := get_tree().get_first_node_in_group("fx")
	if fx:
		fx.call("item_pickup", global_position)

## Shows the tooltip when the player gets close
func _on_proximity_body_entered(body: Node2D) -> void:
	if body.is_in_group("player") and _tooltip:
		_tooltip.visible = true

## Hides the tooltip when the player walks away
func _on_proximity_body_exited(body: Node2D) -> void:
	if body.is_in_group("player") and _tooltip:
		_tooltip.visible = false

## Fills the tooltip with the item name and description
func _setup_tooltip() -> void:
	if _tooltip == null or item == null:
		return
	var name_label := _tooltip.get_node_or_null("VBox/NameLabel") as Label
	var desc_label := _tooltip.get_node_or_null("VBox/DescPanel/DescLabel") as Label
	if name_label:
		name_label.text = item.item_name
	if desc_label:
		desc_label.text = item.description

## Searches for the ground at spawn time; settles at once when the item is
## already at (or below) rest height
func _find_ground() -> void:
	var surface := _cast_ray(global_position + Vector2(0, GROUND_SEARCH_DISTANCE))
	if surface < 0.0:
		surface = _cast_ray(global_position + Vector2(0, -64.0))
	if surface < 0.0:
		# Sin suelo cerca: se queda flotando donde aparece
		_settle(global_position.y)
		return
	_ground_y = surface
	if global_position.y >= _ground_y - HALF_HEIGHT:
		_settle(_ground_y - HALF_HEIGHT)

## Casts a ray against the world layer; returns the hit height or -1
func _cast_ray(destiny: Vector2) -> float:
	var space := get_world_2d().direct_space_state
	var query := PhysicsRayQueryParameters2D.create(global_position, destiny, WORLD_LAYER)
	var hit := space.intersect_ray(query)
	if hit.is_empty():
		return -1.0
	return hit["position"].y

## Stops the item at the given height and enables the idle bob
func _settle(y: float) -> void:
	global_position.y = y
	_rest_y = y
	_velocity_y = 0.0
	_state = State.FLOATING
