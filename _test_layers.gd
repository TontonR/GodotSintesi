extends SceneTree

var frames: int = 0
var game: Node = null
var player: CharacterBody2D = null
var orc: CharacterBody2D = null
var orc2: CharacterBody2D = null
var orc_hp0: float = -1.0
var player_hp0: int = -1
var fails: Array[String] = []

func _chk(cond: bool, msg: String) -> void:
	print(("OK   - " if cond else "FALLO - ") + msg)
	if not cond:
		fails.append(msg)

func _initialize() -> void:
	var packed: PackedScene = load("res://icon.tscn")
	if packed == null:
		print("FALLO - no se pudo cargar icon.tscn")
		quit(1)
		return
	root.add_child(packed.instantiate())
	game = root.get_node("game")
	player = game.get_node("player")

func _process(_d: float) -> bool:
	frames += 1

	if frames == 5:
		var orcs: Array = []
		for ch in game.get_children():
			if ch is CharacterBody2D and ch != player and ch.has_method("_start_attack"):
				orcs.append(ch)
		_chk(orcs.size() >= 2, "hay orcos en escena (%d)" % orcs.size())
		orc = orcs[0]
		orc2 = orcs[1]

		# --- configuración de capas ---
		_chk(_ps("physics/layer_names/2d_physics/layer_1") == "Mundo", "capa 1 = Mundo")
		_chk(_ps("physics/layer_names/2d_physics/layer_2") == "Jugador", "capa 2 = Jugador")
		_chk(_ps("physics/layer_names/2d_physics/layer_3") == "Enemigos", "capa 3 = Enemigos")
		_chk(player.collision_layer == 2, "player layer = 2 (Jugador)")
		_chk(player.collision_mask == 5, "player mask = 5 (Mundo+Enemigos)")
		for i in 3:
			var hb: Area2D = player.get_node("AttackHitbox%d" % (i + 1))
			_chk(hb.collision_layer == 8, "AttackHitbox%d layer = 8 (Ataque jugador)" % (i + 1))
			_chk(hb.collision_mask == 4, "AttackHitbox%d mask = 4 (Enemigos)" % (i + 1))
		_chk(orc.collision_layer == 4, "Orc layer = 4 (Enemigos)")
		_chk(orc.collision_mask == 3, "Orc mask = 3 (Mundo+Jugador)")
		_chk(orc.get_node("Pivot/detection_area").collision_mask == 2, "detection_area mask = 2 (Jugador)")
		_chk(orc.get_node("Pivot/attack_range").collision_mask == 2, "attack_range mask = 2 (Jugador)")
		var tileset: TileSet = game.get_node("TileMapLayer").tile_set
		_chk(tileset.get_physics_layer_collision_layer(0) == 1, "suelo layer = 1 (Mundo)")

		# --- posicionamiento para el combate ---
		player.position = Vector2(1000, 306)
		player.velocity = Vector2.ZERO
		orc.position = Vector2(1030, 306)
		orc.velocity = Vector2.ZERO

	if frames == 8:
		orc_hp0 = orc.current_health
		player_hp0 = player.health
		player.call("_try_attack")

	if frames == 20:
		var hb1: Area2D = player.get_node("AttackHitbox1")
		var hbs: CollisionShape2D = hb1.get_child(0)
		var ob: CollisionShape2D = orc.get_node("orc_hitbox")
		print("  GEOM hb_pos=%s hb_shape_pos=%s size=%s disabled=%s" % [str(hb1.global_position), str(hbs.global_position), str((hbs.shape as RectangleShape2D).size), str(hbs.disabled)])
		print("  GEOM orc_pos=%s orc_shape_pos=%s size=%s disabled=%s" % [str(orc.global_position), str(ob.global_position), str((ob.shape as RectangleShape2D).size), str(ob.disabled)])
		print("  GEOM overlaps_body=%s hb_mask=%d orc_layer=%d hb_layer=%d hb_monitoring=%s" % [str(hb1.overlaps_body(orc)), hb1.collision_mask, orc.collision_layer, hb1.collision_layer, str(hb1.monitoring)])
		print("  GEOM hb_bodies=%s" % str(hb1.get_overlapping_bodies()))

	if frames == 40:
		var hps: Array = []
		for ch in game.get_children():
			if ch is CharacterBody2D and ch != player and ch.has_method("_start_attack"):
				hps.append("%.0f" % ch.current_health)
		print("  vidas orcos: " + str(hps))
		_chk(orc.current_health < orc_hp0, "el ataque del jugador daña al orco (%.0f -> %.0f)" % [orc_hp0, orc.current_health])

	if frames in [40, 90, 140]:
		print("  dbg f%d: pos_jugador=%s pos_orco=%s _player=%s en_rango=%s atacando=%s puede=%s det_bodies=%d atk_pos.x=%.1f atk_bodies=%d" % [
			frames, str(player.position), str(orc.position),
			str(orc._player != null), str(orc._player_in_attack_range),
			str(orc._is_attacking), str(orc._can_attack),
			orc.get_node("Pivot/detection_area").get_overlapping_bodies().size(),
			orc.get_node("Pivot/attack_range").position.x,
			orc.get_node("Pivot/attack_range").get_overlapping_bodies().size(),
		])

	if frames >= 5 and frames <= 45:
		var hb1: Area2D = player.get_node("AttackHitbox1")
		print("  f%-3d jugador_x=%.1f orco_x=%.1f player=%s rango=%s atac=%s puede=%s atk_x=%.1f det=%d atkb=%d | hb_mon=%s hb_bodies=%d pj_atac=%s hits=%d" % [
			frames, player.position.x, orc.position.x,
			str(orc._player != null), str(orc._player_in_attack_range),
			str(orc._is_attacking), str(orc._can_attack),
			orc.get_node("Pivot/attack_range").position.x,
			orc.get_node("Pivot/detection_area").get_overlapping_bodies().size(),
			orc.get_node("Pivot/attack_range").get_overlapping_bodies().size(),
			str(hb1.monitoring), (hb1.get_overlapping_bodies().size() if hb1.monitoring else -1),
			str(player._is_attacking), player._hit_targets.size(),
		])

	if frames == 140:
		_chk(player.health < player_hp0, "el ataque del orco daña al jugador (%d -> %d)" % [player_hp0, player.health])

	if frames == 150:
		orc2.call("_start_attack")
		orc2.call("take_damage", 99999)

	if frames == 160:
		_chk(not is_instance_valid(orc2), "el orco muere (queue_free)")

	if frames == 340:
		print("nota: revisa stderr arriba por si hay errores de script")
		if fails.is_empty():
			print("TEST_OK")
		else:
			print("TEST_FALLO: %d comprobaciones" % fails.size())
		quit(1 if not fails.is_empty() else 0)
		return true
	return false

func _ps(key: String) -> String:
	return str(ProjectSettings.get_setting(key, ""))
