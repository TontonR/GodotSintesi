extends CanvasLayer

# ==============================================================================
# AMBIENT PARTICLES PER BIOME
# ==============================================================================
# Two world-space emitters: autumn leaves (red forest) and snow (snow biome),
# both ported from Sprite Fusion's free MIT VFX library (T-0093). The layer
# copies the camera transform every frame, so the effects scroll with the world
# instead of following the player. There is no alpha crossfade: each emitter
# asks WorldGenerator.ambient_share_at_world_x() for the biome share of every
# visible tile and only spawns a particle there with that probability, so the
# weather thins out block by block through the terrain transition.

const VFX_SETTINGS_SCRIPT := preload("res://scripts/vfx_settings.gd")

var _leaves: SpriteFusionAmbient
var _snow: SpriteFusionAmbient
var _vfx_settings: Node


func _ready() -> void:
	_leaves = _make_effect("leaves", "leaves", 1.0, 3)
	_snow = _make_effect("snow", "snow", 1.0, 7)
	if _get_vfx_settings() != null:
		_vfx_settings.connect("changed", _apply_vfx_settings)
	_apply_vfx_settings()


## Live toggles from SettingsPanel (T-0096): leaves can be removed entirely and
## the fancy motion (including the snow footprint compression) can be turned
## off without hiding the snow.
func _apply_vfx_settings() -> void:
	var vfx := _get_vfx_settings()
	if vfx == null:
		return
	var enhanced := bool(vfx.get("enhanced_vfx_physics"))
	_leaves.enhanced_physics = enhanced
	_snow.enhanced_physics = enhanced
	_snow.queue_redraw()
	_leaves.set_active(bool(vfx.get("leaves_enabled")))


func _process(_delta: float) -> void:
	# World-space layer: children use world coordinates (T-0093 round 3).
	transform = get_viewport().get_canvas_transform()


## Resolves the settings singleton at runtime instead of relying on the autoload
## identifier. The fallback keeps the toggles working while the editor has not
## reloaded an externally edited `project.godot` (T-0096).
func _get_vfx_settings() -> Node:
	if is_instance_valid(_vfx_settings):
		return _vfx_settings
	var tree := get_tree()
	if tree == null:
		return null
	_vfx_settings = tree.root.get_node_or_null("VfxSettings")
	if _vfx_settings == null:
		_vfx_settings = VFX_SETTINGS_SCRIPT.new()
		_vfx_settings.name = "VfxSettings"
		tree.root.add_child(_vfx_settings)
	return _vfx_settings


## Creates one ambient effect as a child of this CanvasLayer.
func _make_effect(node_name: String, kind: String, density: float, seed: int) -> SpriteFusionAmbient:
	var ambient := SpriteFusionAmbient.new()
	ambient.name = node_name
	ambient.effect = kind
	ambient.density = density
	ambient.pixel_scale = 1.0
	ambient.rng_seed = seed
	add_child(ambient)
	return ambient
