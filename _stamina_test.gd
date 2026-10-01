extends SceneTree

var player: CharacterBody2D
var tick: int = 0
var phase: int = 0
var fails: int = 0
var min_stamina_seen: float = INF

func _initialize() -> void:
	var floor_body := StaticBody2D.new()
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(4000, 100)
	shape.shape = rect
	floor_body.position = Vector2(0, 200)
	floor_body.add_child(shape)
	root.add_child(floor_body)

	player = load("res://player.tscn").instantiate()
	player.global_position = Vector2(0, 150)
	root.add_child(player)
	physics_frame.connect(_on_physics)

func _key(code: Key, pressed: bool) -> void:
	var ev := InputEventKey.new()
	ev.physical_keycode = code
	ev.keycode = code
	ev.pressed = pressed
	Input.parse_input_event(ev)

func _clear_input() -> void:
	_key(KEY_SHIFT, false)
	_key(KEY_E, false)
	_key(KEY_D, false)
	_key(KEY_A, false)

func _check(label: String, ok: bool, detail: String) -> void:
	if not ok:
		fails += 1
	print("  [%s] %s -> %s" % ["OK" if ok else "FALLA", label, detail])

func _on_physics() -> void:
	tick += 1
	min_stamina_seen = minf(min_stamina_seen, player.stamina)
	match phase:
		0:
			# Fase 0: 30 ticks en reposo con stamina llena
			if tick > 30:
				_check("reposo con stamina llena no gasta", is_equal_approx(player.stamina, 100.0), "stamina=%.2f" % player.stamina)
				_check("no corre sin pulsar", not player._is_running, "_is_running=%s" % player._is_running)
				_clear_input()
				player.stamina = 50.0
				phase = 1
				tick = 0
		1:
			# Fase 1: 60 ticks (1s) regenerando
			if tick > 60:
				_check("regenera +10/s en 1s (50 -> 60)", absf(player.stamina - 60.0) < 0.5, "stamina=%.2f" % player.stamina)
				player.stamina = 100.0
				_key(KEY_D, true)
				_key(KEY_SHIFT, true)
				phase = 2
				tick = 0
		2:
			# Fase 2: 2 ticks con shift = golpe inicial
			if tick > 2:
				var expected: float = 100.0 - 10.0 - 10.0 * (2.0 / 60.0)
				_check("correr cobra -10 inicial + -10/s", absf(player.stamina - expected) < 1.0, "stamina=%.2f esperado=%.2f" % [player.stamina, expected])
				_check("corre activo", player._is_running, "_is_running=%s" % player._is_running)
				var anim: String = player.animated_sprite.animation
				_check("animacion de carrera", anim == "run_right", "anim=%s" % anim)
				phase = 3
				tick = 0
		3:
			# Fase 3: 60 ticks mas corriendo (1s total)
			if tick > 60:
				var expected: float = 100.0 - 10.0 - 10.0 * (62.0 / 60.0)
				_check("correr 1s completo (100 -> 79.7)", absf(player.stamina - expected) < 1.0, "stamina=%.2f esperado=%.2f" % [player.stamina, expected])
				var fast: bool = absf(player.velocity.x) > 130.0 * 1.5
				_check("velocidad de carrera > 1.5x", fast, "vel.x=%.1f" % player.velocity.x)
				_clear_input()
				phase = 4
				tick = 0
		4:
			# Fase 4: 30 ticks sin nada tras soltar (regenera)
			if tick > 30:
				var expected: float = 79.667 + 10.0 * 0.5
				_check("regenera al parar de correr", absf(player.stamina - expected) < 1.0, "stamina=%.2f esperado=%.2f" % [player.stamina, expected])
				_check("vuelve a animacion de andar", player.animated_sprite.animation != "run_right", "anim=%s" % player.animated_sprite.animation)
				player.stamina = 100.0
				_key(KEY_E, true)
				phase = 5
				tick = 0
		5:
			# Fase 5: 2 ticks con guardia = golpe inicial
			if tick > 2:
				var expected: float = 100.0 - 15.0 - 20.0 * (2.0 / 60.0)
				_check("defender cobra -15 inicial + -20/s", absf(player.stamina - expected) < 1.0, "stamina=%.2f esperado=%.2f" % [player.stamina, expected])
				_check("guardia activa", player._is_guarding, "_is_guarding=%s" % player._is_guarding)
				phase = 6
				tick = 0
		6:
			# Fase 6: 60 ticks mas de guardia
			if tick > 60:
				var expected: float = 100.0 - 15.0 - 20.0 * (62.0 / 60.0)
				_check("defender 1s completo (100 -> 64.3)", absf(player.stamina - expected) < 1.0, "stamina=%.2f esperado=%.2f" % [player.stamina, expected])
				_clear_input()
				phase = 7
				tick = 0
		7:
			# Fase 7: sin stamina no se puede correr ni defender
			if tick > 10:
				player.stamina = 5.0
				_key(KEY_D, true)
				_key(KEY_SHIFT, true)
				_key(KEY_E, true)
				phase = 8
				tick = 0
		8:
			# Fase 8: 30 ticks con shift+E y solo 5 de stamina
			if tick > 30:
				_check("sin stamina no corre", not player._is_running, "_is_running=%s" % player._is_running)
				_check("sin stamina no defiende", not player._is_guarding, "_is_guarding=%s" % player._is_guarding)
				_check("no queda en negativo", player.stamina >= 0.0, "stamina=%.2f" % player.stamina)
				_clear_input()
				phase = 9
				tick = 0
		9:
			# Fase 9: 12 ticks con 9 de stamina -> no alcanza para el golpe inicial (10)
			if tick > 12:
				player.stamina = 9.0
				_key(KEY_D, true)
				_key(KEY_SHIFT, true)
				phase = 10
				tick = 0
		10:
			# Fase 10: 5 ticks con 9 de stamina (antes de que la regen llegue a 10)
			if tick > 5:
				_check("9 de stamina no permite iniciar carrera", not player._is_running, "_is_running=%s stamina=%.2f" % [player._is_running, player.stamina])
				_check("con 9 de stamina solo regenera", player.stamina >= 9.0 and player.stamina < 10.5, "stamina=%.2f" % player.stamina)
				_clear_input()
				phase = 11
				tick = 0
		11:
			# Fase 11: 20 ticks de calma para asentar estados
			if tick > 20:
				player.stamina = 14.0
				min_stamina_seen = INF
				_key(KEY_D, true)
				_key(KEY_SHIFT, true)
				phase = 12
				tick = 0
		12:
			# Fase 12: 60 ticks corriendo desde 14 -> se agota y para
			if tick > 60:
				_check("carrera se agota y se para sola", not player._is_running, "_is_running=%s stamina=%.2f" % [player._is_running, player.stamina])
				_check("la stamina llega a 0 al agotarse", min_stamina_seen < 0.001, "minimo=%.2f" % min_stamina_seen)
				_check("al agotarse vuelve a andar", player.animated_sprite.animation == "movement_right", "anim=%s" % player.animated_sprite.animation)
				_clear_input()
				phase = 13
				tick = 0
		13:
			# Fase 13: 20 de stamina -> 15 inicial deja 5, la guardia se rompe al llegar a 0
			if tick > 5:
				player.stamina = 20.0
				min_stamina_seen = INF
				_key(KEY_E, true)
				phase = 14
				tick = 0
		14:
			# Fase 14: 60 ticks de guardia desde 20
			if tick > 60:
				_check("la guardia se rompe al quedarse sin stamina", not player._is_guarding, "_is_guarding=%s stamina=%.2f" % [player._is_guarding, player.stamina])
				_check("la guardia consume hasta 0", min_stamina_seen < 0.25, "minimo=%.2f (margen de 1 tick de muestreo)" % min_stamina_seen)
				_check("tras romperse vuelve a idle", player.animated_sprite.animation == "idle", "anim=%s" % player.animated_sprite.animation)
				_clear_input()
				print("RESULTADO: ", "OK" if fails == 0 else "FALLA (%d)" % fails)
				quit(0 if fails == 0 else 1)
