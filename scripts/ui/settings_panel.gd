class_name SettingsPanel
extends PanelContainer

# ==============================================================================
# SETTINGS PANEL (main menu and pause menu)
# ==============================================================================
# Only window options: mode and size. The stretch is always `integer` (a
# fractional factor changes the texel size of the nearest-filtered pixel art
# every frame and the parallax shimmers, see T-0010/T-0045), but instead of
# letterboxing the game viewport adapts to the window (`_apply_layout`): it is
# resized to `window size / factor`, so every art pixel is exactly `factor`
# screen pixels and the leftover space becomes more visible world. That gives
# 0 black bars at any resolution, which is how most pixel-art platformers fill
# fullscreen. The viewport never drops below 768x432 because the UI is built
# for it.

## Emitted when the panel closes itself (Back button or Esc).
signal closed

const SETTINGS_PATH := "user://settings.cfg"
## Base game viewport: the smallest one the UI fits in.
const VIEWPORT_SIZE := Vector2i(768, 432)
## `Window.content_scale_stretch` for integer scaling (0 is `fractional`).
const STRETCH_INTEGER := 1
## Window sizes offered in windowed mode; any of them fills the window exactly.
const WINDOW_SIZES: Array[Vector2i] = [
	Vector2i(1024, 576),
	Vector2i(1152, 648),
	Vector2i(1280, 720),
	Vector2i(1366, 768),
	Vector2i(1440, 810),
	Vector2i(1536, 864),
	Vector2i(1600, 900),
	Vector2i(1680, 1050),
	Vector2i(1920, 1080),
	Vector2i(1920, 1200),
	Vector2i(2048, 1152),
	Vector2i(2304, 1296),
	Vector2i(2560, 1440),
	Vector2i(2560, 1600),
	Vector2i(2880, 1620),
	Vector2i(3072, 1728),
	Vector2i(3440, 1440),
	Vector2i(3840, 2160),
]

enum WindowMode {
	WINDOWED,
	FULLSCREEN,
	BORDERLESS,
}

@onready var _window_mode_option: OptionButton = $Margin/Content/WindowModeRow/WindowMode
@onready var _window_mode_label: Label = $Margin/Content/WindowModeRow/WindowModeLabel
@onready var _resolution_option: OptionButton = $Margin/Content/ResolutionRow/Resolution
@onready var _resolution_label: Label = $Margin/Content/ResolutionRow/ResolutionLabel
@onready var _back_button: Button = $Margin/Content/Back

var _window_mode: int = WindowMode.WINDOWED
var _window_size: Vector2i = Vector2i(1536, 864)
## Sizes offered by the list: the ones that fit on this screen.
var _sizes: Array[Vector2i] = []


func _ready() -> void:
	_build_sizes()
	_load_settings()
	_build_options()
	_apply_window()
	_window_mode_option.item_selected.connect(_on_window_mode_selected)
	_resolution_option.item_selected.connect(_on_resolution_selected)
	_back_button.pressed.connect(_on_back)
	hide()
	_update_resolution_state()


func open() -> void:
	show()
	_back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()


func _on_back() -> void:
	hide()
	closed.emit()


# ==============================================================================
# WINDOW
# ==============================================================================
func _build_options() -> void:
	_window_mode_option.clear()
	_window_mode_option.add_item("Windowed", WindowMode.WINDOWED)
	_window_mode_option.add_item("Fullscreen", WindowMode.FULLSCREEN)
	_window_mode_option.add_item("Borderless fullscreen", WindowMode.BORDERLESS)
	var mode_index := _window_mode_option.get_item_index(_window_mode)
	_window_mode_option.select(mode_index if mode_index >= 0 else 0)

	_resolution_option.clear()
	for i in _sizes.size():
		var size: Vector2i = _sizes[i]
		_resolution_option.add_item("%d x %d" % [size.x, size.y], i)
	var size_index := _sizes.find(_window_size)
	if size_index < 0:
		size_index = mini(1, _sizes.size() - 1)
		_window_size = _sizes[size_index]
	_resolution_option.select(size_index)


func _build_sizes() -> void:
	_sizes.clear()
	var bounds := _screen_bounds()
	for size in WINDOW_SIZES:
		if size.x > bounds.x or size.y > bounds.y:
			continue
		_sizes.append(size)
	if _sizes.is_empty():
		_sizes.append(VIEWPORT_SIZE)


func _on_window_mode_selected(index: int) -> void:
	_window_mode = _window_mode_option.get_item_id(index)
	_apply_window()
	_update_resolution_state()
	_save_settings()


func _on_resolution_selected(index: int) -> void:
	if index < 0 or index >= _sizes.size():
		return
	_window_size = _sizes[index]
	if _window_mode == WindowMode.WINDOWED:
		DisplayServer.window_set_size(_window_size)
		_apply_layout(_window_size)
	_save_settings()


func _apply_window() -> void:
	match _window_mode:
		WindowMode.FULLSCREEN:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
			_apply_layout(DisplayServer.screen_get_size())
		WindowMode.BORDERLESS:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			_apply_layout(DisplayServer.screen_get_size())
		_:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			DisplayServer.window_set_size(_window_size)
			_apply_layout(_window_size)


## Fills `size` with no black bars and no fractional stretch: the viewport is
## resized to `size / factor`, with `factor` the largest whole pixel size that
## still leaves 768x432 for the UI. Every art pixel is then exactly `factor`
## screen pixels, so the texel size is constant and the parallax doesn't
## shimmer; the extra room becomes more visible world. At most `factor - 1` px
## is left over when the window size is not divisible.
func _apply_layout(size: Vector2i) -> void:
	var factor := _best_factor(size)
	var divisor := float(factor)
	var window := get_window()
	window.content_scale_size = Vector2i(floori(size.x / divisor), floori(size.y / divisor))
	window.content_scale_stretch = STRETCH_INTEGER


## Whole pixel factor for `size`, clamped so the viewport never drops below the
## base 768x432 (the UI is built for it).
func _best_factor(size: Vector2i) -> int:
	var factor := mini(
		floori(size.x / float(VIEWPORT_SIZE.x)),
		floori(size.y / float(VIEWPORT_SIZE.y))
	)
	return maxi(factor, 1)


## The resolution only means something in a window: fullscreen follows the screen.
func _update_resolution_state() -> void:
	var windowed := _window_mode == WindowMode.WINDOWED
	_resolution_option.disabled = not windowed
	_resolution_label.modulate.a = 1.0 if windowed else 0.5
	_window_mode_label.modulate.a = 1.0


func _screen_bounds() -> Vector2i:
	var rect := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
	if rect.size.x <= 0 or rect.size.y <= 0:
		return DisplayServer.screen_get_size()
	return rect.size


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	_window_mode = clampi(int(config.get_value("display", "window_mode", WindowMode.WINDOWED)), 0, WindowMode.size() - 1)
	var size := Vector2i(
		int(config.get_value("display", "width", 1536)),
		int(config.get_value("display", "height", 864))
	)
	if _sizes.has(size):
		_window_size = size


func _save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("display", "window_mode", _window_mode)
	config.set_value("display", "width", _window_size.x)
	config.set_value("display", "height", _window_size.y)
	config.save(SETTINGS_PATH)
