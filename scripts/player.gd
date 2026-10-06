extends CharacterBody2D

# ==============================================================================
# CONFIGURACIÓN Y VARIABLES
# ==============================================================================
# region Movimiento
@export_group("Movimiento")
@export var move_speed: float = 130.0
@export var acceleration: float = 750.0
@export var friction: float = 1000.0
@export var jump_velocity: float = -340.0
@export var gravity: float = 1400.0
@export var fall_gravity_multiplier: float = 1.6
@export var coyote_time: float = 0.1
@export var jump_buffer_time: float = 0.12
# endregion

# region Estadísticas y Economía
@export_group("Estadísticas y Economía")
@export var max_health: int = 100
@export var max_stamina: float = 100.0
@export var current_coins: int = 0
@export var initial_coins: int = 0

var health: int
var stamina: float
# endregion

# region Mecánicas de Stamina
@export_group("Costes de Stamina")
@export var run_speed_multiplier: float = 1.7
@export var run_acceleration_multiplier: float = 1.3
@export var run_initial_cost: float = 10.0
@export var run_drain_per_second: float = 10.0
@export var guard_initial_cost: float = 15.0
@export var guard_drain_per_second: float = 20.0
@export var stamina_regen_per_second: float = 10.0
# endregion

# region Combate
@export_group("Combate")
@export var hitbox_damage: int = 20
@export var combo_window: float = 0.35

const _ATTACK_ANIMS: Array[String] = ["attack_1", "attack_2", "attack_3"]
const STAMINA_COLOR: Color = Color(0.35, 0.82, 0.29, 1)
# endregion

# region Nodos OnReady
@onready var sprite_pivot: Node2D = $SpritePivot
@onready var animated_sprite: AnimatedSprite2D = $SpritePivot/AnimatedSprite2D
@onready var attack_hitboxes: Array[Area2D] = [$AttackHitbox1, $AttackHitbox2, $AttackHitbox3]
@onready var hitbox_shapes: Array[CollisionShape2D] = [
	$AttackHitbox1/CollisionShape2D,
	$AttackHitbox2/CollisionShape2D,
	$AttackHitbox3/CollisionShape2D,
]
# endregion

# Variables de estado interno
var health_bar: ProgressBar
var health_label: Label
var stamina_bar: ProgressBar
var stamina_label: Label
var coins_label: Label

var _hitbox_offsets: Array[Vector2] = []
var _hitbox_shape_offsets: Array[Vector2] = []
var _active_hitbox: int = 0
var _hit_targets: Array = []

var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _jump_was_pressed: bool = false
var _facing_right: bool = true
var _is_attacking: bool = false
var _is_guarding: bool = false
var _is_running: bool = false
var _is_dead: bool = false
var _combo_index: int = 0
var _combo_timer: float = 0.0


# ==============================================================================
# MÉTODOS PRINCIPALES
# ==============================================================================
func _ready() -> void:
	health = max_health
	stamina = max_stamina
	current_coins = initial_coins
	
	animated_sprite.animation_finished.connect(_on_attack_finished)
	
	for i in attack_hitboxes.size():
		_hitbox_offsets.append(attack_hitboxes[i].position + hitbox_shapes[i].position)
		_hitbox_shape_offsets.append(hitbox_shapes[i].position)
		attack_hitboxes[i].set_deferred("monitoring", false)
		attack_hitboxes[i].body_entered.connect(_on_attack_hitbox_body_entered)
		attack_hitboxes[i].area_entered.connect(_on_attack_hitbox_area_entered)
		
	_ensure_health_ui()
	_ensure_stamina_ui()
	_ensure_coins_ui()
	_update_health_ui()
	_update_stamina_ui()
	_update_coins_ui()


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_attack()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		_try_attack()


func _physics_process(delta: float) -> void:
	if _is_dead:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)
		velocity.y += gravity * delta
		move_and_slide()
		return

	_update_stamina(delta)

	# Reloj del combo
	if not _is_attacking and _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0:
			_combo_index = 0

	# Gravedad
	var current_gravity: float = gravity
	if velocity.y > 0.0:
		current_gravity *= fall_gravity_multiplier
	velocity.y += current_gravity * delta

	# Movimiento Horizontal
	var raw_direction: float = 0.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		raw_direction += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		raw_direction -= 1.0

	var direction: float = raw_direction
	if _is_guarding:
		direction = 0.0
	elif _is_attacking:
		if (_facing_right and raw_direction < 0.0) or (not _facing_right and raw_direction > 0.0):
			direction = 0.0

	var effective_speed: float = move_speed * (0.38 if _is_attacking else 1.0)
	var effective_accel: float = acceleration * (0.38 if _is_attacking else 1.0)
	
	if _is_running:
		effective_speed *= run_speed_multiplier
		effective_accel *= run_acceleration_multiplier
		
	if direction != 0.0:
		velocity.x = move_toward(velocity.x, direction * effective_speed, effective_accel * delta)
	else:
		velocity.x = move_toward(velocity.x, 0.0, friction * delta)

	# Orientación del Sprite e Hitboxes
	if not _is_attacking:
		if direction > 0.0:
			_facing_right = true
		elif direction < 0.0:
			_facing_right = false
			
	sprite_pivot.scale.x = 1.0 if _facing_right else -1.0
	animated_sprite.flip_h = false

	var mirror: float = 1.0 if _facing_right else -1.0
	for i in attack_hitboxes.size():
		attack_hitboxes[i].position = Vector2(
			_hitbox_offsets[i].x * mirror - _hitbox_shape_offsets[i].x,
			_hitbox_offsets[i].y - _hitbox_shape_offsets[i].y
		)

	# Salto
	if _is_attacking or _is_guarding:
		_jump_buffer_timer = 0.0
		_jump_was_pressed = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
	else:
		var jump_pressed: bool = Input.is_key_pressed(KEY_SPACE) or Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP)
		var jump_just_pressed: bool = jump_pressed and not _jump_was_pressed

		if jump_just_pressed:
			_jump_buffer_timer = jump_buffer_time
		else:
			_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

		if is_on_floor():
			_coyote_timer = coyote_time
		else:
			_coyote_timer = maxf(_coyote_timer - delta, 0.0)

		if _jump_buffer_timer > 0.0 and _coyote_timer > 0.0:
			velocity.y = jump_velocity
			_jump_buffer_timer = 0.0
			_coyote_timer = 0.0

		if not jump_pressed and _jump_was_pressed and velocity.y < 0.0:
			velocity.y *= 0.45
			
		_jump_was_pressed = jump_pressed

	move_and_slide()
	_update_animation()


# ==============================================================================
# COMBATE Y DAÑO
# ==============================================================================
func _try_attack() -> void:
	if _is_dead or _is_attacking:
		return
	var anim: String = _ATTACK_ANIMS[_combo_index]
	_is_attacking = true
	_active_hitbox = _combo_index
	set_hitbox_active(true)
	animated_sprite.play(anim)


func _on_attack_finished() -> void:
	_is_attacking = false
	set_hitbox_active(false)
	if animated_sprite.animation in _ATTACK_ANIMS:
		_combo_index = (_combo_index + 1) % _ATTACK_ANIMS.size()
		_combo_timer = combo_window
		_update_animation()


func set_hitbox_active(active: bool) -> void:
	for i in attack_hitboxes.size():
		attack_hitboxes[i].set_deferred("monitoring", active and i == _active_hitbox)
	if active:
		_hit_targets.clear()


func _on_attack_hitbox_body_entered(body: Node2D) -> void:
	_register_hit(body)


func _on_attack_hitbox_area_entered(area: Area2D) -> void:
	_register_hit(area)


func _register_hit(target: Node) -> void:
	if not _is_attacking or target == self or _hit_targets.has(target):
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


func take_damage(amount: int) -> void:
	_apply_damage(amount, true)


func take_damage_from(amount: int, attacker_position: Vector2) -> void:
	_apply_damage(amount, is_attack_from_front(attacker_position))


func is_attack_from_front(attacker_position: Vector2) -> bool:
	if is_equal_approx(attacker_position.x, global_position.x):
		return true
	return (attacker_position.x > global_position.x) == _facing_right


func _apply_damage(amount: int, from_front: bool) -> void:
	if _is_dead or (_is_guarding and from_front):
		return
	health = maxi(health - amount, 0)
	_update_health_ui()
	if health <= 0:
		_die()


func heal(amount: int) -> void:
	health = mini(health + amount, max_health)
	_update_health_ui()


func _die() -> void:
	if _is_dead:
		return
	_is_dead = true
	_is_guarding = false
	_is_running = false
	_is_attacking = false
	_combo_index = 0
	_combo_timer = 0.0
	set_hitbox_active(false)
	velocity = Vector2.ZERO
	animated_sprite.play("death")


# ==============================================================================
# STAMINA Y MONEDAS
# ==============================================================================
func add_coin(amount: int = 1) -> void:
	current_coins += amount
	_update_coins_ui()


func spend_coins(amount: int) -> bool:
	if current_coins < amount:
		return false
	current_coins -= amount
	_update_coins_ui()
	return true


func has_stamina(amount: float) -> bool:
	return stamina >= amount


func can_run() -> bool:
	return not _is_dead and not _is_guarding and not _is_attacking and is_on_floor() and has_stamina(run_initial_cost)


func can_guard() -> bool:
	return not _is_dead and not _is_attacking and has_stamina(guard_initial_cost)


func spend_stamina(amount: float) -> void:
	stamina = maxf(stamina - amount, 0.0)
	_update_stamina_ui()


func restore_stamina(amount: float) -> void:
	stamina = minf(stamina + amount, max_stamina)
	_update_stamina_ui()


func _update_stamina(delta: float) -> void:
	var guard_input: bool = Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT) or Input.is_key_pressed(KEY_E)
	var run_input: bool = Input.is_key_pressed(KEY_SHIFT)

	if _is_guarding:
		if not guard_input:
			_is_guarding = false
		else:
			spend_stamina(guard_drain_per_second * delta)
			if stamina <= 0.0:
				_is_guarding = false
	elif guard_input and can_guard():
		_is_guarding = true
		spend_stamina(guard_initial_cost)

	if _is_running:
		if not run_input or _is_guarding or _is_attacking or not is_on_floor():
			_is_running = false
		else:
			spend_stamina(run_drain_per_second * delta)
			if stamina <= 0.0:
				_is_running = false
	elif not _is_guarding and not _is_attacking and run_input and is_on_floor() and has_stamina(run_initial_cost):
		_is_running = true
		spend_stamina(run_initial_cost)

	if not _is_running and not _is_guarding:
		restore_stamina(stamina_regen_per_second * delta)


# ==============================================================================
# ANIMACIONES Y UI
# ==============================================================================
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
	elif _is_running:
		animated_sprite.play("run_right")
	elif absf(velocity.x) > 10.0:
		animated_sprite.play("movement_right")
	else:
		animated_sprite.play("idle")


func _ensure_health_ui() -> void:
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
		health_label = _get_or_create_bar_label(health_bar, "%d / %d" % [health, max_health])


func _ensure_stamina_ui() -> void:
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	stamina_bar = root.get_node_or_null("UILayer/StaminaBar") as ProgressBar
	if stamina_bar == null:
		stamina_bar = get_node_or_null("../UILayer/StaminaBar") as ProgressBar
	if stamina_bar == null and root:
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
		fg.bg_color = STAMINA_COLOR
		fg.corner_radius_top_left = 4
		fg.corner_radius_top_right = 4
		fg.corner_radius_bottom_right = 4
		fg.corner_radius_bottom_left = 4
		var bar = ProgressBar.new()
		bar.name = "StaminaBar"
		bar.anchor_left = 1.0
		bar.anchor_top = 0.0
		bar.anchor_right = 1.0
		bar.anchor_bottom = 0.0
		bar.offset_left = -220.0
		bar.offset_top = 36.0
		bar.offset_right = -12.0
		bar.offset_bottom = 60.0
		bar.show_percentage = false
		bar.add_theme_stylebox_override("background", bg)
		bar.add_theme_stylebox_override("fill", fg)
		ui_layer.add_child(bar)
		stamina_bar = bar
	stamina_label = null
	if stamina_bar:
		stamina_label = _get_or_create_bar_label(stamina_bar, "%d / %d" % [roundi(stamina), roundi(max_stamina)])


func _ensure_coins_ui() -> void:
	var root = get_parent()
	if root == null:
		root = get_tree().current_scene
	coins_label = root.get_node_or_null("UILayer/coins") as Label
	if coins_label == null:
		coins_label = get_node_or_null("../UILayer/coins") as Label
	if coins_label == null and root:
		var ui_layer = root.get_node_or_null("UILayer")
		if ui_layer == null:
			ui_layer = CanvasLayer.new()
			ui_layer.name = "UILayer"
			ui_layer.layer = 10
			root.add_child(ui_layer)
		var lbl = Label.new()
		lbl.name = "coins"
		lbl.layout_mode = 1
		lbl.anchors_preset = 15
		lbl.anchor_right = 1.0
		lbl.anchor_bottom = 1.0
		lbl.grow_horizontal = 2
		lbl.grow_vertical = 2
		lbl.offset_left = -180.0
		lbl.offset_top = -76.0
		lbl.offset_right = -180.0
		lbl.offset_bottom = -76.0
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		ui_layer.add_child(lbl)
		coins_label = lbl


func _get_or_create_bar_label(bar: ProgressBar, text: String) -> Label:
	var lbl: Label = bar.get_node_or_null("Label") as Label
	if lbl == null:
		lbl = Label.new()
		lbl.name = "Label"
		lbl.layout_mode = 1
		lbl.anchors_preset = 15
		lbl.anchor_right = 1.0
		lbl.anchor_bottom = 1.0
		lbl.grow_horizontal = 2
		lbl.grow_vertical = 2
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		lbl.add_theme_font_size_override("font_size", 14)
		lbl.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		lbl.add_theme_color_override("font_shadow_color", Color(0, 0, 0, 1))
		bar.add_child(lbl)
	lbl.text = text
	return lbl


func _update_health_ui() -> void:
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = health
	if health_label:
		health_label.text = "%d / %d" % [health, max_health]


func _update_stamina_ui() -> void:
	if stamina_bar:
		stamina_bar.max_value = max_stamina
		stamina_bar.value = stamina
	if stamina_label:
		stamina_label.text = "%d / %d" % [roundi(stamina), roundi(max_stamina)]


func _update_coins_ui() -> void:
	if coins_label:
		coins_label.text = str(current_coins)
