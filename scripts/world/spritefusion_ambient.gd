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
# The ground is read per TILE, so resting drops snap to blocks. The drift is
# drawn per pixel on flat runs: a height change leaves a gap instead of a
# vertical or diagonal bridge. Each particle rolls the biome share of its own
# tile ONCE and uniformly: 0..1 is its own probability, so the number of
# particles follows the transition instead of clustering on the good tiles
# (T-0094). After a teleport the visible slice is re-scattered at random heights
# and tree crowns take turns, so no tree dumps a whole pile at once.
# Round 5 (T-0093): the leaves are smaller, spawned outside the view so they
# are already falling when the camera reaches them, each one drifts in its own
# direction, and living trees rain leaves tinted like their own crown.
# Round 7 (T-0096): every crown joins the rain; leaves react to the player,
# enemies and sword hitboxes, the ground litter gains life when touched and
# every removed leaf dissolves pixel by pixel instead of fading.

const LEAF_DISSOLVE: Shader = preload("res://assets/vfx/spritefusion/leaf_dissolve.gdshader")
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
const CANOPY_REFRESH_SECONDS := 0.25
## Only part of the rain is born under a crown; the rest fills the open sky.
const CANOPY_SPAWN_CHANCE := 0.35
## Leaf physics used when the enhanced VFX toggle is on (T-0096).
const LEAF_GRAVITY := 460.0
const LEAF_AIR_DRAG := 1.6
const LEAF_BOUNCE := 0.38
const LEAF_REACTION_COOLDOWN := 0.35
## Force of a bush burst (`burst_leaves`): a little stronger than the first
## T-0103 pass, so the leaves are still moving when they land (T-0107).
const BURST_FORCE := 112.0
## A sword/enemy hitbox and a running actor only disturb a few leaves, then
## wait before the next batch so one attack cannot launch the whole cloud.
const HIT_LEAF_LIMIT := 4
const RUN_LEAF_LIMIT := 2
const HIT_LEAF_COOLDOWN := 0.3
const RUN_BRUSH_COOLDOWN := 0.18
## Last seconds of a leaf's life that are spent dissolving, pixel by pixel.
const DISSOLVE_SECONDS := 0.85
## Ground litter life before it dissolves; touching it adds life.
const GROUND_LIFE_MIN := 18.0
const GROUND_LIFE_MAX := 34.0
const GROUND_LIFE_BONUS := 5.0
const SNOW_WIND := 14.0
const SNOW_COUNTS := [260, 150, 30]
const SNOW_FALL := [26.0, 52.0, 86.0]
const SNOW_SWAY := [8.0, 16.0, 30.0]
## Compressed footprints left by the player and how long they stay low.
const SNOW_PRINT_LIFE := 3.5
const SNOW_PRINT_FADE := 1.0
const SNOW_PRINT_INTERVAL := 0.12
const SNOW_PRINT_FALLOFF := 10.0
## Snow-cap height around a broad, low-frequency noise. The old per-pixel
## high-frequency noise made 1 px spikes that read as vertical lines at 4x.
const SNOW_DRIFT_BASE := 4
const SNOW_DRIFT_MIN := 3
const SNOW_DRIFT_MAX := 7
## World pixels between two ground samples: one tile, so the weather steps
## with the blocks and never draws a diagonal.
const GROUND_STEP := 16.0
const GROUND_REFRESH_SECONDS := 0.1
const OFFSCREEN_MARGIN := 80.0
## World pixels sampled around the view for the ground and biome-share lookups.
## It covers the leaf spawn margin plus their drift, so a leaf spawned off
## camera still reads the share of its own tile in a transition.
const GROUND_MARGIN := 360.0
## Hidden time after a failed share roll: about one full fall + rest cycle, so
## the visible count ends up proportional to the 0..1 share. Retrying every
## 0.25 s would refill the layer almost completely and hide the transition.
const HIDDEN_MIN := 5.0
const HIDDEN_MAX := 9.0

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
## Idle weather. With `rain` off the pool only serves `burst_leaves()`: every
## leaf waits hidden until a bush throws it. That is what the layer drawn
## behind the bushes uses (T-0107).
@export var rain: bool = true
## Z of the leaves thrown by `burst_leaves()` inside this node's own canvas.
## The behind layer keeps 0 so its burst never jumps in front of the foliage.
@export var burst_z: int = 1
## Screen pixels per art pixel. The library recipe uses 2; 1 halves the sizes.
@export_range(0.5, 2.0, 0.25) var pixel_scale: float = 1.0
## Seed for the initial scatter, so the same run reproduces the same cloud.
@export var rng_seed: int = 1

class Leaf:
	var sprite: Sprite2D
	var material: ShaderMaterial
	var wait := 0.0
	var top := true
	var x0 := 0.0
	var x := 0.0
	var y := 0.0
	var vy := 0.0
	var vx := 0.0
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
	var spin := 0.0
	var kicked := false
	var reaction_cd := 0.0


class GroundLeaf:
	var sprite: Sprite2D
	var material: ShaderMaterial
	var slot := -999999
	var base_x := 0.0
	var base_y := 0.0
	var base_rotation := 0.0
	var life := 0.0
	var dead := false
	var reaction_cd := 0.0
	var kick_x := 0.0
	var kick_y := 0.0
	var kick_vx := 0.0
	var kick_vy := 0.0
	var kick_rot := 0.0
	var kick_spin := 0.0


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


## Compressed footprint that stays in the drift after the player leaves.
class SnowPrint:
	var x := 0.0
	var half := 0.0
	var life := 0.0


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
## Biome amount × its density (0..1) for every sampled tile, used as spawn
## probability; the meadow's density is lower than the red forest's.
var _share_world := PackedFloat32Array()
## Hard snow-cover edge (0/1) for every sampled tile. It is separate from the
## particle share: the cap stays solid and only its edge is extended.
var _cover_world := PackedByteArray()
var _ground_origin := 0.0
var _ground_timer := 0.0
var _area_center := Vector2.ZERO
var _area_ready := false
var _area_jumped := false

var _leaves: Array[Leaf] = []
## Live tree crowns (x, y, tint, half width) that rain leaves of their colour.
var _canopies: Array[Dictionary] = []
var _leaf_color_cache := {}
var _canopy_timer := 0.0
## Next crown to check, so leaves take turns among trees instead of piling up.
var _canopy_cursor := 0
var _leaf_textures: Array[ImageTexture] = []
## Ground litter keyed by world slot, so moving the camera does not reset the
## life/dissolve of the leaves that stay visible. `_litter_pool` holds the
## sprites of the slots that just left the view.
var _litter: Dictionary = {}
var _litter_pool: Array[GroundLeaf] = []
var _flakes: Array[Flake] = []
var _snow_prints: Array[SnowPrint] = []
var _snow_print_timer := 0.0
## Fancy leaf motion; BiomeParticles mirrors the SettingsPanel toggle here.
var enhanced_physics := true
var _player: CharacterBody2D
var _player_timer := 0.0
var _hit_cooldown := 0.0
var _brush_cooldown := 0.0
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
	var was_active := visible and is_processing()
	visible = enabled
	set_process(enabled)
	if enabled and not was_active:
		_scatter()


func _process(delta: float) -> void:
	_time += delta
	_player_timer -= delta
	if _player_timer <= 0.0:
		_player_timer = 0.2
		_player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_ground_timer -= delta
	if _ground_timer <= 0.0:
		_ground_timer = GROUND_REFRESH_SECONDS
		_refresh_ground()
		if _area_jumped:
			# A teleport replaces the whole view at once: fill the new slice
			# at random heights instead of dropping every culled particle from
			# the top in a single wave.
			_area_jumped = false
			_scatter()
	if effect == "leaves":
		_hit_cooldown = maxf(_hit_cooldown - delta, 0.0)
		_brush_cooldown = maxf(_brush_cooldown - delta, 0.0)
		_canopy_timer -= delta
		if _canopy_timer <= 0.0:
			_canopy_timer = CANOPY_REFRESH_SECONDS
			_refresh_canopies()
		_update_leaves(delta)
		_update_litter(delta)
		_react_to_actors()
	else:
		_update_snow(delta)
		if _update_snow_prints(delta):
			queue_redraw()


## Fills the visible area on activation, so the weather never starts as drops.
## Shakes leaves off a bush the player walks through (T-0103). Reuses the pool:
## the idle leaves are re-seeded on the spot and kicked outwards, so no node is
## created and the weather keeps its count. Does nothing with the effect off.
func burst_leaves(world_position: Vector2, color: Color, amount: int, force: float = BURST_FORCE) -> void:
	if not visible or _leaves.is_empty() or amount <= 0:
		return
	var spawned := 0
	for leaf in _leaves:
		if spawned >= amount:
			break
		# Parked leaves (`wait` > 0) are eligible too: the burst-only layer
		# keeps its whole pool hidden until a bush throws it (T-0107).
		if leaf.kicked or leaf.sprite == null:
			continue
		_seed_leaf_at(leaf, world_position, color, force)
		spawned += 1


## One pooled leaf thrown from `world_position`, instead of the random scatter
## `_reset_leaf` does. Same fields, same physics as a kicked leaf.
func _seed_leaf_at(leaf, world_position: Vector2, color: Color, force: float) -> void:
	leaf.wait = 0.0
	leaf.top = false
	leaf.rest = -1.0
	leaf.kicked = true
	leaf.reaction_cd = LEAF_REACTION_COOLDOWN
	leaf.x = world_position.x + _rng.randf_range(-8.0, 8.0)
	leaf.x0 = leaf.x
	leaf.y = world_position.y + _rng.randf_range(-8.0, 8.0)
	leaf.vx = _rng.randf_range(-1.2, 1.2) * force
	leaf.vy = -_rng.randf_range(0.55, 1.2) * force
	leaf.spin = _rng.randf_range(-8.0, 8.0)
	leaf.angle = _rng.randf_range(-0.5, 0.5)
	leaf.flip = _rng.randf_range(0.0, TAU)
	leaf.near = true
	leaf.color = color
	leaf.palette = -1
	leaf.sprite.texture = _leaf_color_texture(color, leaf.shape)
	leaf.sprite.modulate.a = 1.0
	leaf.sprite.visible = true
	leaf.sprite.z_index = burst_z
	_set_dissolve(leaf.material, 0.0)
	_place_leaf(leaf)


func _scatter() -> void:
	_ground_timer = 0.0
	if _ground_world.is_empty():
		_refresh_ground()
	if effect == "leaves":
		_canopy_timer = CANOPY_REFRESH_SECONDS
		_refresh_canopies()
		if not rain:
			return
		for leaf in _leaves:
			# A teleport must fill the whole new view, not stack the rain on
			# the few crowns that happen to be visible.
			_reset_leaf(leaf, false, false)
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
	var center := _area.get_center()
	if _area_ready and center.distance_to(_area_center) > maxf(_view.x, _view.y) * 0.75:
		_area_jumped = true
	_area_center = center
	_area_ready = true


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
		_cover_world.resize(columns)
	if _world == null:
		_world = get_tree().get_first_node_in_group("world_generator")
	if _world == null or not _world.has_method("ground_y_at"):
		# Dungeon or no generator: the bottom of the view acts as the ground.
		_ground_world.fill(_area.end.y)
		_share_world.fill(1.0)
		_cover_world.fill(1)
	else:
		_ground_origin = float(first) * GROUND_STEP
		for i in columns:
			var center_x := _ground_origin + (float(i) + 0.5) * GROUND_STEP
			_ground_world[i] = float(_world.call("ground_y_at", center_x))
			_share_world[i] = _biome_share(center_x)
			var cover := 1.0 if effect == "snow" else 0.0
			if effect == "snow" and _world.has_method("ambient_share_at_world_x"):
				cover = float(_world.call("ambient_share_at_world_x", center_x, effect))
			_cover_world[i] = 1 if cover >= 0.5 else 0
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


## Biome amount × density (0..1) of the tile that contains `world_x`.
func _share_at(world_x: float) -> float:
	var last := _share_world.size() - 1
	if last < 0:
		return 1.0
	var i := clampi(floori((world_x - _ground_origin) / GROUND_STEP), 0, last)
	return _share_world[i]


## Hard snow-cover edge (0/1) of the tile that contains `world_x`.
func _cover_at(world_x: float) -> bool:
	var last := _cover_world.size() - 1
	if last < 0:
		return false
	var i := clampi(floori((world_x - _ground_origin) / GROUND_STEP), 0, last)
	return _cover_world[i] != 0


func _biome_share(world_x: float) -> float:
	var share := 1.0
	if _world.has_method("ambient_amount_at_world_x"):
		share = clampf(float(_world.call("ambient_amount_at_world_x", world_x, effect)), 0.0, 1.0)
	elif _world.has_method("ambient_share_at_world_x"):
		share = clampf(float(_world.call("ambient_share_at_world_x", world_x, effect)), 0.0, 1.0)
	if _world.has_method("ambient_density_at_world_x"):
		share *= clampf(float(_world.call("ambient_density_at_world_x", world_x, effect)), 0.0, 1.0)
	return share


## Biome tint for open-sky leaves and litter; transparent keeps the autumn
## palette, while the meadow returns its green foliage tint.
func _leaf_tint_at(world_x: float) -> Color:
	if _world == null or not _world.has_method("ambient_leaf_color_at_world_x"):
		return Color(0, 0, 0, 0)
	var tint: Color = _world.call("ambient_leaf_color_at_world_x", world_x)
	return tint if tint.a > 0.0 else Color(0, 0, 0, 0)


## Uniform X in the range, then one independent roll against the share of that
## same tile: 0..1 is the probability that this particle exists, so the density
## follows the transition evenly instead of clustering on the best tiles.
func _pick_spawn_x(min_x: float, max_x: float) -> float:
	var x := _rng.randf_range(min_x, max_x)
	return x if _rng.randf() <= _share_at(x) else INF


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
	if rain:
		_build_litter()
	var count := int(round(LEAF_COUNT * density))
	for i in count:
		var leaf := Leaf.new()
		leaf.sprite = _new_sprite(_leaf_textures[0], 0, true)
		leaf.material = leaf.sprite.material as ShaderMaterial
		_leaves.append(leaf)
		_reset_leaf(leaf, false, false)


## Litter is deterministic per world slot, so it never slides with the camera.
func _build_litter() -> void:
	var count := int(ceil((_area.size.x + 160.0) / LITTER_SPACING)) + 2
	for i in count:
		var ground := GroundLeaf.new()
		ground.sprite = _new_sprite(_leaf_textures[0], -1, true)
		ground.material = ground.sprite.material as ShaderMaterial
		ground.sprite.visible = false
		_litter_pool.append(ground)


## Litter is deterministic per world slot, so it never slides with the camera.
## Each leaf keeps its own life and dissolve state while its slot is visible;
## touching it adds `GROUND_LIFE_BONUS` and gives it a small hop.
func _place_litter() -> void:
	if effect != "leaves" or (_litter_pool.is_empty() and _litter.is_empty()):
		return
	var start_slot := floori((_area.position.x - 60.0) / LITTER_SPACING)
	var total_slots := _litter_pool.size() + _litter.size()
	var end_slot := start_slot + total_slots - 1
	# Slots that left the view return their sprite to the pool; the ones that
	# remain keep their life, dissolve and kick exactly as they were.
	for slot in _litter.keys():
		if slot < start_slot or slot > end_slot:
			var old: GroundLeaf = _litter[slot]
			old.sprite.visible = false
			_litter.erase(slot)
			_litter_pool.append(old)
	for i in total_slots:
		var slot := start_slot + i
		var x := float(slot) * LITTER_SPACING + _hash(slot, 1) * LITTER_SPACING
		var ground: GroundLeaf
		if _litter.has(slot):
			ground = _litter[slot]
		else:
			if _litter_pool.is_empty():
				break
			ground = _litter_pool.pop_back()
			_init_ground_leaf(ground, slot, x)
			_litter[slot] = ground
		if ground.dead or _hash(slot, 7) > _share_at(x):
			ground.sprite.visible = false
			continue
		ground.sprite.visible = true
		ground.sprite.position = Vector2(ground.base_x + ground.kick_x, ground.base_y + ground.kick_y)
		ground.sprite.rotation = ground.base_rotation + ground.kick_rot


func _init_ground_leaf(ground: GroundLeaf, slot: int, x: float) -> void:
	ground.slot = slot
	ground.base_x = x
	ground.dead = false
	ground.life = _rng.randf_range(GROUND_LIFE_MIN, GROUND_LIFE_MAX)
	ground.reaction_cd = 0.0
	ground.kick_x = 0.0
	ground.kick_y = 0.0
	ground.kick_vx = 0.0
	ground.kick_vy = 0.0
	ground.kick_rot = 0.0
	ground.kick_spin = 0.0
	var shape := int(_hash(slot, 2) * float(LEAF_SHAPES.size())) % LEAF_SHAPES.size()
	var tint := _leaf_tint_at(x)
	if tint.a > 0.0:
		ground.sprite.texture = _leaf_color_texture(tint, shape)
	else:
		var palette := int(_hash(slot, 4) * float(LEAF_PALETTES.size())) % LEAF_PALETTES.size()
		ground.sprite.texture = _leaf_textures[shape * LEAF_PALETTES.size() + palette]
	ground.base_y = _resting_y(x, ground.sprite.texture.get_height())
	ground.base_rotation = (_hash(slot, 5) - 0.5) * 0.6
	ground.sprite.scale = Vector2(_leaf_px, _leaf_px)
	ground.sprite.rotation = ground.base_rotation
	_set_dissolve(ground.material, 0.0)


func _update_litter(delta: float) -> void:
	for ground in _litter.values():
		if ground.slot < -1000 or ground.dead or not ground.sprite.visible:
			continue
		ground.reaction_cd = maxf(ground.reaction_cd - delta, 0.0)
		if ground.kick_y < -0.01 or absf(ground.kick_vx) > 0.01 or absf(ground.kick_vy) > 0.01:
			ground.kick_vy += LEAF_GRAVITY * delta
			ground.kick_vx *= exp(-LEAF_AIR_DRAG * delta)
			ground.kick_x += ground.kick_vx * delta
			ground.kick_y += ground.kick_vy * delta
			ground.kick_rot += ground.kick_spin * delta
			ground.kick_spin *= exp(-1.5 * delta)
			if ground.kick_y >= 0.0 and ground.kick_vy > 0.0:
				if ground.kick_vy > 80.0:
					ground.kick_y = 0.0
					ground.kick_vy = -ground.kick_vy * LEAF_BOUNCE
					ground.kick_vx *= 0.6
					ground.kick_spin *= 0.6
				else:
					# Keep the displaced position: the leaf lands where the hit left it
					# instead of snapping back to its original slot.
					ground.base_x += ground.kick_x
					ground.base_y = _resting_y(ground.base_x, ground.sprite.texture.get_height())
					ground.base_rotation += ground.kick_rot
					ground.kick_x = 0.0
					ground.kick_y = 0.0
					ground.kick_vx = 0.0
					ground.kick_vy = 0.0
					ground.kick_rot = 0.0
					ground.kick_spin = 0.0
			ground.sprite.position = Vector2(ground.base_x + ground.kick_x, ground.base_y + ground.kick_y)
			ground.sprite.rotation = ground.base_rotation + ground.kick_rot
		ground.life -= delta
		if ground.life <= 0.0:
			ground.dead = true
			ground.sprite.visible = false
			continue
		if ground.life < DISSOLVE_SECONDS:
			_set_dissolve(ground.material, 1.0 - ground.life / DISSOLVE_SECONDS)
		else:
			_set_dissolve(ground.material, 0.0)


func _set_dissolve(material: ShaderMaterial, amount: float) -> void:
	if material != null:
		material.set_shader_parameter("dissolve", clampf(amount, 0.0, 1.0))


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
	if _canopies.is_empty():
		_canopy_cursor = 0
	else:
		_canopy_cursor %= _canopies.size()


## A visible crown whose tile belongs to this biome's share, or an empty dict
## for the open-sky spawn. Every living tree takes part: crowns are visited in
## turns, so each one gets the same share of the rain instead of random piles.
func _pick_canopy() -> Dictionary:
	if _canopies.is_empty():
		return {}
	var count := _canopies.size()
	for i in count:
		var index := (_canopy_cursor + i) % count
		var canopy: Dictionary = _canopies[index]
		if _rng.randf() <= _share_at(float(canopy["x"])):
			_canopy_cursor = (index + 1) % count
			return canopy
	_canopy_cursor = (_canopy_cursor + 1) % count
	return {}


func _reset_leaf(leaf: Leaf, top: bool, canopy_spawn: bool = true) -> void:
	if not rain:
		_hide_leaf(leaf)
		return
	leaf.wait = 0.0
	leaf.top = top
	leaf.rest = -1.0
	leaf.angle = 0.0
	leaf.kicked = false
	leaf.vx = 0.0
	leaf.spin = 0.0
	leaf.reaction_cd = 0.0
	_set_dissolve(leaf.material, 0.0)
	leaf.vy = _rng.randf_range(34.0, 56.0)
	leaf.amp = _rng.randf_range(14.0, 34.0)
	leaf.w = _rng.randf_range(1.8, 2.8)
	leaf.ph = _rng.randf_range(0.0, TAU)
	leaf.flip = _rng.randf_range(0.0, TAU)
	leaf.near = _rng.randf() < 0.35
	# Each leaf drifts in its own direction instead of all of them to the right.
	leaf.drift = _rng.randf_range(-LEAF_DRIFT, LEAF_DRIFT)
	leaf.shape = _rng.randi_range(0, LEAF_SHAPES.size() - 1)
	var canopy := {}
	if canopy_spawn and _rng.randf() < CANOPY_SPAWN_CHANCE:
		canopy = _pick_canopy()
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
			leaf.wait = _rng.randf_range(HIDDEN_MIN, HIDDEN_MAX)
			leaf.sprite.visible = false
			return
		leaf.x0 = x
		if top:
			leaf.y = _area.position.y - _rng.randf_range(0.0, 40.0)
		else:
			var bottom := clampf(_ground_at(x) - 20.0, _area.position.y, _area.end.y - 20.0)
			leaf.y = _rng.randf_range(_area.position.y, maxf(bottom, _area.position.y))
		var tint := _leaf_tint_at(x)
		if tint.a > 0.0:
			leaf.color = tint
			leaf.palette = -1
			leaf.sprite.texture = _leaf_color_texture(tint, leaf.shape)
		else:
			leaf.color = Color.WHITE
			leaf.palette = _rng.randi_range(0, LEAF_PALETTES.size() - 1)
			leaf.sprite.texture = _leaf_textures[leaf.shape * LEAF_PALETTES.size() + leaf.palette]
	leaf.sprite.visible = true
	leaf.x = leaf.x0
	leaf.sprite.z_index = 1 if leaf.near else 0
	leaf.sprite.modulate.a = 1.0
	_place_leaf(leaf)


## Parks a pooled leaf of a burst-only layer (`rain` off) until
## `burst_leaves()` re-seeds it. INF keeps `_update_leaves()` from recycling it
## into rain, and the invisible sprite keeps the bursts from kicking it.
func _hide_leaf(leaf: Leaf) -> void:
	leaf.wait = INF
	leaf.top = false
	leaf.rest = -1.0
	leaf.kicked = false
	leaf.vx = 0.0
	leaf.vy = 0.0
	leaf.spin = 0.0
	leaf.reaction_cd = 0.0
	_set_dissolve(leaf.material, 0.0)
	leaf.sprite.visible = false


func _update_leaves(delta: float) -> void:
	for leaf in _leaves:
		leaf.reaction_cd = maxf(leaf.reaction_cd - delta, 0.0)
		if leaf.wait > 0.0:
			leaf.wait -= delta
			if leaf.wait <= 0.0:
				_reset_leaf(leaf, leaf.top)
			continue
		if _out_of_area(leaf.x, leaf.y):
			_reset_leaf(leaf, true)
			continue
		if leaf.kicked:
			_step_kicked_leaf(leaf, delta)
			continue
		if leaf.rest >= 0.0:
			leaf.rest -= delta
			if leaf.rest <= 0.0:
				_reset_leaf(leaf, true)
				continue
			leaf.y = _resting_leaf_y(leaf)
			_set_dissolve(leaf.material, 1.0 - leaf.rest / DISSOLVE_SECONDS)
			leaf.sprite.position = Vector2(leaf.x, leaf.y)
			continue
		leaf.ph += leaf.w * delta
		leaf.x0 += leaf.drift * delta
		if enhanced_physics:
			leaf.x0 += _noise(leaf.x0 * 0.01 + leaf.ph * 0.7, 4) * 9.0 * delta
		leaf.x = leaf.x0 + sin(leaf.ph) * leaf.amp
		leaf.y += leaf.vy * (0.45 + 0.9 * absf(cos(leaf.ph))) * delta
		leaf.angle = cos(leaf.ph) * 0.75 + (0.0 if leaf.near else 0.3)
		var flip_speed := 6.0 if _hash(floori(leaf.ph / PI), floori(leaf.x0)) < 0.25 else 0.4
		leaf.flip += flip_speed * delta
		if leaf.y >= _resting_leaf_y(leaf):
			leaf.y = _resting_leaf_y(leaf)
			leaf.rest = _rng.randf_range(2.5, 5.0)
			leaf.angle *= 0.3
			_set_dissolve(leaf.material, 0.0)
			leaf.sprite.rotation = leaf.angle
			leaf.sprite.scale = Vector2(_leaf_px, _leaf_px)
			leaf.sprite.position = Vector2(leaf.x, leaf.y)
			continue
		_place_leaf(leaf)


func _step_kicked_leaf(leaf: Leaf, delta: float) -> void:
	leaf.vy += LEAF_GRAVITY * delta
	leaf.vx *= exp(-LEAF_AIR_DRAG * delta)
	leaf.x += leaf.vx * delta
	leaf.y += leaf.vy * delta
	leaf.angle += leaf.spin * delta
	leaf.spin *= exp(-1.2 * delta)
	leaf.flip += 5.0 * delta
	var floor_y := _resting_leaf_y(leaf)
	if leaf.y >= floor_y and leaf.vy > 0.0:
		leaf.y = floor_y
		if leaf.vy > 70.0:
			leaf.vy = -leaf.vy * LEAF_BOUNCE
			leaf.vx *= 0.65
			leaf.spin *= 0.6
		else:
			leaf.kicked = false
			leaf.vx = 0.0
			leaf.vy = 0.0
			leaf.spin = 0.0
			leaf.angle *= 0.3
			leaf.rest = _rng.randf_range(2.5, 5.0)
			_set_dissolve(leaf.material, 0.0)
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


# --- Interactions (T-0096) --------------------------------------------------

## Player and enemies brush the leaves; swords and enemy attacks lift the ones
## that fall inside their world hitboxes. Runs after movement, so the boxes and
## the leaf positions are the ones drawn this frame.
func _react_to_actors() -> void:
	var enemies := get_tree().get_nodes_in_group("enemies")

	# Attacks first: their stronger lift must win over the walking nudge.
	if _player != null and _player.has_method("is_attacking_now") and bool(_player.call("is_attacking_now")):
		var player_rects: Array = _player.call("attack_rects")
		for rect in player_rects:
			_lift_rect(rect)
	for node in enemies:
		var enemy := node as Node2D
		if enemy == null or not is_instance_valid(enemy):
			continue
		if enemy.has_method("is_attacking_now") and bool(enemy.call("is_attacking_now")):
			var enemy_rects: Array = enemy.call("attack_rects")
			for rect in enemy_rects:
				_lift_rect(rect)

	if _player != null and is_instance_valid(_player):
		_react_actor(_player, true)
	for node in enemies:
		var enemy := node as Node2D
		if enemy != null and is_instance_valid(enemy):
			_react_actor(enemy, false)


func _react_actor(actor: Node2D, is_player: bool) -> void:
	if is_player and _brush_cooldown > 0.0:
		return
	var rect := _actor_rect(actor)
	var velocity := Vector2.ZERO
	if actor is CharacterBody2D:
		velocity = (actor as CharacterBody2D).velocity
	var running := (
		is_player
		and _player != null
		and _player.has_method("is_running_now")
		and bool(_player.call("is_running_now"))
	)
	var point: Vector2
	var brushed := 0
	for leaf in _leaves:
		if leaf.wait > 0.0 or not leaf.sprite.visible:
			continue
		point = Vector2(leaf.x, leaf.y)
		if rect.grow(3.0).has_point(point):
			var leaf_side := signf(velocity.x)
			if is_zero_approx(leaf_side):
				leaf_side = signf(leaf.x - rect.get_center().x)
			_kick_leaf(leaf, velocity, running, 0.0, leaf_side)
			brushed += 1
			if running and brushed >= RUN_LEAF_LIMIT:
				_brush_cooldown = RUN_BRUSH_COOLDOWN
				return
	for ground in _litter.values():
		if ground.slot < -1000 or ground.dead or not ground.sprite.visible:
			continue
		point = Vector2(ground.base_x + ground.kick_x, ground.base_y + ground.kick_y)
		if rect.grow(3.0).has_point(point):
			var ground_side := signf(velocity.x)
			if is_zero_approx(ground_side):
				ground_side = signf(ground.base_x + ground.kick_x - rect.get_center().x)
			_kick_ground(ground, velocity, running, 0.0, ground_side)
			brushed += 1
			if running and brushed >= RUN_LEAF_LIMIT:
				_brush_cooldown = RUN_BRUSH_COOLDOWN
				break


## Lifts every leaf inside a world hitbox, including the ground litter.
func _lift_rect(rect: Rect2) -> void:
	if _hit_cooldown > 0.0:
		return
	_hit_cooldown = HIT_LEAF_COOLDOWN
	# Defensive: a mirrored hitbox used to arrive with negative width and
	# spammed the debugger from the ground-litter has_point() call.
	if rect.size.x < 0.0 or rect.size.y < 0.0:
		rect = rect.abs()
	var origin_x := rect.get_center().x
	var point: Vector2
	var lifted := 0
	for leaf in _leaves:
		if leaf.wait > 0.0 or not leaf.sprite.visible:
			continue
		point = Vector2(leaf.x, leaf.y)
		if rect.has_point(point):
			var leaf_side := signf(leaf.x - origin_x)
			if is_zero_approx(leaf_side):
				leaf_side = 1.0
			_kick_leaf(leaf, Vector2.ZERO, false, 1.0, leaf_side)
			lifted += 1
			if lifted >= HIT_LEAF_LIMIT:
				break
	if lifted >= HIT_LEAF_LIMIT:
		return
	for ground in _litter.values():
		if ground.slot < -1000 or ground.dead or not ground.sprite.visible:
			continue
		point = Vector2(ground.base_x + ground.kick_x, ground.base_y + ground.kick_y)
		if rect.has_point(point):
			var ground_side := signf(ground.base_x + ground.kick_x - origin_x)
			if is_zero_approx(ground_side):
				ground_side = 1.0
			_kick_ground(ground, Vector2.ZERO, false, 1.0, ground_side)
			lifted += 1
			if lifted >= HIT_LEAF_LIMIT:
				break


func _kick_leaf(leaf: Leaf, actor_velocity: Vector2, running: bool, lift: float, side_dir: float = 0.0) -> void:
	if leaf.reaction_cd > 0.0:
		return
	leaf.reaction_cd = LEAF_REACTION_COOLDOWN
	if not enhanced_physics:
		leaf.x0 += _rng.randf_range(-2.5, 2.5)
		leaf.y -= 1.0
		_place_leaf(leaf)
		return
	leaf.kicked = true
	leaf.rest = -1.0
	var up := _rng.randf_range(65.0, 95.0)
	if running:
		up += 25.0
	if lift > 0.0:
		up += lift * 35.0
	leaf.vy = -up
	var side := side_dir
	if is_zero_approx(side):
		side = signf(actor_velocity.x)
	if is_zero_approx(side):
		side = 1.0 if _rng.randf() < 0.5 else -1.0
	var lateral := _rng.randf_range(55.0, 85.0)
	if running:
		lateral = _rng.randf_range(110.0, 150.0)
	if lift > 0.0:
		lateral = _rng.randf_range(175.0, 235.0)
	leaf.vx = side * lateral + _rng.randf_range(-18.0, 18.0)
	leaf.spin = _rng.randf_range(-9.0, 9.0)
	_set_dissolve(leaf.material, 0.0)


func _kick_ground(ground: GroundLeaf, actor_velocity: Vector2, running: bool, lift: float, side_dir: float = 0.0) -> void:
	if ground.reaction_cd > 0.0:
		return
	ground.reaction_cd = LEAF_REACTION_COOLDOWN
	# Touching a ground leaf extends its life and cancels a dissolve in progress.
	ground.life = minf(ground.life + GROUND_LIFE_BONUS, GROUND_LIFE_MAX + 20.0)
	_set_dissolve(ground.material, 0.0)
	if not enhanced_physics:
		ground.kick_rot = _rng.randf_range(-0.08, 0.08)
		return
	var up := _rng.randf_range(36.0, 56.0)
	if running:
		up += 22.0
	if lift > 0.0:
		up += lift * 22.0
	ground.kick_vy = -up
	var side := side_dir
	if is_zero_approx(side):
		side = signf(actor_velocity.x)
	if is_zero_approx(side):
		side = 1.0 if _rng.randf() < 0.5 else -1.0
	var lateral := _rng.randf_range(45.0, 65.0)
	if running:
		lateral = _rng.randf_range(75.0, 110.0)
	if lift > 0.0:
		lateral = _rng.randf_range(140.0, 190.0)
	ground.kick_vx += side * lateral + _rng.randf_range(-14.0, 14.0)
	ground.kick_spin = _rng.randf_range(-7.0, 7.0)


func _actor_rect(actor: Node2D) -> Rect2:
	if actor.has_method("hurt_rect"):
		var rect: Rect2 = actor.call("hurt_rect")
		if rect.size != Vector2.ZERO:
			return rect
	return Rect2(actor.global_position - Vector2(14.0, 28.0), Vector2(28.0, 56.0))


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
		flake.wait = _rng.randf_range(HIDDEN_MIN, HIDDEN_MAX)
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


## Low-frequency cap height: the surface undulates without the dense 1 px
## spikes that used to read as lines at the game's 4x scale.
func _snow_drift_height(world_x: float) -> int:
	var broad := _noise(world_x * 0.026, 11)
	var detail := _noise(world_x * 0.075, 12)
	return clampi(
		SNOW_DRIFT_BASE + roundi(broad * 1.8 + detail * 0.45),
		SNOW_DRIFT_MIN,
		SNOW_DRIFT_MAX
	)


## The hard biome edge is extended over flat ground, in both directions, until
## the surface height changes. The cap therefore ends on a step, not in the
## middle of a flat run; a step up or down stops the extension.
func _snow_cover_columns(first: int, last: int) -> PackedByteArray:
	var count := last - first + 1
	var cover := PackedByteArray()
	cover.resize(count)
	for i in count:
		cover[i] = 1 if _cover_at(float(first + i) + 0.5) else 0
	for i in count:
		if cover[i] == 0:
			continue
		if i == 0 or cover[i - 1] == 0:
			cover = _extend_snow_cover(cover, first, i, -1)
		if i == count - 1 or cover[i + 1] == 0:
			cover = _extend_snow_cover(cover, first, i, 1)
	return cover


func _extend_snow_cover(cover: PackedByteArray, first: int, edge_index: int, step: int) -> PackedByteArray:
	var edge_x := float(first + edge_index) + 0.5
	var edge_ground := _ground_at(edge_x)
	var i := edge_index + step
	while i >= 0 and i < cover.size():
		var x := float(first + i) + 0.5
		if not is_equal_approx(_ground_at(x), edge_ground):
			break
		cover[i] = 1
		i += step
	return cover


## Snow drift drawn one world pixel at a time, like the first version: no
## full-width tile bands. The cap sits on the stepped ground, so block edges
## end it instead of drawing a diagonal seam, and its broad noise keeps the
## top irregular without the old spikes. Its edge comes from `cover`, not from
## the particle probability, so the blanket stays solid while flakes fade.
func _draw() -> void:
	if effect != "snow" or _drift_colors.is_empty() or _share_world.is_empty() or _cover_world.is_empty():
		return
	var footprint := _snow_footprint()
	var first := floori(_area.position.x - 16.0)
	var last := ceili(_area.end.x + 16.0)
	var cover := _snow_cover_columns(first, last)
	for column in range(first, last + 1):
		if cover[column - first] == 0:
			continue
		var x := float(column)
		var center_x := x + 0.5
		var ground := roundf(_ground_at(center_x))
		var height := _snow_drift_height(center_x)
		var press := 0.0
		if not is_inf(footprint.x):
			press = _snow_press(center_x, footprint.x, footprint.y)
		if enhanced_physics:
			for mark in _snow_prints:
				var strength := clampf(mark.life / SNOW_PRINT_FADE, 0.0, 1.0)
				press = maxf(press, _snow_press(center_x, mark.x, mark.half) * strength)
		if press > 0.0:
			height = maxi(1, int(round(float(height) * (1.0 - press * 0.85))))
		for r in height:
			var color: Color = _drift_colors[0] if r == height - 1 else _drift_colors[1]
			draw_rect(Rect2(x, ground - 1.0 - float(r), 1.0, 1.0), color)
		draw_rect(Rect2(x, ground, 1.0, 1.0), _drift_colors[2])


## Updates the temporary low trail. The current footprint is immediate; marks
## left behind keep the snow compressed for a few seconds after the player
## leaves, then fade back to the normal height.
func _update_snow_prints(delta: float) -> bool:
	var had_prints := not _snow_prints.is_empty()
	for i in range(_snow_prints.size() - 1, -1, -1):
		var mark := _snow_prints[i]
		mark.life -= delta
		if mark.life <= 0.0:
			_snow_prints.remove_at(i)
	if not enhanced_physics:
		_snow_prints.clear()
		return had_prints
	var footprint := _snow_footprint()
	var active := not is_inf(footprint.x)
	if active:
		_snow_print_timer -= delta
		if _snow_print_timer <= 0.0:
			_snow_print_timer = SNOW_PRINT_INTERVAL
			var mark := SnowPrint.new()
			mark.x = footprint.x
			mark.half = footprint.y
			mark.life = SNOW_PRINT_LIFE
			_snow_prints.append(mark)
			if _snow_prints.size() > 32:
				_snow_prints.remove_at(0)
	return active or had_prints or not _snow_prints.is_empty()


func _snow_press(x: float, center: float, half: float) -> float:
	var dist := absf(x - center)
	if dist >= half + SNOW_PRINT_FALLOFF:
		return 0.0
	return clampf(1.0 - maxf(0.0, dist - half) / SNOW_PRINT_FALLOFF, 0.0, 1.0)


## Player footprint that compresses the drift while the enhanced physics option
## is on. Returns x = center (INF when inactive) and y = half width in pixels.
func _snow_footprint() -> Vector2:
	if not enhanced_physics or _player == null or not is_instance_valid(_player):
		return Vector2(INF, 0.0)
	var rect := _actor_rect(_player)
	var center := rect.get_center()
	if absf(rect.end.y - _ground_at(center.x)) > 14.0:
		return Vector2(INF, 0.0)
	return Vector2(center.x, maxf(rect.size.x * 0.5, 6.0))


# --- Texture building -------------------------------------------------------

func _new_sprite(texture: Texture2D, layer_index: int, dissolve: bool = false) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture = texture
	sprite.centered = true
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.scale = Vector2(_px, _px)
	sprite.z_index = layer_index
	if dissolve:
		var material := ShaderMaterial.new()
		material.shader = LEAF_DISSOLVE
		material.set_shader_parameter("seed", _rng.randf() * 1000.0)
		sprite.material = material
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
