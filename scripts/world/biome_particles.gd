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

var _leaves: SpriteFusionAmbient
var _snow: SpriteFusionAmbient


func _ready() -> void:
	_leaves = _make_effect("leaves", "leaves", 1.0, 3)
	_snow = _make_effect("snow", "snow", 1.0, 7)


func _process(_delta: float) -> void:
	# World-space layer: children use world coordinates (T-0093 round 3).
	transform = get_viewport().get_canvas_transform()


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
