extends SceneTree

const RUN_FRAMES: int = 1200
const WARMUP_FRAMES: int = 60
const SETTLE_FRAMES: int = 12
const MAX_EXPECTED_LAG: float = 18.0
const MAX_EXPECTED_CAMERA_STEP: float = 6.0


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var args := OS.get_cmdline_user_args()
	var seed_value: int = int(args[0]) if not args.is_empty() else 12345
	var game_scene := load("res://scenes/game.tscn") as PackedScene
	var game := game_scene.instantiate()
	game.get_node("map").set("world_seed", seed_value)
	root.add_child(game)
	await physics_frame

	var player := game.get_node("player") as CharacterBody2D
	var camera := player.get_node("Camera2D") as Camera2D
	for _frame in range(WARMUP_FRAMES):
		await physics_frame

	var start_position: Vector2 = player.global_position
	var max_lag: float = 0.0
	var max_camera_dy: float = 0.0
	var last_camera_y: float = camera.global_position.y
	_set_key(KEY_D, true)
	for _frame in range(RUN_FRAMES):
		await physics_frame
		var lag: float = player.global_position.y - camera.global_position.y
		max_lag = maxf(max_lag, absf(lag))
		max_camera_dy = maxf(max_camera_dy, absf(camera.global_position.y - last_camera_y))
		last_camera_y = camera.global_position.y
	var run_end_lag: float = player.global_position.y - camera.global_position.y
	_set_key(KEY_D, false)
	for _frame in range(SETTLE_FRAMES):
		await physics_frame
	var settled_lag: float = player.global_position.y - camera.global_position.y
	var player_x_delta: float = player.global_position.x - start_position.x
	var passed: bool = player_x_delta > 100.0 and max_lag <= MAX_EXPECTED_LAG and max_camera_dy <= MAX_EXPECTED_CAMERA_STEP and absf(settled_lag) <= 1.0
	print("DIAG seed=", seed_value,
		" max_abs_lag=", max_lag,
		" run_end_lag=", run_end_lag,
		" settled_lag=", settled_lag,
		" max_camera_dy=", max_camera_dy,
		" player_x_delta=", player_x_delta,
		" player_y_delta=", player.global_position.y - start_position.y,
		" result=", "PASS" if passed else "FAIL")
	quit(0 if passed else 1)


func _set_key(key: Key, pressed: bool) -> void:
	var event := InputEventKey.new()
	event.keycode = key
	event.physical_keycode = key
	event.pressed = pressed
	Input.parse_input_event(event)