class_name EnemyBase
extends CharacterBody2D

@export_group("Basic Stats")
@export var max_health: float = 10.0
@export var base_attack: float = 5.0
@export var speed_movement: float = 50.0
@export var attack_cooldown: float = 2.0
@export var uses_gravity: bool = true

@export_group("Nodes")
@export var sprite: AnimatedSprite2D
@export var detection_area: Area2D
@export var attack_range: Area2D
@export var flip_pivot: Node2D ## Si se asigna, se voltea entero en vez de solo el sprite

@export_group("Feedback")
@export var hit_flash_color: Color = Color(1.0, 0.2, 0.2)
@export var hit_flash_time: float = 0.15

@export_group("Blood")
@export var blood_enabled: bool = true
@export var blood_color: Color = Color(0.78, 0.1, 0.12)
@export_range(0.0, 1.0) var low_health_threshold: float = 0.35 ## % de vida a partir del cual sangra
@export var blood_offset: Vector2 = Vector2(0, -6) ## Desde dónde salen las gotas
@export var blood_amount: int = 4 ## Gotas simultáneas del goteo

@export_group("Animations")
@export var idle_animation: StringName = &"idle"
@export var move_animation: StringName = &"walk"
@export var attack_animation: StringName = &"attack"
@export var sprite_faces_right: bool = true

@export_group("Attack")
@export var attack_impact_delay: float = 0.5
@export var attack_duration: float = 1.0

@export_group("Loot")
@export var coin_scene: PackedScene = preload("res://scenes/collectables/coin.tscn")
@export var coins_on_death: int = 3
@export var coin_drop_spread: float = 14.0
@export var coin_drop_y: float = 8.0

var health: float = 0.0
var gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

var _player: CharacterBody2D = null
var _player_in_attack_range: bool = false
var _is_attacking: bool = false
var _can_attack: bool = true
var _is_dead: bool = false
var _is_facing_left: bool = false
var _attack_range_offset_x: float = 0.0
var _attack_timer: Timer
var _hit_tween: Tween
var _blood_drip: CPUParticles2D
var _blood_burst: CPUParticles2D


func _ready() -> void:
	health = max_health

	if blood_enabled:
		_blood_drip = _create_blood_emitter(false)
		_blood_burst = _create_blood_emitter(true)

	_attack_timer = Timer.new()
	_attack_timer.one_shot = true
	_attack_timer.wait_time = attack_cooldown
	_attack_timer.timeout.connect(func(): _can_attack = true)
	add_child(_attack_timer)

	if attack_range:
		_attack_range_offset_x = absf(attack_range.position.x)
		attack_range.body_entered.connect(_on_attack_range_body_entered)
		attack_range.body_exited.connect(_on_attack_range_body_exited)

	if detection_area:
		detection_area.body_entered.connect(_on_detection_area_body_entered)
		detection_area.body_exited.connect(_on_detection_area_body_exited)


func _physics_process(delta: float) -> void:
	if _is_dead:
		return

	if uses_gravity and not is_on_floor():
		velocity.y += gravity * delta

	if _is_attacking:
		velocity.x = move_toward(velocity.x, 0.0, speed_movement)
	else:
		_update_behavior(delta)

	move_and_slide()


func _update_behavior(_delta: float) -> void:
	if not is_instance_valid(_player):
		velocity.x = move_toward(velocity.x, 0.0, speed_movement)
		_play_animation(idle_animation)
		return

	var dist_x := _player.global_position.x - global_position.x
	if absf(dist_x) > 5.0:
		_set_facing_direction(dist_x < 0.0)

	if _player_in_attack_range:
		velocity.x = 0.0
		if _can_attack:
			_start_attack()
		else:
			_play_animation(idle_animation)
	else:
		_chase(dist_x)


func _chase(dist_x: float) -> void:
	velocity.x = signf(dist_x) * speed_movement
	_play_animation(move_animation)


func _start_attack() -> void:
	_is_attacking = true
	_can_attack = false
	_attack_timer.start(attack_cooldown)
	_play_animation(attack_animation, true)

	await get_tree().create_timer(attack_impact_delay).timeout
	if _is_dead:
		return
	_perform_attack_hit()

	var remaining := attack_duration - attack_impact_delay
	if remaining > 0.0:
		await get_tree().create_timer(remaining).timeout
	if _is_dead:
		return

	_is_attacking = false


func _perform_attack_hit() -> void:
	if not attack_range:
		return
	for body in attack_range.get_overlapping_bodies():
		if _is_valid_target(body):
			_deal_damage_to(body)


func _deal_damage_to(body: Node2D) -> void:
	if body.has_method("take_damage_from"):
		body.take_damage_from(base_attack, global_position)
	else:
		body.take_damage(base_attack)


func _is_valid_target(body: Node2D) -> bool:
	return body != self and body.has_method("take_damage")


# ==============================================================================
# DAÑO Y MUERTE
# ==============================================================================
func take_damage(amount: float) -> void:
	if _is_dead:
		return
	health = maxf(health - amount, 0.0)
	if health <= 0.0:
		_die()
	else:
		_flash_hit()
		_update_blood()


func _die() -> void:
	_is_dead = true
	_is_attacking = false
	_can_attack = false
	_player = null
	_player_in_attack_range = false
	velocity = Vector2.ZERO
	if _blood_drip:
		_blood_drip.emitting = false
	if sprite:
		sprite.stop()
	if detection_area:
		detection_area.set_deferred("monitoring", false)
	if attack_range:
		attack_range.set_deferred("monitoring", false)
	_drop_coins()
	_on_death()


## Hook: los hijos lo sobrescriben para animaciones de muerte.
func _on_death() -> void:
	queue_free()


func _drop_coins() -> void:
	if not coin_scene or coins_on_death <= 0:
		return
	var parent := get_parent()
	if parent == null:
		return
	for i in coins_on_death:
		var coin := coin_scene.instantiate() as Node2D
		coin.position = position + Vector2(randf_range(-coin_drop_spread, coin_drop_spread), coin_drop_y)
		parent.add_child.call_deferred(coin)


# ==============================================================================
# FEEDBACK: PARPADEO Y SANGRE
# ==============================================================================
func _flash_hit() -> void:
	if not sprite:
		return
	if _hit_tween:
		_hit_tween.kill()
	sprite.modulate = hit_flash_color
	_hit_tween = create_tween()
	_hit_tween.tween_property(sprite, "modulate", Color.WHITE, hit_flash_time)


## Con poca vida gotea sangre de forma continua, y suelta un chorrito extra al recibir un golpe.
func _update_blood() -> void:
	if not blood_enabled:
		return
	var low := health <= max_health * low_health_threshold
	_blood_drip.emitting = low
	if low:
		_blood_burst.restart()


## Partículas cuadradas de 2px, sin suavizado, que caen y se desvanecen al final.
func _create_blood_emitter(burst: bool) -> CPUParticles2D:
	var img := Image.create(1, 1, false, Image.FORMAT_RGBA8)
	img.fill(Color.WHITE)

	var gradient := Gradient.new()
	gradient.colors = PackedColorArray([blood_color, blood_color, Color(blood_color, 0.0)])
	gradient.offsets = PackedFloat32Array([0.0, 0.7, 1.0])

	var p := CPUParticles2D.new()
	p.texture = ImageTexture.create_from_image(img)
	p.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	p.color_ramp = gradient
	p.position = blood_offset
	p.local_coords = false ## Las gotas caen en el mundo aunque el enemigo se mueva
	p.emitting = false
	p.one_shot = burst
	p.amount = 6 if burst else blood_amount
	p.explosiveness = 1.0 if burst else 0.0
	p.lifetime = 0.7
	p.lifetime_randomness = 0.4
	p.direction = Vector2.UP
	p.spread = 70.0
	p.initial_velocity_min = 20.0 if burst else 8.0
	p.initial_velocity_max = 80.0 if burst else 35.0
	p.gravity = Vector2(0.0, 280.0)
	p.scale_amount_min = 2.0
	p.scale_amount_max = 2.0
	add_child(p)
	return p


# ==============================================================================
# ORIENTACIÓN Y ANIMACIÓN
# ==============================================================================
func _set_facing_direction(look_left: bool) -> void:
	if _is_facing_left == look_left:
		return
	_is_facing_left = look_left

	var flipped := look_left if sprite_faces_right else not look_left
	if flip_pivot:
		flip_pivot.scale.x = -1.0 if flipped else 1.0
		return
	if sprite:
		sprite.flip_h = flipped
	if attack_range:
		attack_range.position.x = - _attack_range_offset_x if look_left else _attack_range_offset_x


func _play_animation(anim_name: StringName, force: bool = false) -> void:
	if _is_attacking and not force:
		return
	if not sprite or not sprite.sprite_frames:
		return
	if not sprite.sprite_frames.has_animation(anim_name):
		return
	if sprite.animation != anim_name or force:
		sprite.play(anim_name)


# ==============================================================================
# SEÑALES
# ==============================================================================
func _on_detection_area_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player = body as CharacterBody2D


func _on_detection_area_body_exited(body: Node2D) -> void:
	if body == _player:
		_player = null
		_player_in_attack_range = false


func _on_attack_range_body_entered(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_attack_range = true


func _on_attack_range_body_exited(body: Node2D) -> void:
	if _is_valid_target(body):
		_player_in_attack_range = false