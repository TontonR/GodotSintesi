extends SceneTree

var scene: Node
var player: CharacterBody2D
var world: TileMapLayer
var frame: int = 0
var started: bool = false
var fails: int = 0

func _initialize() -> void:
	scene = load("res://icon.tscn").instantiate()
	root.add_child(scene)
	player = scene.get_node("player")
	world = scene.get_node("TileMapLayer")
	physics_frame.connect(_on_physics)

func _check(label: String, ok: bool, detail: String) -> void:
	if not ok:
		fails += 1
	print("  [%s] %s -> %s" % ["OK" if ok else "FALLA", label, detail])

func _wait(frames: int) -> void:
	for i in range(frames):
		await physics_frame

func _coins_in_zone(zone_index: int) -> Array:
	var start_x: int = zone_index * world.zone_width_tiles * 16
	var end_x: int = start_x + world.zone_width_tiles * 16
	var found: Array = []
	for coin in get_nodes_in_group("coins"):
		if coin.global_position.x >= start_x and coin.global_position.x < end_x:
			found.append(coin)
	return found

func _coins_near(x: float, radius: float) -> int:
	var count: int = 0
	for coin in get_nodes_in_group("coins"):
		if absf(coin.global_position.x - x) <= radius:
			count += 1
	return count

func _run() -> void:
	# Espera a que se apliquen los add_child diferidos del generador de zonas
	await _wait(30)

	# --- 1. La moneda usa solo el CollisionShape2D que creó el usuario ---
	var template: Node = load("res://coin.tscn").instantiate()
	_check("la moneda es un Area2D (única forma de detectar)", template is Area2D, "tipo=%s" % template.get_class())
	var shapes: Array = template.find_children("*", "CollisionShape2D", true, false)
	_check("la moneda tiene 1 sola hitbox", shapes.size() == 1, "hitboxes=%d" % shapes.size())
	_check("la hitbox cuelga de la raíz", shapes.size() == 1 and shapes[0].get_parent() == template, "padre=%s" % ("n/a" if shapes.is_empty() else shapes[0].get_parent().name))
	template.free()

	# --- 2. 20 monedas por zona ---
	# Se usan las listas del propio generador: el grupo también incluye la moneda
	# que el usuario colocó a mano en icon.tscn
	var tracked0: Array = world.loaded_zones[0]["coins"]
	var tracked1: Array = world.loaded_zones[1]["coins"]
	_check("20 monedas generadas en la zona 0", tracked0.size() == world.coins_per_zone, "monedas=%d esperado=%d" % [tracked0.size(), world.coins_per_zone])
	_check("20 monedas generadas en la zona 1", tracked1.size() == world.coins_per_zone, "monedas=%d esperado=%d" % [tracked1.size(), world.coins_per_zone])
	var expected_y: float = world.ground_level * 16 - world.coin_ground_offset
	var on_ground: bool = true
	var inside_zone: bool = true
	var in_tree: bool = true
	var in_group: bool = true
	for coin in tracked0:
		if not is_equal_approx(coin.position.y, expected_y):
			on_ground = false
		if coin.position.x < world.safe_start_tiles * 16 or coin.position.x >= world.zone_width_tiles * 16:
			inside_zone = false
		if not coin.is_inside_tree():
			in_tree = false
		if not coin.is_in_group("coins"):
			in_group = false
	_check("las monedas quedan apoyadas en el suelo", on_ground, "y=%.1f esperado=%.1f" % [tracked0[0].position.y, expected_y])
	_check("las monedas de la zona 0 están dentro de su rango", inside_zone, "rango=[%d, %d)" % [world.safe_start_tiles * 16, world.zone_width_tiles * 16])
	_check("las monedas están en la escena", in_tree, "todas dentro=%s" % in_tree)
	_check("las monedas se registran en el grupo 'coins'", in_group, "todas en el grupo=%s" % in_group)

	# --- 3. Recogerlas sigue funcionando ---
	var zone0: Array = _coins_in_zone(0)
	var before: int = player.current_coins
	var target: Node2D = tracked0[tracked0.size() - 1]
	target.global_position = player.global_position
	await _wait(10)
	_check("recoger la moneda la borra", not is_instance_valid(target), "viva=%s" % is_instance_valid(target))
	_check("y suma 1 al contador", player.current_coins == before + 1, "contador=%d esperado=%d" % [player.current_coins, before + 1])
	_check("el Label sigue al contador", player.coins_label.text == str(player.current_coins), "texto='%s' contador=%d" % [player.coins_label.text, player.current_coins])

	# --- 4. El ogro suelta monedas al morir ---
	var orc: Node2D = load("res://orc.tscn").instantiate()
	var drop_x: float = player.global_position.x + 120
	orc.position = Vector2(drop_x, player.global_position.y)
	scene.add_child(orc)
	await _wait(5)
	var expected_drop: int = orc.coins_on_death
	var coins_before: int = _coins_near(drop_x, 60)
	orc.take_damage(9999)
	await _wait(10)
	_check("el ogro muere y se libera", not is_instance_valid(orc), "vivo=%s" % is_instance_valid(orc))
	_check("el ogro suelta %d monedas" % expected_drop, _coins_near(drop_x, 60) - coins_before == expected_drop, "soltadas=%d" % (_coins_near(drop_x, 60) - coins_before))
	var grounded: bool = true
	for coin in get_nodes_in_group("coins"):
		if absf(coin.global_position.x - drop_x) <= 60 and coin.global_position.y > world.ground_level * 16:
			grounded = false
	_check("las monedas soltadas no flotan bajo el suelo", grounded, "suelo=%d" % (world.ground_level * 16))

	# --- 5. Descargar la zona limpia sus monedas ---
	var zone0_before: int = _coins_in_zone(0).size()
	world._unload_zone(0)
	await _wait(5)
	_check("descargar la zona 0 borra sus monedas", _coins_in_zone(0).size() == 0, "antes=%d despues=%d" % [zone0_before, _coins_in_zone(0).size()])
	_check("la zona 1 queda intacta", _coins_in_zone(1).size() == world.coins_per_zone, "monedas=%d" % _coins_in_zone(1).size())

	print("RESULTADO: ", "OK" if fails == 0 else "FALLA (%d)" % fails)
	quit(0 if fails == 0 else 1)

func _on_physics() -> void:
	frame += 1
	if not started and frame > 2:
		started = true
		_run()