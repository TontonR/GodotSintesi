class_name SpriteFusionAmbient
extends Node2D

# ==============================================================================
# SPRITE FUSION AMBIENT VFX
# ==============================================================================
# Screen-space port of two free (MIT) effects from Sprite Fusion's VFX library:
#   - falling-leaves: https://www.spritefusion.com/pixel-art-vfx/falling-leaves
#   - snow:           https://www.spritefusion.com/pixel-art-vfx/snow
# Shapes, palettes and motion constants come from the downloaded .ts recipes
# (assets/vfx/spritefusion/). Each particle is a Sprite2D and the ambient layer
# is a CanvasLayer, so positions are screen pixels and the camera never moves
# them. `WorldGenerator.ground_y_at()` is sampled through the camera transform
# so leaves and flakes land and rest on the surface like the web recipes do.

const FADE_SECONDS := 0.5
const LEAF_DRIFT := 12.0
const LEAF_COUNT := 80
const SNOW_WIND := 14.0
const SNOW_COUNTS := [260, 150, 30]
const SNOW_FALL := [26.0, 52.0, 86.0]
const SNOW_SWAY := [8.0, 16.0, 30.0]
## Screen pixels between two ground samples, refreshed every 0.1 s.
const GROUND_STEP := 8.0
const GROUND_REFRESH_SECONDS := 0.1

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


class Flake:
	var sprite: Sprite2D
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
var _view := Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _time := 0.0
var _active := false
var _strength := -1.0
var _tween: Tween
var _world: Node
var _ground_screen := PackedFloat32Array()
var _ground_timer := 0.0

var _leaves: Array[Leaf] = []
var _leaf_textures: Array[ImageTexture] = []
var _flakes: Array[Flake] = []
var _snow_dots: Array[ImageTexture] = []
var _snow_flake: ImageTexture
var _snow_crystals: Array[ImageTexture] = []


func _ready() -> void:
	_px = pixel_scale
	_view = get_viewport_rect().size
	_rng.seed = rng_seed
	modulate.a = 0.0
	visible = false
	set_process(false)
	if effect == "leaves":
		_build_leaves()
	else:
		_build_snow()


## Sets the effect opacity from the biome blend (0 = off, 1 = full).
func set_strength(strength: float) -> void:
	strength = clampf(strength, 0.0, 1.0)
	if is_equal_approx(strength, _strength):
		return
	_strength = strength
	var enabled := strength > 0.01
	if enabled and not _active:
		_scatter()
		visible = true
		set_process(true)
	_active = enabled
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", strength, FADE_SECONDS)
	if not enabled:
		_tween.tween_callback(func() -> void:
			set_process(false)
			visible = false)


## Turns the effect fully on or off; kept for callers that only toggle.
func set_active(enabled: bool) -> void:
	set_strength(1.0 if enabled else 0.0)


func _process(delta: float) -> void:
	_ground_timer -= delta
	if _ground_timer <= 0.0:
		_ground_timer = GROUND_REFRESH_SECONDS
		_refresh_ground()
	if effect == "leaves":
		_update_leaves(delta)
	else:
		_update_snow(delta)


## Fills the screen on activation, so the weather never starts as drops.
func _scatter() -> void:
	_ground_timer = 0.0
	if effect == "leaves":
		for leaf in _leaves:
			_reset_leaf(leaf, false)
	else:
		_time = 0.0
		for flake in _flakes:
			_reset_flake(flake, false)


# --- Ground -----------------------------------------------------------------

## Samples the terrain under every screen column and stores it in screen pixels.
func _refresh_ground() -> void:
	var columns := int(ceil(_view.x / GROUND_STEP)) + 1
	if _ground_screen.size() != columns:
		_ground_screen.resize(columns)
	if _world == null:
		_world = get_tree().get_first_node_in_group("world_generator")
	if _world == null or not _world.has_method("ground_y_at"):
		# Dungeon or no generator: the bottom of the screen acts as the ground.
		_ground_screen.fill(_view.y)
		return
	var canvas := get_viewport().get_canvas_transform()
	var inverse := canvas.affine_inverse()
	for i in columns:
		var screen_x := minf(i * GROUND_STEP, _view.x)
		var world_x := (inverse * Vector2(screen_x, 0.0)).x
		var ground_world_y: float = _world.call("ground_y_at", world_x)
		var ground_screen_y := (canvas * Vector2(world_x, ground_world_y)).y
		_ground_screen[i] = clampf(ground_screen_y, 0.0, _view.y)


## Ground Y in screen pixels under `screen_x`, interpolated between samples.
func _ground_at(screen_x: float) -> float:
	var last := _ground_screen.size() - 1
	if last <= 0:
		return _view.y
	var t := clampf(screen_x / GROUND_STEP, 0.0, float(last))
	var i := mini(int(t), last - 1)
	return lerpf(_ground_screen[i], _ground_screen[i + 1], t - float(i))


# --- Leaves -----------------------------------------------------------------

func _build_leaves() -> void:
	for shape in LEAF_SHAPES:
		for palette in LEAF_PALETTES:
			_leaf_textures.append(_make_texture(shape, _leaf_colors(palette)))
	var count := int(round(LEAF_COUNT * density))
	for i in count:
		var leaf := Leaf.new()
		leaf.sprite = _new_sprite(_leaf_textures[0], 0)
		_leaves.append(leaf)
		_reset_leaf(leaf, false)


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


func _reset_leaf(leaf: Leaf, top: bool) -> void:
	leaf.x0 = _rng.randf_range(-40.0, _view.x)
	leaf.y = -_rng.randf_range(0.0, 40.0) if top else _rng.randf_range(0.0, maxf(_view.y - 20.0, 1.0))
	leaf.vy = _rng.randf_range(34.0, 56.0)
	leaf.amp = _rng.randf_range(14.0, 34.0)
	leaf.w = _rng.randf_range(1.8, 2.8)
	leaf.ph = _rng.randf_range(0.0, TAU)
	leaf.flip = _rng.randf_range(0.0, TAU)
	leaf.near = _rng.randf() < 0.35
	leaf.shape = _rng.randi_range(0, LEAF_SHAPES.size() - 1)
	leaf.palette = _rng.randi_range(0, LEAF_PALETTES.size() - 1)
	leaf.angle = 0.0
	leaf.rest = -1.0
	leaf.x = leaf.x0
	leaf.sprite.texture = _leaf_textures[leaf.shape * LEAF_PALETTES.size() + leaf.palette]
	leaf.sprite.z_index = 1 if leaf.near else 0
	leaf.sprite.modulate.a = 1.0
	_place_leaf(leaf)


func _update_leaves(delta: float) -> void:
	for leaf in _leaves:
		if leaf.rest >= 0.0:
			leaf.rest -= delta
			if leaf.rest < 0.0:
				_reset_leaf(leaf, true)
				continue
			leaf.sprite.modulate.a = minf(1.0, leaf.rest)
			leaf.sprite.position = Vector2(leaf.x, _resting_leaf_y(leaf))
			continue
		leaf.ph += leaf.w * delta
		leaf.x0 += LEAF_DRIFT * delta
		leaf.x = leaf.x0 + sin(leaf.ph) * leaf.amp
		leaf.y += leaf.vy * (0.45 + 0.9 * absf(cos(leaf.ph))) * delta
		leaf.angle = cos(leaf.ph) * 0.75 + (0.0 if leaf.near else 0.3)
		var flip_speed := 6.0 if _hash(floori(leaf.ph / PI), floori(leaf.x0)) < 0.25 else 0.4
		leaf.flip += flip_speed * delta
		if leaf.x > _view.x + 60.0:
			leaf.x0 -= _view.x + 120.0
		if leaf.y >= _resting_leaf_y(leaf):
			leaf.rest = _rng.randf_range(2.5, 5.0)
			leaf.angle *= 0.3
			leaf.sprite.modulate.a = 1.0
			leaf.sprite.rotation = leaf.angle
			leaf.sprite.scale = Vector2(_px, _px)
			leaf.sprite.position = Vector2(leaf.x, _resting_leaf_y(leaf))
			continue
		_place_leaf(leaf)


func _place_leaf(leaf: Leaf) -> void:
	leaf.sprite.position = Vector2(leaf.x, leaf.y)
	leaf.sprite.rotation = leaf.angle
	leaf.sprite.scale = Vector2(_px * (0.35 + 0.65 * absf(cos(leaf.flip))), _px)


## Center of a leaf lying on the surface: its bottom overlaps the grass line.
func _resting_leaf_y(leaf: Leaf) -> float:
	return _ground_at(leaf.x) - leaf.sprite.texture.get_height() * _px * 0.5 + _px


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
	for layer in SNOW_COUNTS.size():
		var count := int(round(SNOW_COUNTS[layer] * density))
		for i in count:
			var flake := Flake.new()
			flake.layer = layer
			flake.sprite = _new_sprite(_snow_flake, layer - 2)
			_flakes.append(flake)
			_reset_flake(flake, false)


func _reset_flake(flake: Flake, top: bool) -> void:
	flake.x = _rng.randf_range(-60.0, _view.x)
	flake.y = -_rng.randf_range(0.0, 40.0) if top else _rng.randf_range(0.0, _view.y)
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
		if flake.x > _view.x + 40.0:
			flake.x -= _view.x + 100.0
		if flake.y >= _resting_flake_y(flake):
			# Background flakes vanish on contact; the two near layers settle.
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
