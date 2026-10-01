extends CharacterBody2D

# Velocidad máxima horizontal en píxeles por segundo - bajada bastante
@export var move_speed: float = 130.0
# Aceleración al acelerar / frenar (suaviza el movimiento) - ajustada a nueva velocidad
@export var acceleration: float = 750.0
@export var friction: float = 1000.0
# Salto y gravedad - salto bastante más bajo
@export var jump_velocity: float = -340.0
@export var gravity: float = 1400.0
# Vida
@export var max_health: int = 100
var health: int
# Al caer la gravedad es mayor: el salto se siente más ágil
@export var fall_gravity_multiplier: float = 1.6
# Margen para saltar justo después de dejar el suelo
@export var coyote_time: float = 0.1
# Margen para registrar el salto pulsado un poco antes de tocar suelo
@export var jump_buffer_time: float = 0.12

@onready var sprite_pivot: Node2D = $SpritePivot
@onready var animated_sprite: AnimatedSprite2D = $SpritePivot/AnimatedSprite2D
@onready var attack_hitboxes: Array[Area2D] = [$AttackHitbox1, $AttackHitbox2, $AttackHitbox3]
@onready var hitbox_shapes: Array[CollisionShape2D] = [
	$AttackHitbox1/CollisionShape2D,
	$AttackHitbox2/CollisionShape2D,
	$AttackHitbox3/CollisionShape2D,
]
@onready var hitbox_debug: Node2D = $HitboxDebug
var health_bar: ProgressBar
var health_label: Label

# Daño que inflige el golpe cuando la hitbox toca a un enemigo
@export var hitbox_damage: int = 20
# Dibuja la hitbox del ataque en pantalla (para ajustar en pruebas)
@export var show_attack_hitbox: bool = true
# Posición total de cada hitbox definida en el editor (se espejea al girar)
var _hitbox_offsets: Array[Vector2] = []
# Offset de cada forma dentro de su Area2D (para que el espejo sea correcto)
var _hitbox_shape_offsets: Array[Vector2] = []
# Índice de la hitbox activa (0=attack_1, 1=attack_2, 2=attack_3)
var _active_hitbox: int = 0
# Cuerpos/áreas ya golpeados en el golpe actual (evita daño repetido)
var _hit_targets: Array = []

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_was_pressed: bool = false
var _facing_right: bool = true
var _is_attacking: bool = false
var _is_guarding: bool = false
var _is_dead: bool = false
var _combo_index: int = 0
var _combo_timer: float = 0.0
@export var combo_window: float = 0.35
const _ATTACK_ANIMS: Array[String] = ["attack_1", "attack_2", "attack_3"]

func _ready() -> void:
	health = max_health
	animated_sprite.animation_finished.connect(_on_attack_finished)
	for i in attack_hitboxes.size():
		_hitbox_offsets.append(attack_hitboxes[i].position + hitbox_shapes[i].position)
		_hitbox_shape_offsets.append(hitbox_shapes[i].position)
		attack_hitboxes[i].set_deferred("monitoring", false)
		attack_hitboxes[i].body_entered.connect(_on_attack_hitbox_body_entered)
		attack_hitboxes[i].area_entered.connect(_on_attack_hitbox_area_entered)
	if hitbox_debug:
		hitbox_debug.clear()
	_ensure_health_ui()
	_update_health_ui()

func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	_register_hit(body)

func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	_register_hit(area)

func _register_hit(target: Node) -> void:
	if not _is_attacking:
		return
	if target == self or _hit_targets.has(target):
		return
	_hit_targets.append(target)
	_deal_damage(target)

func _deal_damage(target: Node) -> void:
	if target.has_method("take_damage"):
		target.take_damage(hitbox_damage)
	else:
		var parent := target.get_parent()
		if parent and parent.has_method("take_damage"):
			parent.take_damage(hitbox_damage)

func set_hitbox_active(active: bool) -> void:
	# set_deferred evita el error de cambiar monitoring durante un flush de física
	for i in attack_hitboxes.size():
		attack_hitboxes[i].set_deferred("monitoring", active and i == _active_hitbox)
	if active:
		_hit_targets.clear()

func _update_hitbox_debug() -> void:
	# Dibuja la hitbox activa mientras dura el ataque (solo para pruebas)
	if hitbox_debug == null:
		return
	if not show_attack_hitbox or not _is_attacking:
		hitbox_debug.clear()
		return
	var rect_shape := hitbox_shapes[_active_hitbox].shape as RectangleShape2D
	if rect_shape == null:
		hitbox_debug.clear()
		return
	var size: Vector2 = rect_shape.size
	var center: Vector2 = attack_hitboxes[_active_hitbox].position + hitbox_shapes[_active_hitbox].position
	hitbox_debug.set_rect(Rect2(center - size * 0.5, size))

func take_damage(amount: int) -> void:
	# Sin origen conocido se asume que viene de frente
	_apply_damage(amount, true)

func take_damage_from(amount: int, attacker_position: Vector2) -> void:
	_apply_damage(amount, is_attack_from_front(attacker_position))

func is_attack_from_front(attacker_position: Vector2) -> bool:
	if is_equal_approx(attacker_position.x, global_position.x):
		return true
	return (attacker_position.x > global_position.x) == _facing_right

func _apply_damage(amount: int, from_front: bool) -> void:
	if _is_dead:
		return
	if _is_guarding and from_front:
		return
	health = maxi(health - amount, 0)
	_update_health_ui()
	if health <= 0:
		_die()

func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	_update_health_ui()

func _ensure_health_ui() -> void:
	# Crea el HUD si no existe (evita que el editor lo borre)
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	health_bar = root.get_node_or_null("UILayer/HealthBar") as ProgressBar
	if health_bar == null:
		health_bar = get_node_or_null("../UILayer/HealthBar") as ProgressBar
	if health_bar == null and root:
		var ui_layer = root.get_node_or_null("UILayer")
		if ui_layer == null:
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UILayer"
			ui_layer.layer = 10
			root.add_child(ui_layer)
		var bg = StyleBoxFlat.new()
		bg.bg_color = Color(0.176, 0.176, 0.176, 1)
		bg.corner_radius_top_left = 6
		bg.corner_radius_top_right = 6
		bg.corner_radius_bottom_right = 6
		bg.corner_radius_bottom_left = 6
		bg.border_width_left = 2
		bg.border_width_top = 2
		bg.border_width_right = 2
		bg.border_width_bottom = 2
		bg.border_color = Color(0, 0, 0, 1)
		var fg = StyleBoxFlat.new()
		fg.bg_color = Color(0.859, 0.192, 0.192, 1)
		fg.corner_radius_top_left = 4
		fg.corner_radius_top_right = 4
		fg.corner_radius_bottom_right = 4
		fg.corner_radius_bottom_left = 4
		var bar = ProgressBar.new()
		bar.name = "HealthBar"
		bar.anchor_left = 1.0
		bar.anchor_top = 0.0
		bar.anchor_right = 1.0
		bar.anchor_bottom = 0.0
		bar.offset_left = -220.0
		bar.offset_top = 12.0
		bar.offset_right = -12.0
		bar.offset_bottom = 36.0
		bar.max_value = max_health
		bar.value = health
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", bg)
		bar.add_theme_stylebox_override("fill", fg)
		ui_layer.add_child(bar)
		health_bar = bar
	health_label = null
	if health_bar:
		health_label = health_bar.get_node_or_null("Label") as Label
		if health_label == null:
			var lbl = Label.new()
			lbl.name = "Label"
			lbl.layout_mode = 1
			lbl.anchors_preset = 15
			lbl.anchor_right = 1.0
			lbl.anchor_bottom = 1.0
			lbl.grow_horizontal = 2
			lbl.grow_vertical = 2
			lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lbl.text = "%d / %d" % [health, max_health]
			var fs = 14
			lbl.add_theme_font_size_override("font_size", fs)
			lbl.add_theme_color_override("font_color", Color(1,1,1,1))
			lbl.add_theme_color_override("font_shadow_color", Color(0,0,0,1))
			health_bar.add_child(lbl)
			health_label = lbl

func _update_health_ui() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if health_label:
		health_label.text = "%d / %d" % [health, max_health]

func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	_is_guarding = false
	_is_attacking = false
	_combo_index = 0
	_combo_timer = 0.0
	set_hitbox_active(false)
	if hitbox_debug:
		hitbox_debug.clear()
	velocity = Vector2.ZERO
	animated_sprite.play("death")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_attack()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_attack()

func _physics_process(delta: float) -> void:
	# --- Muerto: solo gravedad y animación de muerte ---
	if _is_dead:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.y += gravity * delta
		move_and_slide()
		return

	# --- Guardia: se mantiene pulsada (derecho del ratón o E) ---
	_is_guarding = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_key_pressed(KEY_E)

	# --- Combo timer (si no encadenas, vuelve a attack_1) ---
	if not _is_attacking and _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_index = 0

	# --- Gravedad ---
	var current_gravity: float = gravity
	if velocity.y > 0.0:
		current_gravity *= fall_gravity_multiplier
	velocity.y += current_gravity * delta

	# --- Movimiento horizontal con aceleración y rozamiento ---
	# Al atacar se mueve más lento, no se para solo y no puede girar
	var raw_direction: float = 0.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		raw_direction += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		raw_direction -= 1.0

	var direction: float = raw_direction
	if _is_guarding:
		# En guardia no se puede mover
		direction = 0.0
	elif _is_attacking:
		# Bloquear movimiento en dirección contraria y giro durante el ataque
		if (_facing_right and raw_direction < 0.0) or (not _facing_right and raw_direction > 0.0):
			direction = 0.0

	var effective_speed: float = move_speed * (0.38 if _is_attacking else 1.0)
	var effective_accel: float = acceleration * (0.38 if _is_attacking else 1.0)
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * effective_speed, effective_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# --- Dirección del sprite - pivot en hitbox para evitar teleporte ---
	# Bloqueado al atacar: no se puede cambiar la dirección del ataque
	if not _is_attacking:
		if direction > 0.0:
			_facing_right = true
		elif direction < 0.0:
			_facing_right = false
	# Rotar el pivot en la hitbox, no el centro de la imagen
	sprite_pivot.scale.x = 1.0 if _facing_right else -1.0
	# Asegurar que el sprite no use flip_h (evita doble espejo)
	animated_sprite.flip_h = false

	# Las hitboxes del ataque se espejean alrededor del origen del jugador
	var mirror: float = 1.0 if _facing_right else -1.0
	for i in attack_hitboxes.size():
		attack_hitboxes[i].position = Vector2(
			_hitbox_offsets[i].x * mirror - _hitbox_shape_offsets[i].x,
			_hitbox_offsets[i].y - _hitbox_shape_offsets[i].y
		)
	_update_hitbox_debug()

	# --- Salto - bloqueado al atacar o en guardia ---
	if _is_attacking or _is_guarding:
		# No permitir salto mientras ataca o defiende, reset buffers
		_jump_buffer_timer = 0.0
		_jump_was_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	else:
		var jump_pressed: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
		var jump_just_pressed: bool = jump_pressed and not _jump_was_pressed

		# Buffer: recuerda la pulsación unos instantes
		if jump_just_pressed:
			_jump_buffer_timer = jump_buffer_time
		else:
			_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

		# Coyote time: unos instantes después de dejar el suelo
		if is_on_floor():
			_coyote_timer = coyote_time
		else:
			_coyote_timer = maxf(_coyote_timer - delta, 0.0)

		if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
			velocity.y = jump_velocity
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0

		# Salto variable: si sueltas pronto, el salto es más corto
		if not jump_pressed and _jump_was_pressed and velocity.y < 0.0:
			velocity.y *= 0.45
		_jump_was_pressed = jump_pressed

	move_and_slide()
	_update_animation()

func _try_attack() -> void:
	if _is_dead or _is_attacking:
		return
	var anim: String = _ATTACK_ANIMS[_combo_index]
	_is_attacking = true
	_active_hitbox = _combo_index
	set_hitbox_active(true)
	animated_sprite.play(anim)

func _on_attack_finished() -> void:
	if animated_sprite.animation in _ATTACK_ANIMS:
		_is_attacking = false
		set_hitbox_active(false)
		# Avanza combo 1->2->3->0
		_combo_index = (_combo_index + 1) % _ATTACK_ANIMS.size()
		_combo_timer = combo_window
		# Si completó el ciclo 3→0, el timer igualmente permite reset visual
		_update_animation()
	else:
		_is_attacking = false
		set_hitbox_active(false)

func _update_animation() -> void:
	if _is_dead or _is_attacking:
		return
	if _is_guarding:
		animated_sprite.play("defend")
		return
	if not is_on_floor():
		if velocity.y < 0.0:
			animated_sprite.play("movement_right")
		else:
			animated_sprite.play("idle")
	elif absf(velocity.x) > 10.0:
		animated_sprite.play("movement_right")
	else:
		animated_sprite.play("idle")
