extends CanvasLayer

# ==============================================================================
# AMBIENT PARTICLES PER BIOME
# ==============================================================================
# Two on-screen emitters: autumn leaves (red forest) and snow (snow biome), both
# ported from Sprite Fusion's free MIT VFX library (T-0093). The generator is
# polled for the biome every POLL_SECONDS at the player's X and the matching
# emitter is turned on. When it is turned off, the effect fades out.

## How often the biome under the player is checked (s).
const POLL_SECONDS := 0.25

var _player: Node2D
var _world: Node
var _leaves: SpriteFusionAmbient
var _snow: SpriteFusionAmbient
var _elapsed := 0.0
var _last_ambient := ""


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
	var ambient := ""
	if _player and _world and _world.has_method("biome_at_world_x"):
		var biome: Biome = _world.call("biome_at_world_x", _player.global_position.x)
		if biome:
			ambient = biome.ambient
	if ambient == _last_ambient:
		return
	_last_ambient = ambient
	_set_emitter(_leaves, ambient == "leaves")
	_set_emitter(_snow, ambient == "snow")


## Creates one ambient effect as a child of this CanvasLayer.
func _make_effect(node_name: String, kind: String, density: float, seed: int) -> SpriteFusionAmbient:
	var ambient := SpriteFusionAmbient.new()
	ambient.name = node_name
	ambient.effect = kind
	ambient.density = density
	ambient.rng_seed = seed
	add_child(ambient)
	return ambient


## Turns an emitter on or off; the effect fades itself over 0.4 s.
func _set_emitter(ambient: SpriteFusionAmbient, enabled: bool) -> void:
	if ambient == null:
		return
	ambient.set_active(enabled)
