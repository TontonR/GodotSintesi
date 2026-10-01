extends SceneTree

func _initialize() -> void:
	var scene: Node = load("res://icon.tscn").instantiate()
	root.add_child(scene)
	await process_frame
	await process_frame
	var ui: CanvasLayer = scene.get_node("UILayer")
	var fails: int = 0
	for bar_name in ["HealthBar", "StaminaBar"]:
		var bar: ProgressBar = ui.get_node(bar_name)
		var fill: StyleBoxFlat = bar.get_theme_stylebox("fill") as StyleBoxFlat
		var bg: StyleBoxFlat = bar.get_theme_stylebox("background") as StyleBoxFlat
		var visible_fill: bool = fill != null and fill.draw_center and not is_equal_approx(fill.bg_color.a, 0.0)
		if not visible_fill:
			fails += 1
		print("%s -> fill=%s color=%s | bg=%s draw_center=%s | value=%.0f/%.0f" % [
			bar_name, "null" if fill == null else "ok", "n/a" if fill == null else fill.bg_color.to_html(false),
			"n/a" if bg == null else bg.bg_color.to_html(false), str(null if fill == null else fill.draw_center),
			bar.value, bar.max_value])
	print("RESULTADO: ", "OK" if fails == 0 else "FALLA (%d)" % fails)
	quit(0 if fails == 0 else 1)
