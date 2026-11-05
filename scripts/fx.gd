extends Node2D

# ==============================================================================
# EFECTOS DE COMBATE, PICKUPS Y UI
# ==============================================================================
# Partículas y textos viven en el mundo; el flash rojo, en una capa de pantalla.
# Todo se crea en código: este nodo no necesita escenas ni texturas externas.
# Los demás sistemas lo buscan en el grupo "fx".

var _camera: Camera2D
var _shake_time := 0.0
var _shake_duration := 0.01
var _shake_strength := 0.0
var _flash: ColorRect
var _flash_tween: Tween
var _text_layer: CanvasLayer
var _dot_texture: ImageTexture
var _streak_texture: ImageTexture


func _ready() -> void:
	add_to_group("fx")
	_dot_texture = _solid_texture(2)
	_streak_texture = _make_streak_texture()
	_build_layers()


func _process(delta: float) -> void:
	if _shake_time <= 0.0:
		return
	_shake_time = maxf(_shake_time - delta, 0.0)
	var camera := _get_camera()
	if camera == null:
		return
	if _shake_time <= 0.0:
		camera.offset = Vector2.ZERO
		_shake_strength = 0.0
		return
	var amount := _shake_strength * (_shake_time / _shake_duration)
	camera.offset = Vector2(randf_range(-amount, amount), randf_range(-amount, amount))


# ==============================================================================
# API PARA EL RESTO DEL JUEGO
# ==============================================================================

## Golpe a un enemigo: chispas y número de daño. Si es crítico, más chispas
## doradas, número más grande y sacudida corta.
func enemy_hit(world_position: Vector2, damage: float, critical: bool = false) -> void:
	if critical:
		_burst(world_position, Color(1.0, 0.8, 0.32), 14, 140.0, 0.45, 1.2, 280.0, 4.0)
		_burst(world_position, Color(1.0, 1.0, 0.9), 6, 90.0, 0.25, 0.8, 120.0, 2.0)
		shake(1.0, 0.06)
		if damage >= 1.0:
			_number(world_position + Vector2(0.0, -10.0), str(roundi(damage)), Color(1.0, 0.78, 0.28), 12)
		return
	_burst(world_position, Color(1.0, 0.85, 0.55), 8, 90.0, 0.35, 0.9)
	if damage >= 1.0:
		_number(world_position + Vector2(0.0, -10.0), str(roundi(damage)), Color(1.0, 0.93, 0.72))


## Muerte de un enemigo: reventón de sangre en capas (chorro oscuro con
## estela, salpicadura roja, niebla y chispas blancas) y golpe de cámara.
func enemy_death(world_position: Vector2) -> void:
	_burst(world_position, Color(0.52, 0.04, 0.06), 32, 300.0, 0.95, 1.7, 680.0, 7.0, 180.0, true)
	_burst(world_position, Color(0.85, 0.12, 0.1), 26, 190.0, 0.7, 1.4, 380.0, 10.0)
	_burst(world_position, Color(0.62, 0.06, 0.08, 0.55), 14, 55.0, 0.55, 2.6, 40.0, 6.0)
	_burst(world_position, Color(1.0, 0.94, 0.88), 8, 120.0, 0.3, 0.7, 260.0, 4.0)
	shake(1.4, 0.12)


## Daño al jugador: número rojo, chispas, sacudida de cámara y flash.
func player_hit(world_position: Vector2, damage: float) -> void:
	_burst(world_position, Color(1.0, 0.3, 0.28), 10, 110.0, 0.4, 1.0)
	_number(world_position, str(-roundi(damage)), Color(1.0, 0.42, 0.38))
	shake(2.5, 0.18)
	damage_flash()


## Moneda recogida: chispas doradas y "+1".
func coin_pickup(world_position: Vector2) -> void:
	_burst(world_position, Color(1.0, 0.85, 0.3), 10, 80.0, 0.45, 0.9)
	_number(world_position + Vector2(0.0, -8.0), "+1", Color(1.0, 0.88, 0.35))


## Objeto recogido: chispas verdes.
func item_pickup(world_position: Vector2) -> void:
	_burst(world_position, Color(0.55, 1.0, 0.65), 14, 70.0, 0.6, 1.0)


## Curación: chispas verdes y "+N".
func heal(world_position: Vector2, amount: int) -> void:
	_burst(world_position, Color(0.45, 1.0, 0.55), 12, 60.0, 0.5, 1.0)
	if amount > 0:
		_number(world_position, "+%d" % amount, Color(0.55, 1.0, 0.6))


## Polvo (saltar, aterrizar, correr). `strength` escala tamaño y velocidad.
## El llamador pasa el punto de los pies: la nube se abre pegada al suelo.
## El color sale del césped del bioma (aclarado) para que se lea como tierra local.
func dust(world_position: Vector2, amount: int = 4, strength: float = 1.0) -> void:
	var color := Color(0.84, 0.8, 0.72, 0.75)
	var biome := _biome_at(world_position.x)
	if biome:
		color = biome.grass_color.lightened(0.35)
		color.a = 0.75
	_burst(world_position, color, amount, 38.0 * strength, 0.42, 1.1 * strength, 240.0, 4.0)


## Parry: chispas blancas y doradas, aviso flotante, sacudida corta y destello.
func parry(world_position: Vector2) -> void:
	_burst(world_position, Color(1.0, 1.0, 0.92), 16, 180.0, 0.35, 1.2, 60.0, 5.0)
	_burst(world_position, Color(1.0, 0.86, 0.42), 10, 120.0, 0.5, 0.9, 240.0, 4.0)
	_number(world_position + Vector2(0.0, -12.0), "¡PARRY!", Color(1.0, 0.95, 0.65))
	shake(1.2, 0.1)
	damage_flash(Color(1.0, 0.95, 0.72), 0.16)


## Ventana de parry abierta: chispas pequeñas doradas, sin texto ni sacudida.
func parry_ready(world_position: Vector2) -> void:
	_burst(world_position, Color(1.0, 0.9, 0.55, 0.9), 4, 45.0, 0.22, 0.6, 0.0, 2.0, 70.0)


## Sacude la cámara sin tocar su posición: solo el offset, con caída gradual.
func shake(strength: float, duration: float) -> void:
	if _get_camera() == null:
		return
	_shake_strength = maxf(_shake_strength, strength)
	_shake_duration = maxf(duration, 0.01)
	_shake_time = _shake_duration


## Flash a pantalla completa (por debajo del HUD). Por defecto, rojo de daño.
func damage_flash(color: Color = Color(1.0, 0.12, 0.12), alpha: float = 0.3) -> void:
	if _flash == null:
		return
	if _flash_tween and _flash_tween.is_valid():
		_flash_tween.kill()
	_flash.color = color
	_flash.color.a = 0.0
	_flash_tween = create_tween()
	_flash_tween.tween_property(_flash, "color:a", alpha, 0.04)
	_flash_tween.tween_property(_flash, "color:a", 0.0, 0.28)


# ==============================================================================
# CONSTRUCCIÓN
# ==============================================================================

## Capa de números (8, bajo el HUD) y capa del flash (9, también bajo el HUD).
func _build_layers() -> void:
	_text_layer = CanvasLayer.new()
	_text_layer.name = "DamageNumbers"
	_text_layer.layer = 8
	add_child(_text_layer)

	var flash_layer := CanvasLayer.new()
	flash_layer.name = "DamageFlash"
	flash_layer.layer = 9
	add_child(flash_layer)
	var root := Control.new()
	root.name = "FlashRoot"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	flash_layer.add_child(root)
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_flash = ColorRect.new()
	_flash.name = "Color"
	_flash.color = Color(1.0, 0.12, 0.12, 0.0)
	_flash.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(_flash)
	_flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)


## Número flotante: sube y se desvanece. Se coloca en coordenadas de pantalla
## para que el zoom de la cámara no cambie su tamaño.
func _number(world_position: Vector2, text: String, color: Color, font_size: int = 9) -> void:
	if _text_layer == null:
		return
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color(0.0, 0.0, 0.0, 1.0))
	label.add_theme_constant_override("outline_size", 3)
	_text_layer.add_child(label)
	label.position = (get_viewport().get_canvas_transform() * world_position).round()
	var target := label.position + Vector2(randf_range(-3.0, 3.0), -18.0)
	var tween := label.create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position", target, 0.65)
	tween.tween_property(label, "modulate:a", 0.0, 0.45).set_delay(0.2)
	tween.finished.connect(label.queue_free)


## Estallido de partículas de un solo uso.
func _burst(
	world_position: Vector2,
	color: Color,
	amount: int,
	speed: float,
	lifetime: float,
	strength: float,
	gravity: float = 320.0,
	radius: float = 3.0,
	spread: float = 180.0,
	align_to_velocity: bool = false
) -> void:
	var particles := CPUParticles2D.new()
	particles.texture = _streak_texture if align_to_velocity else _dot_texture
	particles.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	particles.one_shot = true
	particles.emitting = false
	particles.amount = maxi(amount, 1)
	particles.lifetime = lifetime
	particles.explosiveness = 1.0
	particles.direction = Vector2.UP
	particles.spread = spread
	particles.gravity = Vector2(0.0, gravity)
	particles.initial_velocity_min = speed * 0.45
	particles.initial_velocity_max = speed
	particles.scale_amount_min = 0.5 * strength
	particles.scale_amount_max = 1.0 * strength
	particles.color = color
	particles.particle_flag_align_y = align_to_velocity
	particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	particles.emission_sphere_radius = radius
	add_child(particles)
	particles.global_position = world_position
	particles.emitting = true
	get_tree().create_timer(lifetime + 0.3).timeout.connect(particles.queue_free)


## Píxel blanco reutilizado por todas las partículas (se tiñen con `color`).
func _solid_texture(size: int) -> ImageTexture:
	var image := Image.create(size, size, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)


## Gota alargada (2×5) para la sangre: con `particle_flag_align_y` se estira en
## la dirección del chorro y se lee como salpicadura, no como chispa cuadrada.
func _make_streak_texture() -> ImageTexture:
	var image := Image.create(2, 5, false, Image.FORMAT_RGBA8)
	image.fill(Color.WHITE)
	return ImageTexture.create_from_image(image)


## Bioma bajo una X del mundo; null si el generador aún no existe.
func _biome_at(world_x: float) -> Biome:
	var world := get_tree().get_first_node_in_group("world_generator")
	if world == null or not world.has_method("biome_at_world_x"):
		return null
	return world.call("biome_at_world_x", world_x) as Biome


func _get_camera() -> Camera2D:
	if _camera and is_instance_valid(_camera):
		return _camera
	_camera = get_viewport().get_camera_2d() as Camera2D
	return _camera
