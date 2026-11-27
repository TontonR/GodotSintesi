class_name SpriteFusionBlood
extends Sprite2D

# ==============================================================================
# BLOOD SPRAY (SPRITE FUSION RECIPE, WORLD SPACE)
# ==============================================================================
# Port of the free (MIT) `blood` effect from Sprite Fusion's VFX library:
#   https://www.spritefusion.com/pixel-art-vfx/blood
# The original recipe lives in assets/vfx/spritefusion/blood.ts. One node per
# hit draws the whole spray into a small RGBA8 canvas anchored in the world:
# 7 strands grow first, drops fly with drag and gravity, land on
# `WorldGenerator.ground_y_at()` and leave stains that dry for 6 s; mist and
# drips finish the read. The 6-tone ramp is derived from `blood_color`, so every
# enemy keeps its own blood.

const CANVAS_SIZE := Vector2i(256, 160)
## Canvas top-left relative to the hit: mostly above and to both sides.
const CANVAS_OFFSET := Vector2(-128.0, -104.0)
const GRAVITY := 1900.0
const STAIN_LIFE := 6.0
const STRAND_SECONDS := 0.09
const BAYER := [0, 8, 2, 10, 12, 4, 14, 6, 3, 11, 1, 9, 15, 7, 13, 5]

## Colour of this spray; the six tones of the palette are derived from it.
@export var blood_color: Color = Color(0.82, 0.11, 0.1)
## Spray side: +1 to the right, -1 to the left.
@export var direction: int = 1
## Scales the number of drops and the jet, like the recipe's `amount`.
@export_range(0.3, 3.0, 0.1) var amount: float = 1.0
## Scales strands, drops and mist, like the recipe's `size`.
@export_range(0.5, 2.0, 0.1) var size: float = 1.0

var _ramp: Array[Color] = []
var _drops: Array[Dictionary] = []
var _stains: Array[Dictionary] = []
var _mist: Array[Dictionary] = []
var _strands: Array[Dictionary] = []
var _drips: Array[Dictionary] = []

var _time := 0.0
var _angle := PI + 0.35
var _image: Image
var _texture: ImageTexture
var _origin := Vector2.ZERO
var _rng := RandomNumberGenerator.new()
var _world: Node


func _ready() -> void:
	centered = false
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = 4


## Starts the spray at `world_position`. Call it after adding the node to
## the tree; the node frees itself when the last stain dries.
func play(world_position: Vector2, spray_direction: int = 1) -> void:
	global_position = world_position
	direction = 1 if spray_direction >= 0 else -1
	offset = CANVAS_OFFSET
	_origin = world_position + CANVAS_OFFSET
	_rng.randomize()
	_ramp = _make_ramp()
	_image = Image.create(CANVAS_SIZE.x, CANVAS_SIZE.y, false, Image.FORMAT_RGBA8)
	_image.fill(Color(0.0, 0.0, 0.0, 0.0))
	_texture = ImageTexture.create_from_image(_image)
	texture = _texture
	_emit()


func _process(delta: float) -> void:
	if _image == null:
		return
	_time += delta
	_step(delta)
	_image.fill(Color(0.0, 0.0, 0.0, 0.0))
	_draw_stains()
	_draw_strands()
	_draw_mist()
	_draw_drips()
	_draw_drops()
	_texture.update(_image)
	if _finished():
		queue_free()


# --- Emission ---------------------------------------------------------------

func _emit() -> void:
	_time = 0.0
	_angle = -0.35 if direction > 0 else PI + 0.35
	var ux := cos(_angle)
	var uy := sin(_angle)
	var wound := global_position
	for i in 7:
		var u := (float(i) - 3.0) / 3.0
		_strands.append({
			"a": _angle + u * 0.62 + _rng.randf_range(-0.08, 0.08),
			"l": (11.0 + 7.0 * (1.0 - absf(u)) + _rng.randf_range(-2.0, 3.0)) * size,
			"w": (1.3 + 0.6 * (1.0 - absf(u))) * size,
		})
	var drip_times := [
		_rng.randf_range(0.22, 0.32),
		_rng.randf_range(0.6, 0.8),
		_rng.randf_range(1.1, 1.4),
	]
	for i in (3 if amount >= 1.0 else 2):
		_drips.append({"t0": drip_times[i], "fell": false})
	for i in roundi(46.0 * amount):
		var s := 3 if _rng.randf() < 0.12 else (2 if _rng.randf() < 0.35 else 1)
		var spread := _rng.randf_range(-1.0, 1.0) * _rng.randf_range(0.1, 0.65) * (1.2 if s == 1 else 0.8)
		var delay := _rng.randf_range(0.0, 0.07)
		var speed := (
			_rng.randf_range(260.0, 950.0) if s == 1
			else _rng.randf_range(200.0, 650.0) if s == 2
			else _rng.randf_range(150.0, 460.0)
		) * (1.0 - delay * 4.0) * sqrt(size)
		var a := _angle + spread
		_drops.append(_make_drop(
			wound.x + ux * _rng.randf_range(0.0, 8.0),
			wound.y + uy * _rng.randf_range(0.0, 8.0),
			cos(a) * speed,
			sin(a) * speed - _rng.randf_range(0.0, 150.0),
			s, delay, 3.0, false))
	var jet := roundi(14.0 * amount)
	for i in jet:
		var a := _angle + _rng.randf_range(-0.12, 0.12)
		var speed := _rng.randf_range(620.0, 1050.0) * sqrt(size)
		_drops.append(_make_drop(
			wound.x, wound.y,
			cos(a) * speed,
			sin(a) * speed - _rng.randf_range(0.0, 60.0),
			2 if _rng.randf() < 0.25 else 1,
			(float(i) / 14.0) * 0.05, 3.0, false))
	for i in roundi(6.0 * sqrt(amount)):
		var a := _angle + _rng.randf_range(-0.5, 0.5)
		var speed := _rng.randf_range(30.0, 110.0)
		var life := _rng.randf_range(0.35, 0.6)
		_mist.append({
			"x": wound.x + ux * _rng.randf_range(2.0, 14.0),
			"y": wound.y + uy * _rng.randf_range(2.0, 14.0),
			"vx": cos(a) * speed,
			"vy": sin(a) * speed - 12.0,
			"r": _rng.randf_range(2.5, 5.0) * size,
			"life": life,
			"max": life,
			"t0": _rng.randf_range(0.0, 0.05),
		})


func _make_drop(x: float, y: float, vx: float, vy: float, s: int, delay: float, life: float, crown: bool) -> Dictionary:
	return {
		"x": x,
		"y": y,
		"vx": vx,
		"vy": vy,
		"s": s,
		"delay": delay,
		"life": life,
		"crown": crown,
		"seed": _rng.randf(),
	}


# --- Simulation -------------------------------------------------------------

func _step(delta: float) -> void:
	for i in range(_drops.size() - 1, -1, -1):
		var drop: Dictionary = _drops[i]
		if float(drop["delay"]) > 0.0:
			drop["delay"] = float(drop["delay"]) - delta
			continue
		drop["life"] = float(drop["life"]) - delta
		if float(drop["life"]) <= 0.0:
			_drops.remove_at(i)
			continue
		var drag := 0.7 / float(drop["s"])
		drop["vy"] = float(drop["vy"]) + GRAVITY * delta
		drop["vx"] = float(drop["vx"]) - float(drop["vx"]) * drag * delta
		drop["vy"] = float(drop["vy"]) - float(drop["vy"]) * drag * 0.5 * delta
		var previous_y := float(drop["y"])
		drop["x"] = float(drop["x"]) + float(drop["vx"]) * delta
		drop["y"] = float(drop["y"]) + float(drop["vy"]) * delta
		var ground := _ground_y(float(drop["x"]))
		if float(drop["vy"]) > 0.0 and previous_y <= ground and float(drop["y"]) >= ground:
			_splat(drop, ground)
			_drops.remove_at(i)
	for drip in _drips:
		if bool(drip["fell"]) or _time < float(drip["t0"]) + 0.2:
			continue
		drip["fell"] = true
		_drops.append(_make_drop(
			global_position.x + _rng.randf_range(-1.0, 1.0),
			global_position.y + 6.0,
			_rng.randf_range(-10.0, 10.0), 30.0,
			2 if _rng.randf() < 0.5 else 1, 0.0, 3.0, false))
	for i in range(_mist.size() - 1, -1, -1):
		var puff: Dictionary = _mist[i]
		if float(puff["t0"]) > 0.0:
			puff["t0"] = float(puff["t0"]) - delta
			continue
		puff["life"] = float(puff["life"]) - delta
		if float(puff["life"]) <= 0.0:
			_mist.remove_at(i)
			continue
		puff["vx"] = float(puff["vx"]) - float(puff["vx"]) * 3.0 * delta
		puff["vy"] = float(puff["vy"]) - float(puff["vy"]) * 3.0 * delta - 6.0 * delta
		puff["x"] = float(puff["x"]) + float(puff["vx"]) * delta
		puff["y"] = float(puff["y"]) + float(puff["vy"]) * delta


## A drop that reaches the ground: stain with the recipe's width, plus a small
## crown of drops that bounces when the hit was strong.
func _splat(drop: Dictionary, ground: float) -> void:
	var speed := sqrt(float(drop["vx"]) * float(drop["vx"]) + float(drop["vy"]) * float(drop["vy"]))
	var dir := 1 if float(drop["vx"]) >= 0.0 else -1
	var s := int(drop["s"])
	var width := (0.5 + minf(0.6, speed / 1200.0)) if s == 1 else s * 0.6 + minf(0.9, speed / 800.0)
	if bool(drop["crown"]):
		width *= 0.5
	var sats: Array[Vector2] = []
	var sat_count := 2 if s >= 2 and speed > 350.0 else (1 if speed > 450.0 else 0)
	for k in sat_count:
		sats.append(Vector2(
			_rng.randf_range(1.0, 3.0) + k * _rng.randf_range(1.5, 3.0),
			2.0 if _rng.randf() < 0.2 else 1.0))
	_stains.append({
		"x": float(drop["x"]),
		"y": roundi(ground),
		"w": width,
		"lean": minf(1.0, absf(float(drop["vx"])) / 400.0),
		"dir": dir,
		"t0": _time,
		"sats": sats,
		"tone": 1 if _rng.randf() < 0.3 else 0,
	})
	if bool(drop["crown"]) or s < 2 or speed <= 260.0:
		return
	for k in _rng.randi_range(1, 3):
		_drops.append(_make_drop(
			float(drop["x"]), ground - 1.0,
			dir * _rng.randf_range(10.0, 130.0) + _rng.randf_range(-70.0, 70.0),
			-_rng.randf_range(80.0, 170.0),
			1, 0.0, 0.8, true))


func _ground_y(world_x: float) -> float:
	if _world == null:
		_world = get_tree().get_first_node_in_group("world_generator")
	if _world == null or not _world.has_method("ground_y_at"):
		return INF
	return float(_world.call("ground_y_at", world_x))


func _finished() -> bool:
	if _time <= 1.0 or not _drops.is_empty():
		return false
	for stain in _stains:
		if _time - float(stain["t0"]) <= STAIN_LIFE + 1.2:
			return false
	return true


# --- Drawing ----------------------------------------------------------------

func _draw_stains() -> void:
	for stain in _stains:
		var age := _time - float(stain["t0"])
		var fade := 1.0 - clampf((age - STAIN_LIFE) / 1.2, 0.0, 1.0)
		if fade <= 0.0:
			continue
		var spread := _smooth(0.0, 0.12, age)
		var width := float(stain["w"])
		var lean := float(stain["lean"])
		var dir := int(stain["dir"])
		var half := width * (0.55 + 0.45 * spread)
		var dry := mini(4, (1 if age < 0.35 else 2 if age < 1.4 else 3 if age < 3.2 else 4) + int(stain["tone"]))
		var body := _ramp[dry]
		var under := _ramp[mini(5, dry + 1)]
		var wx := float(stain["x"])
		var row := int(stain["y"])
		var left := wx - half * (1.0 - 0.3 * lean)
		var right := wx + half * (1.0 + 0.8 * lean)
		var lo := left if dir > 0 else 2.0 * wx - right
		var hi := right if dir > 0 else 2.0 * wx - left
		var x := floori(lo)
		while float(x) <= ceilf(hi):
			var q := absf(float(x) + 0.5 - wx) / maxf(0.5, (hi - lo) * 0.5)
			if fade < 1.0 and fade <= _bayer(x, row):
				x += 1
				continue
			_plot(float(x), float(row), under if q > 0.85 and width > 1.0 else body)
			if width > 1.6 and q < 0.6:
				_plot(float(x), float(row + 1), under)
			if width > 2.2 and q < 0.45:
				_plot(float(x), float(row - 1), _ramp[1] if q < 0.2 and age < 1.0 else body)
			x += 1
		if age < 0.4 and width > 1.0:
			_plot(wx - float(dir) * half * 0.3, float(row), _ramp[0])
		for sat in stain["sats"]:
			var sat_vec: Vector2 = sat
			var sx := wx + dir * (half * (1.0 + 0.6 * lean) + sat_vec.x * spread)
			if fade < 1.0 and fade <= _bayer(floori(sx), row):
				continue
			_plot(sx, float(row), body)
			if sat_vec.y > 1.5:
				_plot(sx + float(dir), float(row), under)


func _draw_strands() -> void:
	if _time >= STRAND_SECONDS:
		return
	var grow := _out_cubic(_time / 0.045)
	var broken := clampf((_time - 0.04) / 0.05, 0.0, 1.0)
	var wx := global_position.x
	var wy := global_position.y
	for strand in _strands:
		var length := float(strand["l"]) * grow
		var start := length * broken
		var ca := cos(float(strand["a"]))
		var sa := sin(float(strand["a"]))
		for pass_index in 3:
			var d := start
			while d <= length:
				var u := d / maxf(1.0, length)
				var r := float(strand["w"]) * pow(1.0 - u, 0.6) * (1.0 - broken * 0.5) + (0.5 if u > 0.85 else 0.0)
				if r >= 0.35:
					var x := wx + ca * d
					var y := wy + sa * d
					if pass_index == 0:
						_disc(x, y, r + 0.7, _ramp[4])
					elif pass_index == 1:
						_disc(x, y, r, _ramp[1] if d < length * 0.35 else _ramp[2])
					elif d < length * 0.5 and r > 0.9:
						_plot(roundf(x - sa * r * 0.4), roundf(y + ca * r * 0.4 - 0.4), _ramp[0])
				d += 0.5
	if _time < 0.035:
		_disc(wx, wy, 2.6 * size, _ramp[1])
		_disc(wx, wy, 1.5 * size, _ramp[0])


func _draw_mist() -> void:
	for puff in _mist:
		if float(puff["t0"]) > 0.0:
			continue
		var k := float(puff["life"]) / maxf(0.001, float(puff["max"]))
		_alpha_disc(
			float(puff["x"]), float(puff["y"]),
			float(puff["r"]) * (1.6 - 0.6 * k),
			_ramp[3], 0.4 * k * minf(1.0, (1.0 - k) * 8.0))


func _draw_drips() -> void:
	var wx := global_position.x
	var wy := global_position.y
	for drip in _drips:
		var u := _time - float(drip["t0"])
		if u < 0.0 or u > 1.6:
			continue
		var run := minf(3.0, 3.0 * _smooth(0.0, 0.18, u))
		var fade := 1.0 - clampf((u - 1.0) / 0.6, 0.0, 1.0)
		var drop_color := Color(_ramp[3], fade)
		var k := 0
		while float(k) <= run:
			_plot(wx, wy + float(k), drop_color)
			k += 1
		if bool(drip["fell"]):
			continue
		_plot(wx, wy + run + 1.0, _ramp[2])
		if _smooth(0.0, 0.2, u) > 0.6:
			_plot(wx + 1.0, wy + run + 1.0, _ramp[3])
			_plot(wx, wy + run + 2.0, _ramp[2])
			_plot(wx, wy + run + 1.0, _ramp[0])


func _draw_drops() -> void:
	for drop in _drops:
		if float(drop["delay"]) > 0.0:
			continue
		var x := float(drop["x"])
		var y := float(drop["y"])
		var vx := float(drop["vx"])
		var vy := float(drop["vy"])
		var speed := sqrt(vx * vx + vy * vy)
		if speed <= 0.001:
			speed = 1.0
		var ux := vx / speed
		var uy := vy / speed
		var tail := minf(6.0, speed * 0.008)
		if tail >= 1.0:
			_line(x - ux * tail, y - uy * tail, x - ux, y - uy, _ramp[2] if int(drop["s"]) >= 2 else _ramp[3])
		match int(drop["s"]):
			3:
				_disc(x, y, 1.7, _ramp[4])
				_disc(x, y, 1.15, _ramp[1])
				_plot(roundf(x - 0.7), roundf(y - 0.7), _ramp[0])
			2:
				var px := floori(x)
				var py := floori(y)
				_plot(float(px), float(py), _ramp[0])
				_plot(float(px + 1), float(py), _ramp[1])
				_plot(float(px), float(py + 1), _ramp[2])
				_plot(float(px + 1), float(py + 1), _ramp[3])
			_:
				_plot(float(floori(x)), float(floori(y)), _ramp[1] if float(drop["seed"]) < 0.5 else _ramp[2])


# --- Pixel canvas -----------------------------------------------------------

func _plot(world_x: float, world_y: float, color: Color) -> void:
	_set_cell(floori(world_x - _origin.x), floori(world_y - _origin.y), color)


func _set_cell(x: int, y: int, color: Color) -> void:
	if x < 0 or y < 0 or x >= CANVAS_SIZE.x or y >= CANVAS_SIZE.y:
		return
	_image.set_pixel(x, y, color)


func _disc(world_x: float, world_y: float, radius: float, color: Color) -> void:
	var cx := world_x - _origin.x
	var cy := world_y - _origin.y
	if radius <= 0.5:
		_set_cell(roundi(cx), roundi(cy), color)
		return
	var r2 := radius * radius
	var y := floori(cy - radius)
	while float(y) <= ceilf(cy + radius):
		var dy := float(y) + 0.5 - cy
		var x := floori(cx - radius)
		while float(x) <= ceilf(cx + radius):
			var dx := float(x) + 0.5 - cx
			if dx * dx + dy * dy <= r2:
				_set_cell(x, y, color)
			x += 1
		y += 1


func _alpha_disc(world_x: float, world_y: float, radius: float, color: Color, alpha: float) -> void:
	if alpha <= 0.01 or radius <= 0.0:
		return
	var cx := world_x - _origin.x
	var cy := world_y - _origin.y
	var r2 := radius * radius
	var y := floori(cy - radius)
	while float(y) <= ceilf(cy + radius):
		var dy := float(y) + 0.5 - cy
		var x := floori(cx - radius)
		while float(x) <= ceilf(cx + radius):
			var dx := float(x) + 0.5 - cx
			if dx * dx + dy * dy <= r2:
				_blend_cell(x, y, color, alpha)
			x += 1
		y += 1


func _line(x0: float, y0: float, x1: float, y1: float, color: Color) -> void:
	var ax := roundi(x0 - _origin.x)
	var ay := roundi(y0 - _origin.y)
	var bx := roundi(x1 - _origin.x)
	var by := roundi(y1 - _origin.y)
	var dx := absi(bx - ax)
	var dy := -absi(by - ay)
	var sx := 1 if ax < bx else -1
	var sy := 1 if ay < by else -1
	var err := dx + dy
	for i in 4096:
		_set_cell(ax, ay, color)
		if ax == bx and ay == by:
			break
		var e2 := 2 * err
		if e2 >= dy:
			err += dy
			ax += sx
		if e2 <= dx:
			err += dx
			ay += sy


func _blend_cell(x: int, y: int, color: Color, alpha: float) -> void:
	if alpha <= 0.01 or x < 0 or y < 0 or x >= CANVAS_SIZE.x or y >= CANVAS_SIZE.y:
		return
	var dst := _image.get_pixel(x, y)
	var out_a := alpha + dst.a * (1.0 - alpha)
	if out_a <= 0.0:
		return
	var k := alpha / out_a
	_image.set_pixel(x, y, Color(
		color.r * k + dst.r * (1.0 - k),
		color.g * k + dst.g * (1.0 - k),
		color.b * k + dst.b * (1.0 - k),
		out_a))


# --- Helpers ----------------------------------------------------------------

func _make_ramp() -> Array[Color]:
	var ramp: Array[Color] = []
	ramp.append(blood_color.lightened(0.55))
	ramp.append(blood_color.lightened(0.12))
	ramp.append(blood_color)
	ramp.append(blood_color.darkened(0.22))
	ramp.append(blood_color.darkened(0.45))
	ramp.append(blood_color.darkened(0.65))
	return ramp


func _bayer(x: int, y: int) -> float:
	return (float(BAYER[((y & 3) << 2) | (x & 3)]) + 0.5) / 16.0


func _smooth(edge0: float, edge1: float, value: float) -> float:
	var t := clampf((value - edge0) / (edge1 - edge0), 0.0, 1.0)
	return t * t * (3.0 - 2.0 * t)


func _out_cubic(value: float) -> float:
	return 1.0 - pow(1.0 - clampf(value, 0.0, 1.0), 3.0)
