extends CanvasLayer

# ==============================================================================
# PARTÍCULAS DE AMBIENTE POR BIOMA
# ==============================================================================
# Dos emisores en pantalla: hojas rojas (bosque rojo) y copos de nieve (nieve).
# El bioma se consulta al generador cada POLL_SECONDS en la X del jugador y se
# activa el emisor que toca. Al apagarlo, las partículas vivas terminan su vida.

## Cada cuánto se revisa el bioma bajo el jugador (s).
const POLL_SECONDS := 0.25

var _player: Node2D
var _world: Node
var _leaves: CPUParticles2D
var _snow: CPUParticles2D
var _elapsed := 0.0
var _last_ambient := ""
var _tweens: Dictionary = {}


func _ready() -> void:
	_player = get_parent().get_node_or_null("player") as Node2D
	var view := get_viewport().get_visible_rect().size
	_leaves = _make_emitter("leaves", _leaf_texture(), 28, 7.0, 30.0, Vector2(14.0, 25.0), view)
	_snow = _make_emitter("snow", _snow_texture(), 220, 12.0, 18.0, Vector2(10.0, 5.0), view)


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


## Enciende o apaga un emisor con un fundido corto para que no entre de golpe.
func _set_emitter(particles: CPUParticles2D, enabled: bool) -> void:
	if particles == null:
		return
	var key := particles.name
	if _tweens.has(key):
		(_tweens[key] as Tween).kill()
	if enabled:
		particles.emitting = true
	var tween := create_tween()
	_tweens[key] = tween
	tween.tween_property(particles, "modulate:a", 1.0 if enabled else 0.0, 0.4)
	if not enabled:
		tween.tween_callback(func(): particles.emitting = false)


## Emisor a pantalla completa: nace por encima del borde superior y cae.
func _make_emitter(
	node_name: String,
	texture: Texture2D,
	amount: int,
	lifetime: float,
	speed: float,
	gravity: Vector2,
	view: Vector2
) -> CPUParticles2D:
	var particles := CPUParticles2D.new()
	particles.name = node_name
	particles.texture = texture
	particles.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	particles.amount = amount
	particles.lifetime = lifetime
	particles.one_shot = false
	particles.emitting = false
	# Empieza invisible: el fundido de `_set_emitter()` lo enciende.
	particles.modulate = Color(1.0, 1.0, 1.0, 0.0)
	# Entra con la pantalla ya llena de partículas, no a gotas.
	particles.preprocess = lifetime
	particles.position = Vector2(view.x * 0.5, -6.0)
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_RECTANGLE
	particles.emission_rect_extents = Vector2(view.x * 0.6, 2.0)
	particles.direction = Vector2(0.0, 1.0)
	particles.spread = 20.0
	particles.gravity = gravity
	particles.initial_velocity_min = speed * 0.6
	particles.initial_velocity_max = speed
	particles.scale_amount_min = 0.7
	particles.scale_amount_max = 1.3
	if node_name == "leaves":
		particles.angular_velocity_min = -110.0
		particles.angular_velocity_max = 110.0
	add_child(particles)
	return particles


## Hoja de 5×5 en rombo: relleno rojo con borde más oscuro.
func _leaf_texture() -> ImageTexture:
	var image := Image.create(5, 5, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	var edge := Color(0.42, 0.07, 0.05)
	var fill := Color(0.86, 0.2, 0.16)
	for y in range(5):
		for x in range(5):
			var distance := absi(x - 2) + absi(y - 2)
			if distance <= 2:
				image.set_pixel(x, y, edge if distance == 2 else fill)
	return ImageTexture.create_from_image(image)


## Copo de 3×3 en cruz.
func _snow_texture() -> ImageTexture:
	var image := Image.create(3, 3, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	for point in [Vector2i(1, 0), Vector2i(0, 1), Vector2i(1, 1), Vector2i(2, 1), Vector2i(1, 2)]:
		image.set_pixelv(point, Color.WHITE)
	return ImageTexture.create_from_image(image)
