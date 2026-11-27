class_name DecorProp
extends Sprite2D
## Decoration prop: never collides and lives with its chunk. Bushes bend and
## drop a few leaves when the player walks through them; the rest do nothing
## (the script turns its `_process` off, so a chunk full of trees costs nothing).

## Enables the bend and the leaf burst.
@export var sways: bool = false
## Horizontal reach of the bend, in pixels.
@export var sway_radius_px: float = 48.0
## Maximum bend, in radians (0.1 ≈ 6°).
@export var sway_angle: float = 0.1
## Leaves thrown on entry. Half of T-0103's 7: the burst was too busy (T-0107).
@export var leaves_per_burst: int = 4
## Leaves thrown when the player leaves the bush: more than on entry, but
## fewer than T-0103's 18 (T-0107).
@export var leaves_on_exit: int = 9
## Share of the burst drawn behind the bush; the rest is drawn in front, so the
## shrub reads as a volume instead of a flat cut-out (T-0107).
@export_range(0.0, 1.0, 0.05) var leaves_behind_share: float = 0.45
## The behind leaves are thrown from where the player is, so while he walks
## away they keep falling on him for a moment instead of all from the crown.
@export var behind_leaves_follow_player: bool = true
## Physics force of the burst; a little stronger than T-0103 (T-0107).
@export var burst_force: float = 112.0
## Biome tint of the foliage; the leaf burst uses it so the particles match.
@export var tint_color: Color = Color.WHITE

## The sprite origin is the bottom center, so rotation pivots on the ground.
var _player: Node2D
var _time: float = 0.0
var _phase: float = 0.0
var _bend: float = 0.0
var _was_near: bool = false


func _ready() -> void:
	if not sways:
		set_process(false)
		return
	# Different phase per bush so a row of them does not sway in unison.
	_phase = fmod(absf(global_position.x + global_position.y), TAU)
	_find_player()


func _process(delta: float) -> void:
	if not is_instance_valid(_player):
		_find_player()
		if _player == null:
			return
	_time += delta
	var dx := _player.global_position.x - global_position.x
	var dy := _player.global_position.y - global_position.y
	# The player's origin sits above its feet, so vertical tolerance is wide.
	var near := absf(dx) < sway_radius_px and absf(dy) < 80.0
	var target := 0.0
	if near:
		target = clampf(1.0 - absf(dx) / sway_radius_px, 0.15, 1.0)
	_bend = lerpf(_bend, target, clampf(delta * 12.0, 0.0, 1.0))
	rotation = sin(_time * 8.5 + _phase) * sway_angle * _bend
	if near != _was_near:
		# Entering sheds a few leaves; leaving shakes the whole bush.
		_emit_leaves(leaves_per_burst if near else leaves_on_exit)
	_was_near = near


## Player by group, then by the usual sibling name (some scenes omit the group).
func _find_player() -> void:
	_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null:
		# Chunk → map → game root → `player`.
		var map := get_parent()
		var root := map.get_parent() if map else null
		if root:
			_player = root.get_node_or_null("player") as Node2D


## Leaf burst from the crown. Uses the Sprite Fusion leaves of the ambient (the
## same art the weather uses, T-0103) and falls back to the old `fx` burst when
## there is no ambient in the scene (the dungeon test scenes).
## T-0107: the burst is split between the layer in front of the bush and the one
## behind it; the behind leaves are born at the player so they trail him.
func _emit_leaves(amount: int) -> void:
	if texture == null or amount <= 0:
		return
	var crown := global_position + Vector2(0.0, -texture.get_height() * scale.y * 0.55)
	var color := tint_color.lightened(0.25)
	var ambient := _ambient()
	if ambient != null and not ambient.visible:
		# Leaves toggle off (SettingsPanel): no burst in either layer.
		return
	var behind := 0
	if ambient != null and amount > 1:
		behind = clampi(roundi(float(amount) * leaves_behind_share), 1, amount - 1)
	var front := amount - behind
	if ambient != null:
		ambient.call("burst_leaves", crown, color, front, burst_force)
	else:
		var fx := get_tree().get_first_node_in_group("fx")
		if fx != null:
			fx.call("leaves", crown, color, amount)
		return
	if behind <= 0:
		return
	var back := _back_ambient()
	if back != null:
		back.call("burst_leaves", _behind_origin(crown), color, behind, burst_force)


## Origin of the leaves drawn behind the bush: the player's body while he is
## valid, so they keep falling where he stands for a moment, and the crown as a
## fallback.
func _behind_origin(crown: Vector2) -> Vector2:
	if behind_leaves_follow_player and is_instance_valid(_player):
		return _player.global_position + Vector2(0.0, 2.0)
	return crown


## Leaf layer that draws BEHIND the bushes: `behind_leaves`, a child of the map
## placed before the chunks. It has no idle rain, only the pool the bursts use
## (T-0107).
func _back_ambient() -> SpriteFusionAmbient:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var map := scene.get_node_or_null("map")
	if map == null:
		return null
	return map.get_node_or_null("behind_leaves") as SpriteFusionAmbient


## Leaves ambient of the world: the `biome_particles` child whose effect is
## `leaves` (the snow one must not throw leaves in the snow biome).
func _ambient() -> SpriteFusionAmbient:
	var scene := get_tree().current_scene
	if scene == null:
		return null
	var particles := scene.get_node_or_null("biome_particles")
	if particles == null:
		return null
	for child in particles.get_children():
		if child is SpriteFusionAmbient and String(child.get("effect")) == "leaves":
			return child as SpriteFusionAmbient
	return null
