extends CanvasLayer

# ==============================================================================
# AMBIENT PARTICLES PER BIOME
# ==============================================================================
# Two on-screen emitters: autumn leaves (red forest) and snow (snow biome), both
# ported from Sprite Fusion's free MIT VFX library (T-0093). The generator is
# polled every POLL_SECONDS and gives each effect the share of the biome blend
# around the player, so they crossfade over ~64 tiles instead of popping.

## How often the biome under the player is checked (s).
const POLL_SECONDS := 0.25

var _player: Node2D
var _world: Node
var _leaves: SpriteFusionAmbient
var _snow: SpriteFusionAmbient
var _elapsed := 0.0


func _ready() -> void:
	_player = get_parent().get_node_or_null("player") as Node2D
	_leaves = _make_effect("leaves", "leaves", 1.0, 3)
	_snow = _make_effect("snow", "snow", 1.0, 7)


func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed < POLL_SECONDS:
		return
	_elapsed = 0.0
	if _world == null:
		_world = get_tree().get_first_node_in_group("world_generator")
	var leaves := 0.0
	var snow := 0.0
	if _player and _world and _world.has_method("ambient_weight_at_world_x"):
		var world_x: float = _player.global_position.x
		leaves = float(_world.call("ambient_weight_at_world_x", world_x, "leaves"))
		snow = float(_world.call("ambient_weight_at_world_x", world_x, "snow"))
	_set_emitter(_leaves, leaves)
	_set_emitter(_snow, snow)


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


## Sets the blend share; the effect fades its own alpha over 0.5 s.
func _set_emitter(ambient: SpriteFusionAmbient, strength: float) -> void:
	if ambient == null:
		return
	ambient.set_strength(strength)
