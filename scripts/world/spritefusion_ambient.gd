class_name SpriteFusionAmbient
extends Node2D

# ==============================================================================
# SPRITE FUSION AMBIENT VFX (WORLD SPACE)
# ==============================================================================
# Port of two free (MIT) effects from Sprite Fusion's VFX library:
#   - falling-leaves: https://www.spritefusion.com/pixel-art-vfx/falling-leaves
#   - snow:           https://www.spritefusion.com/pixel-art-vfx/snow
# Shapes, palettes and motion constants come from the downloaded .ts recipes
# (assets/vfx/spritefusion/). Particles live in WORLD coordinates: the parent
# CanvasLayer copies the camera transform every frame, and this node spawns and
# recycles around the visible world rect. Walking therefore scrolls them instead
# of dragging them along, and they land on `WorldGenerator.ground_y_at()`.
# The recipes' ground layers are also ported: leaf litter and the snow drift.
# The ground is read per TILE, so the drift and the resting drops follow the
# block steps (never a diagonal), and each particle is spawned with the biome
# share of its own tile as probability: the weather thins out through the
# terrain transition instead of fading the whole layer's opacity (T-0094).
# Round 5 (T-0093): the leaves are smaller, spawned outside the view so they
# are already falling when the camera reaches them, each one drifts in its own
# direction, and living trees rain leaves tinted like their own crown.

const LEAF_DRIFT := 12.0
const LEAF_COUNT := 108
const LITTER_SPACING := 18.0
## Leaves are spawned this far outside the view (world px) and culled at the
## same distance: while running, the weather is already falling in the frame
## that is about to enter instead of popping in front of the camera.
const LEAF_SPAWN_MARGIN := 260.0
## Falling leaves and the litter are drawn at this fraction of the recipe's
## pixels; the art was too big at 1 px per art pixel.
const LEAF_SCALE := 0.75
## Share of the leaves born under a living tree instead of the open sky.
const TREE_LEAF_SHARE := 0.55
const CANOPY_REFRESH_SECONDS := 0.25
const SNOW_WIND := 14.0
const SNOW_COUNTS := [260, 150, 30]
const SNOW_FALL := [26.0, 52.0, 86.0]
const SNOW_SWAY := [8.0, 16.0, 30.0]
## World pixels between two ground samples: one tile, so the weather steps
## with the blocks and never draws a diagonal.
const GROUND_STEP := 16.0
const GROUND_REFRESH_SECONDS := 0.1
const OFFSCREEN_MARGIN := 80.0
## World pixels sampled around the view for the ground and biome-share lookups.
## It covers the leaf spawn margin plus their drift, so a leaf spawned off
## camera still reads the share of its own tile in a transition.
const GROUND_MARGIN := 360.0
## Attempts to find a tile whose biome share passes the spawn roll.
const SPAWN_TRIES := 16
## Seconds a hidden particle waits before rolling for a new tile.
const RETRY_SECONDS := 0.25

## 3 leaf silhouettes from falling-leaves.ts; L/B/S/D/R/T are palette slots.
const LEAF_SHAPES: Array = [
	["......DDDD..", "...DDDLLLBD.", ".DDLLLRLBBBD", "TRRRRRRRRRRD", ".DDBBBBBRSSD", "...DDDSSSSD.", "......DDDD.."],
	["...DDD...", "..DLLBD..", ".DLLLBBD.", "DLLRBBBSD", "DLBBRBSSD", ".DBBBRSD.", "..DDSSD..", "....T...."],
	[".....D.....", "....DLD....", ".DD.DLD.DD.", ".DLDDLDDLD.", "..DLLLBBD..", "DDDLLRBBDDD", ".DLLBRBSSD.", "..DDBRSDD..", "....DRD....", ".....T....."],
]

## Autumn palettes from falling-leaves.ts, in light/base/shade/dark order.
const LEAF_PALETTES: Array = [
	["ffc86a", "f08a2a", "b8521a", "5e240e"],
	["ff8a66", "d8382a", "9a1f22", "470f15"],
	["fff09a", "f0c83a", "b88a1c", "5a3f10"],
	["c99a62", "9a6a3b", "6b4424", "33200f"],
]

## Crystals from snow.ts: two 7x7 frames and one 5x5 frame.
const SNOW_CRYSTALS: Array = [
	["...b...", ".b.w.b.", "..bwb..", "bwwWwwb", "..bwb..", ".b.w.b.", "...b..."],
	["b..b..b", ".b.w.b.", "..wWw..", "bwWWWwb", "..wWw..", ".b.w.b.", "b..b..b"],
	["..b..", ".bwb.", "bwWwb", ".bwb.", "..b.."],
]

## Drift colours from snow.ts.
const DRIFT_HEX := ["e9f0ff", "c3cff0", "8e9ccc"]

@export_group("Effect")
## Ambient effect to draw: leaves for the red forest, snow for the snow biome.
@export_enum("leaves", "snow") var effect: String = "leaves"
## Multiplies the recipe's particle count; 1.0 is the library default.
@export_range(0.1, 3.0, 0.05) var density: float = 1.0
## Screen pixels per art pixel. The library recipe uses 2; 1 halves the sizes.
@export_range(0.5, 2.0, 0.25) var pixel_scale: float = 1.0
## Seed for the initial scatter, so the same run reproduces the same cloud.
@export var rng_seed: int = 1

class Leaf:
	var sprite: Sprite2D
	var wait := 0.0
	var x0 := 0.0
	var x := 0.0
	var y := 0.0
	var vy := 0.0
	var amp := 0.0
	var w := 0.0
	var ph := 0.0
	var flip := 0.0
	var shape := 0
	var palette := 0
	var near := false
	var angle := 0.0
	var rest := -1.0
	var drift := 0.0
	var color := Color.WHITE


class Flake:
	var sprite: Sprite2D
	var wait := 0.0
	var x := 0.0
	var y := 0.0
	var vy := 0.0
	var sway := 0.0
	var f := 0.0
	var ph := 0.0
	var layer := 0
	var kind := 0
	var rest := -1.0


var _px := 1.0
## Screen pixels per art pixel for the leaves and the litter (see LEAF_SCALE).
var _leaf_px := 1.0
## Distance at which particles are recycled; the leaves use their spawn margin.
var _cull_margin := OFFSCREEN_MARGIN
var _view := Vector2.ZERO
var _area := Rect2()
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _world: Node
var _ground_world := PackedFloat32Array()
## Biome share (0..1) of every sampled tile, used as spawn probability.
var _share_world := PackedFloat32Array()
var _ground_origin := 0.0
var _ground_timer := 0.0

var _leaves: Array[Leaf] = []
## Live tree crowns (x, y, tint, half width) that rain leaves of their colour.
var _canopies: Array[Dictionary] = []
var _leaf_color_cache := {}
var _canopy_timer := 0.0
var _leaf_textures: Array[ImageTexture] = []
var _litter: Array[Sprite2D] = []
var _flakes: Array[Flake] = []
var _snow_dots: Array[ImageTexture] = []
var _snow_flake: ImageTexture
var _snow_crystals: Array[ImageTexture] = []
var _drift_colors: Array[Color] = []


func _ready() -> void:
	_px = pixel_scale
	_view = get_viewport_rect().size
	_refresh_area()
	_rng.seed = rng_seed
	modulate.a = 1.0
	if effect == "leaves":
		_build_leaves()
	else:
		_build_snow()
	_scatter()
	visible = true
	set_process(true)


## Turns the effect fully on or off. There is no fade: the layer is never
## translucent, the per-tile spawn probability is what thins the weather out.
func set_active(enabled: bool) -> void:
	visible = enabled
	set_process(enabled)
	if enabled:
		_scatter()


func _process(delta: float) -> void:
	_ground_timer -= delta
	if _ground_timer <= 0.0:
		_ground_timer = GROUND_REFRESH_SECONDS
		_refresh_ground()
	if effect == "leaves":
		_canopy_timer -= delta
		if _canopy_timer <= 0.0:
			_canopy_timer = CANOPY_REFRESH_SECONDS
			_refresh_canopies()
		_update_leaves(delta)
	else:
		_update_snow(delta)


## Fills the visible area on activation, so the weather never starts as drops.
func _scatter() -> void:
	_ground_timer = 0.0
	if _ground_world.is_empty():
		_refresh_ground()
	if effect == "leaves":
		_canopy_timer = CANOPY_REFRESH_SECONDS
		_refresh_canopies()
		for leaf in _leaves:
			_reset_leaf(leaf, false)
	else:
		_time = 0.0
		for flake in _flakes:
			_reset_flake(flake, false)


# --- Visible world rect and ground -----------------------------------------

## The parent CanvasLayer copies the camera transform, so `_area` is the visible
## slice of the world; spawning follows the camera, not the player node.
func _refresh_area() -> void:
	var canvas := get_viewport().get_canvas_transform()
	var inverse := canvas.affine_inverse()
	var top_left := inverse * Vector2.ZERO
	var bottom_right := inverse * _view
	_area = Rect2(top_left, bottom_right - top_left)


## Samples the terrain and the biome share of every visible tile column, one
## sample per TILE. It refreshes every 0.1 s, so ground and share snap to blocks.
func _refresh_ground() -> void:
	_refresh_area()
	var first := floori((_area.position.x - GROUND_MARGIN) / GROUND_STEP)
	var last := ceili((_area.end.x + GROUND_MARGIN) / GROUND_STEP)
	var columns := int(last - first) + 1
	if _ground_world.size() != columns:
		_ground_world.resize(columns)
		_share_world.resize(columns)
	if _world == null:
		_world = get_tree().get_first_node_in_group("world_generator")
	if _world == null or not _world.has_method("ground_y_at"):
		# Dungeon or no generator: the bottom of the view acts as the ground.
		_ground_world.fill(_area.end.y)
		_share_world.fill(1.0)
	else:
		_ground_origin = float(first) * GROUND_STEP
		for i in columns:
			var center_x := _ground_origin + (float(i) + 0.5) * GROUND_STEP
			_ground_world[i] = float(_world.call("ground_y_at", center_x))
			_share_world[i] = _biome_share(center_x)
	_place_litter()
	queue_redraw()


## Ground Y of the tile that contains `world_x`. Stepped on purpose: the
## weather sits on blocks, so two heights never meet in a diagonal.
func _ground_at(world_x: float) -> float:
	var last := _ground_world.size() - 1
	if last < 0:
		return _area.end.y
	var i := clampi(floori((world_x - _ground_origin) / GROUND_STEP), 0, last)
	return _ground_world[i]


## Biome share (0..1) of the tile that contains `world_x`.
func _share_at(world_x: float) -> float:
	var last := _share_world.size() - 1
	if last < 0:
		return 1.0
	var i := clampi(floori((world_x - _ground_origin) / GROUND_STEP), 0, last)
	return _share_world[i]


func _biome_share(world_x: float) -> float:
	if not _world.has_method("ambient_share_at_world_x"):
		return 1.0
	return clampf(float(_world.call("ambient_share_at_world_x", world_x, effect)), 0.0, 1.0)


## Random X inside the range whose tile share passes its own die roll, so the
## density of the weather follows the transition block by block.
func _pick_spawn_x(min_x: float, max_x: float) -> float:
	for i in SPAWN_TRIES:
		var x := _rng.randf_range(min_x, max_x)
		if _rng.randf() <= _share_at(x):
			return x
	return INF


func _out_of_area(x: float, y: float) -> bool:
	return (
		x < _area.position.x - _cull_margin
		or x > _area.end.x + _cull_margin
		or y > _area.end.y + 40.0
	)


# --- Leaves -----------------------------------------------------------------

func _build_leaves() -> void:
	_leaf_px = pixel_scale * LEAF_SCALE
	_cull_margin = LEAF_SPAWN_MARGIN + OFFSCREEN_MARGIN
	for shape in LEAF_SHAPES:
		for palette in LEAF_PALETTES:
			_leaf_textures.append(_make_texture(shape, _leaf_colors(palette)))
	_build_litter()
	var count := int(round(LEAF_COUNT * density))
	for i in count:
		var leaf := Leaf.new()
		leaf.sprite = _new_sprite(_leaf_textures[0], 0)
		_leaves.append(leaf)
		_reset_leaf(leaf, false)


## Litter is deterministic per world slot, so it never slides with the camera.
func _build_litter() -> void:
	var count := int(ceil((_area.size.x + 160.0) / LITTER_SPACING)) + 2
	for i in count:
		_litter.append(_new_sprite(_leaf_textures[0], -1))


func _place_litter() -> void:
	if effect != "leaves" or _litter.is_empty():
		return
	var start_slot := floori((_area.position.x - 60.0) / LITTER_SPACING)
	for i in _litter.size():
		var slot := start_slot + i
		var x := float(slot) * LITTER_SPACING + _hash(slot, 1) * LITTER_SPACING
		var sprite := _litter[i]
		# Litter only exists where this biome's share wins its own die roll.
		if _hash(slot, 7) > _share_at(x):
			sprite.visible = false
			continue
		sprite.visible = true
		var shape := int(_hash(slot, 2) * float(LEAF_SHAPES.size())) % LEAF_SHAPES.size()
		var palette := int(_hash(slot, 4) * float(LEAF_PALETTES.size())) % LEAF_PALETTES.size()
		sprite.texture = _leaf_textures[shape * LEAF_PALETTES.size() + palette]
		sprite.position = Vector2(x, _resting_y(x, sprite.texture.get_height()))
		sprite.rotation = (_hash(slot, 5) - 0.5) * 0.6
		sprite.scale = Vector2(_leaf_px, _leaf_px)


func _leaf_colors(palette: Array) -> Dictionary:
	var shade := Color(palette[2])
	var dark := Color(palette[3])
	return {
		"L": Color(palette[0]),
		"B": Color(palette[1]),
		"S": shade,
		"D": dark,
		"R": shade,
		"T": dark,
	}


## Leaf texture in a tree's tint: the same 3 silhouettes, with the palette
## derived from the crown colour (light, base, shade, dark). Cached because the
## biome only has a handful of decor tints.
func _leaf_color_texture(color: Color, shape: int) -> ImageTexture:
	var key := "%d:%s" % [shape, color.to_html(false)]
	if _leaf_color_cache.has(key):
		return _leaf_color_cache[key]
	var shade := color.darkened(0.25)
	var dark := color.darkened(0.55)
	var texture := _make_texture(LEAF_SHAPES[shape], {
		"L": color.lightened(0.45),
		"B": color,
		"S": shade,
		"D": dark,
		"R": shade,
		"T": dark,
	})
	_leaf_color_cache[key] = texture
	return texture


## Crowns of the living trees around the view (plus the spawn margin). They are
## in the `decor_tree` group and die with their chunk, so the check is only
## `is_instance_valid`; refreshed a few times per second instead of per leaf.
func _refresh_canopies() -> void:
	_canopies.clear()
	if effect != "leaves":
		return
	var min_x := _area.position.x - LEAF_SPAWN_MARGIN
	var max_x := _area.end.x + LEAF_SPAWN_MARGIN
	for node in get_tree().get_nodes_in_group("decor_tree"):
		var tree := node as DecorProp
		if tree == null or not is_instance_valid(tree) or tree.texture == null:
			continue
		var crown := tree.global_position + Vector2(
			0.0, -tree.texture.get_height() * tree.scale.y * 0.55
		)
		if crown.x < min_x or crown.x > max_x or crown.y > _area.end.y + 80.0:
			continue
		_canopies.append({
			"x": crown.x,
			"y": crown.y,
			"color": tree.tint_color,
			"half": tree.texture.get_width() * tree.scale.x * 0.3,
		})


## A visible crown whose tile belongs to this biome's share, or an empty dict
## for the open-sky spawn.
func _pick_canopy() -> Dictionary:
	if _canopies.is_empty() or _rng.randf() > TREE_LEAF_SHARE:
		return {}
	for i in 4:
		var canopy: Dictionary = _canopies[_rng.randi_range(0, _canopies.size() - 1)]
		if _rng.randf() <= _share_at(float(canopy["x"])):
			return canopy
	return {}


func _reset_leaf(leaf: Leaf, top: bool) -> void:
	leaf.wait = 0.0
	leaf.rest = -1.0
	leaf.angle = 0.0
	leaf.vy = _rng.randf_range(34.0, 56.0)
	leaf.amp = _rng.randf_range(14.0, 34.0)
	leaf.w = _rng.randf_range(1.8, 2.8)
	leaf.ph = _rng.randf_range(0.0, TAU)
	leaf.flip = _rng.randf_range(0.0, TAU)
	leaf.near = _rng.randf() < 0.35
	# Each leaf drifts in its own direction instead of all of them to the right.
	leaf.drift = _rng.randf_range(-LEAF_DRIFT, LEAF_DRIFT)
	leaf.shape = _rng.randi_range(0, LEAF_SHAPES.size() - 1)
	var canopy := _pick_canopy()
	if not canopy.is_empty():
		# Under a living tree: born at its crown, in that tree's own colour.
		var half := float(canopy["half"])
		leaf.x0 = float(canopy["x"]) + _rng.randf_range(-half, half)
		leaf.y = float(canopy["y"]) + _rng.randf_range(-4.0, 6.0)
		leaf.color = Color(canopy["color"])
		leaf.palette = -1
		leaf.sprite.texture = _leaf_color_texture(leaf.color, leaf.shape)
	else:
		var x := _pick_spawn_x(
			_area.position.x - LEAF_SPAWN_MARGIN,
			_area.end.x + LEAF_SPAWN_MARGIN
		)
		if is_inf(x):
			leaf.wait = RETRY_SECONDS
			leaf.sprite.visible = false
			return
		leaf.x0 = x
		if top:
			leaf.y = _area.position.y - _rng.randf_range(0.0, 40.0)
		else:
			var bottom := clampf(_ground_at(x) - 20.0, _area.position.y, _area.end.y - 20.0)
			leaf.y = _rng.randf_range(_area.position.y, maxf(bottom, _area.position.y))
		leaf.color = Color.WHITE
		leaf.palette = _rng.randi_range(0, LEAF_PALETTES.size() - 1)
		leaf.sprite.texture = _leaf_textures[leaf.shape * LEAF_PALETTES.size() + leaf.palette]
	leaf.sprite.visible = true
	leaf.x = leaf.x0
	leaf.sprite.z_index = 1 if leaf.near else 0
	leaf.sprite.modulate.a = 1.0
	_place_leaf(leaf)


func _update_leaves(delta: float) -> void:
	for leaf in _leaves:
		if leaf.wait > 0.0:
			leaf.wait -= delta
			if leaf.wait <= 0.0:
				_reset_leaf(leaf, true)
			continue
		if _out_of_area(leaf.x, leaf.y):
			_reset_leaf(leaf, true)
			continue
		if leaf.rest >= 0.0:
			leaf.rest -= delta
			if leaf.rest < 0.0:
				_reset_leaf(leaf, true)
				continue
			leaf.sprite.modulate.a = minf(1.0, leaf.rest)
			leaf.sprite.position = Vector2(leaf.x, _resting_leaf_y(leaf))
			continue
		leaf.ph += leaf.w * delta
		leaf.x0 += leaf.drift * delta
		leaf.x = leaf.x0 + sin(leaf.ph) * leaf.amp
		leaf.y += leaf.vy * (0.45 + 0.9 * absf(cos(leaf.ph))) * delta
		leaf.angle = cos(leaf.ph) * 0.75 + (0.0 if leaf.near else 0.3)
		var flip_speed := 6.0 if _hash(floori(leaf.ph / PI), floori(leaf.x0)) < 0.25 else 0.4
		leaf.flip += flip_speed * delta
		if leaf.y >= _resting_leaf_y(leaf):
			leaf.rest = _rng.randf_range(2.5, 5.0)
			leaf.angle *= 0.3
			leaf.sprite.modulate.a = 1.0
			leaf.sprite.rotation = leaf.angle
			leaf.sprite.scale = Vector2(_leaf_px, _leaf_px)
			leaf.sprite.position = Vector2(leaf.x, _resting_leaf_y(leaf))
			continue
		_place_leaf(leaf)


func _place_leaf(leaf: Leaf) -> void:
	leaf.sprite.position = Vector2(leaf.x, leaf.y)
	leaf.sprite.rotation = leaf.angle
	leaf.sprite.scale = Vector2(_leaf_px * (0.35 + 0.65 * absf(cos(leaf.flip))), _leaf_px)


## Center of a leaf lying on the surface: its bottom overlaps the grass line.
func _resting_leaf_y(leaf: Leaf) -> float:
	return _resting_y(leaf.x, leaf.sprite.texture.get_height())


func _resting_y(x: float, height: float) -> float:
	return _ground_at(x) - height * _leaf_px * 0.5 + _leaf_px


# --- Snow -------------------------------------------------------------------

func _build_snow() -> void:
	var colors := {
		"W": Color(1.0, 1.0, 1.0),
		"w": Color(227.0 / 255.0, 237.0 / 255.0, 1.0),
		"b": Color(159.0 / 255.0, 177.0 / 255.0, 230.0 / 255.0),
		"d": Color(108.0 / 255.0, 124.0 / 255.0, 184.0 / 255.0),
	}
	_snow_dots = [_make_texture(["d"], colors), _make_texture(["b"], colors)]
	_snow_flake = _make_texture(["Ww", "wb"], colors)
	for crystal in SNOW_CRYSTALS:
		_snow_crystals.append(_make_texture(crystal, colors))
	for hex in DRIFT_HEX:
		_drift_colors.append(Color(hex))
	for layer in SNOW_COUNTS.size():
		var count := int(round(SNOW_COUNTS[layer] * density))
		for i in count:
			var flake := Flake.new()
			flake.layer = layer
			flake.sprite = _new_sprite(_snow_flake, layer - 2)
			_flakes.append(flake)
			_reset_flake(flake, false)


func _reset_flake(flake: Flake, top: bool) -> void:
	var x := _pick_spawn_x(_area.position.x - 60.0, _area.end.x)
	if is_inf(x):
		flake.wait = RETRY_SECONDS
		flake.sprite.visible = false
		return
	flake.wait = 0.0
	flake.sprite.visible = true
	flake.x = x
	if top:
		flake.y = _area.position.y - _rng.randf_range(0.0, 40.0)
	else:
		var bottom := clampf(_ground_at(x), _area.position.y, _area.end.y)
		flake.y = _rng.randf_range(_area.position.y, maxf(bottom, _area.position.y))
	flake.vy = SNOW_FALL[flake.layer] * _rng.randf_range(0.75, 1.25)
	flake.sway = SNOW_SWAY[flake.layer] * _rng.randf_range(0.6, 1.2)
	flake.f = _rng.randf_range(0.8, 1.8)
	flake.ph = _rng.randf_range(0.0, TAU)
	flake.kind = _rng.randi_range(0, 2)
	flake.rest = -1.0
	if flake.layer == 0:
		flake.sprite.texture = _snow_dots[flake.kind & 1]
	elif flake.layer == 1:
		flake.sprite.texture = _snow_flake
	else:
		flake.sprite.texture = _snow_crystals[flake.kind]
	flake.sprite.modulate.a = 1.0
	_place_flake(flake)


func _update_snow(delta: float) -> void:
	_time += delta
	var wind := SNOW_WIND + 16.0 * _noise(_time * 0.3, 5)
	for flake in _flakes:
		if flake.wait > 0.0:
			flake.wait -= delta
			if flake.wait <= 0.0:
				_reset_flake(flake, true)
			continue
		if _out_of_area(flake.x, flake.y):
			_reset_flake(flake, true)
			continue
		if flake.rest >= 0.0:
			flake.rest -= delta
			if flake.rest < 0.0:
				_reset_flake(flake, true)
				continue
			flake.sprite.modulate.a = minf(1.0, flake.rest / 0.8)
			flake.sprite.position = Vector2(roundf(flake.x), roundf(_resting_flake_y(flake)))
			continue
		flake.y += flake.vy * delta
		flake.x += (wind * (0.5 + flake.layer * 0.4) + cos(_time * flake.f + flake.ph) * flake.sway) * delta
		if flake.y >= _resting_flake_y(flake):
			# Background flakes vanish on contact; the two near layers melt.
			if flake.layer == 0:
				_reset_flake(flake, true)
				continue
			flake.rest = _rng.randf_range(1.0, 2.6)
			flake.sprite.modulate.a = 1.0
			flake.sprite.position = Vector2(roundf(flake.x), roundf(_resting_flake_y(flake)))
			continue
		_place_flake(flake)
		if flake.layer == 2:
			var frame := int(floorf(_time * 3.0 + flake.ph)) & 1
			if flake.kind == 2:
				frame = 2
			flake.sprite.texture = _snow_crystals[frame]


func _place_flake(flake: Flake) -> void:
	flake.sprite.position = Vector2(roundf(flake.x), roundf(flake.y))


func _resting_flake_y(flake: Flake) -> float:
	return _ground_at(flake.x) - flake.sprite.texture.get_height() * _px * 0.5


## Snow drift along the ground, from the recipe's per-tile noise. Each tile
## draws a full-width band of 1–3 px, so two heights always meet in a block
## step (like Minecraft's snow layers), never in a diagonal.
func _draw() -> void:
	if effect != "snow" or _drift_colors.is_empty() or _share_world.is_empty():
		return
	var first := floori((_area.position.x - GROUND_STEP) / GROUND_STEP)
	var last := floori((_area.end.x + GROUND_STEP) / GROUND_STEP)
	for t in range(first, last + 1):
		var column_x := float(t) * GROUND_STEP
		var center_x := column_x + GROUND_STEP * 0.5
		if _hash(t, 21) > _share_at(center_x):
			continue
		var ground := _ground_at(center_x)
		var height := 1 + roundi(1.6 + _noise(float(t) * 1.44, 11) * 1.4 + _noise(float(t) * 4.96, 12) * 0.6)
		for r in height:
			var color: Color = _drift_colors[0] if r == height - 1 else _drift_colors[1]
			draw_rect(Rect2(column_x, ground - 1.0 - r, GROUND_STEP, 1.0), color)
		draw_rect(Rect2(column_x, ground, GROUND_STEP, 1.0), _drift_colors[2])


# --- Texture building -------------------------------------------------------

func _new_sprite(texture: Texture2D, layer_index: int) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(_px, _px)
	sprite.z_index = layer_index
	add_child(sprite)
	return sprite


## Turns a row-art sprite and its palette into an image at 1 px per art pixel.
func _make_texture(rows: Array, colors: Dictionary) -> ImageTexture:
	var width := 0
	for row in rows:
		width = maxi(width, (row as String).length())
	var image := Image.create(width, rows.size(), false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for y in rows.size():
		var row: String = rows[y]
		for x in row.length():
			var key := row[x]
			if key != "." and colors.has(key):
				image.set_pixel(x, y, colors[key])
	return ImageTexture.create_from_image(image)


# --- Deterministic hash/noise from the recipes ------------------------------

func _hash(n: int, k: int = 0) -> float:
	var value := (n + 1 + k * 7919) * 2654435761
	value &= 0xFFFFFFFF
	return float(value % 100000) / 100000.0


func _noise(x: float, s: int = 0) -> float:
	var i := floori(x)
	var f := x - i
	var u := f * f * (3.0 - 2.0 * f)
	var a := _hash(i, s)
	var b := _hash(i + 1, s)
	return a * 2.0 - 1.0 + (b - a) * 2.0 * u
