class_name MocoEmitter
extends Node2D
## Partículas de moco del jugador (slime). Cada nivel añade partículas y defensa
## plana; la poción y las pasivas suben el nivel, el corazón mucosil lo dobla.

## Defensa plana por nivel (el moco compacto come daño).
@export var defense_per_level: float = 0.5
## Partículas visibles por nivel.
@export var particles_per_level: int = 5

var level: int = 0

var _particles: CPUParticles2D


func _ready() -> void:
	_build_particles()
	_refresh()


func add_level(amount: int) -> void:
	level = maxi(level + amount, 0)
	_refresh()


func multiply_level(factor: float) -> void:
	level = maxi(roundi(float(level) * factor), 0)
	_refresh()


func get_level() -> int:
	return level


func get_defense() -> float:
	return float(level) * defense_per_level


func _build_particles() -> void:
	if _particles != null:
		return
	_particles = CPUParticles2D.new()
	_particles.name = "MocoParticles"
	_particles.texture = _make_drop_texture()
	_particles.lifetime = 1.2
	_particles.one_shot = false
	_particles.emitting = false
	_particles.amount = 1
	_particles.position = Vector2(0, 8)
	_particles.emission_shape = CPUParticles2D.EMISSION_SHAPE_SPHERE
	_particles.emission_sphere_radius = 8.0
	_particles.direction = Vector2(0, 1)
	_particles.spread = 40.0
	_particles.gravity = Vector2(0, 220)
	_particles.initial_velocity_min = 10.0
	_particles.initial_velocity_max = 40.0
	_particles.scale_amount_min = 0.5
	_particles.scale_amount_max = 1.2
	add_child(_particles)


## Gota verde generada por código: no hay asset de moco en el proyecto.
func _make_drop_texture() -> Texture2D:
	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([
		Color(0.45, 0.78, 0.2, 0.9),
		Color(0.28, 0.52, 0.14, 0.0),
	])
	var texture := GradientTexture2D.new()
	texture.gradient = gradient
	texture.fill = GradientTexture2D.FILL_RADIAL
	texture.fill_from = Vector2(0.5, 0.5)
	texture.fill_to = Vector2(1.0, 0.5)
	texture.width = 8
	texture.height = 8
	return texture


func _refresh() -> void:
	if _particles == null:
		return
	_particles.amount = maxi(level * particles_per_level, 1)
	_particles.emitting = level > 0
	visible = level > 0
