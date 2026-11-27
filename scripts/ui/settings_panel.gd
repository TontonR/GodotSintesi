class_name SettingsPanel
extends PanelContainer

# ==============================================================================
# SETTINGS PANEL (main menu and pause menu)
# ==============================================================================
# Two columns: video (window, resolution, VSync, FPS cap, graphics quality and
# the VFX toggles) and the language plus the key remapping. Everything applies
# immediately and is stored in `user://settings.cfg`:
#   - `[display]` here (window mode and size),
#   - `[video]` / `[language]` / `[input]` in the `GameSettings` singleton,
#   - `[vfx]` in `VfxSettings`.
# Each writer loads the file before saving so the sections never overwrite each
# other.
#
# The stretch is always `integer` (a fractional factor changes the texel size of
# the nearest-filtered pixel art every frame and the parallax shimmers, see
# T-0010/T-0045); instead of letterboxing, the game viewport adapts to the
# window (`_apply_layout`), so every art pixel is exactly `factor` screen pixels
# and the leftover space becomes more visible world. The viewport never drops
# below 768x432 because the UI is built for it.

## Emitted when the panel closes itself (Back button or Esc).
signal closed

const SETTINGS_PATH := "user://settings.cfg"
const VFX_SETTINGS_SCRIPT := preload("res://scripts/vfx_settings.gd")
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
## Option labels, translated when the panel redraws its lists.
const VSYNC_KEYS: Array[String] = [
	"settings.vsync_off", "settings.vsync_on", "settings.vsync_adaptive"
]
const QUALITY_KEYS: Array[String] = ["settings.quality_low", "settings.quality_high"]

enum WindowMode {
	WINDOWED,
	FULLSCREEN,
	BORDERLESS,
}

@onready var _window_mode_option: OptionButton = $Margin/Content/Columns/Video/WindowModeRow/WindowMode
@onready var _window_mode_label: Label = $Margin/Content/Columns/Video/WindowModeRow/WindowModeLabel
@onready var _resolution_option: OptionButton = $Margin/Content/Columns/Video/ResolutionRow/Resolution
@onready var _resolution_label: Label = $Margin/Content/Columns/Video/ResolutionRow/ResolutionLabel
@onready var _vsync_option: OptionButton = $Margin/Content/Columns/Video/VsyncRow/Vsync
@onready var _fps_option: OptionButton = $Margin/Content/Columns/Video/FpsRow/Fps
@onready var _quality_option: OptionButton = $Margin/Content/Columns/Video/QualityRow/Quality
@onready var _language_option: OptionButton = $Margin/Content/Columns/Gameplay/LanguageRow/Language
@onready var _leaves_check: CheckButton = $Margin/Content/Columns/Video/LeavesRow/Leaves
@onready var _physics_check: CheckButton = $Margin/Content/Columns/Video/PhysicsRow/Physics
@onready var _debug_check: CheckButton = $Margin/Content/Columns/Video/DebugRow/Debug
@onready var _controls: VBoxContainer = $Margin/Content/Columns/Gameplay/ControlsScroll/Controls
@onready var _reset_button: Button = $Margin/Content/Columns/Gameplay/ResetControls
@onready var _back_button: Button = $Margin/Content/Back

var _window_mode: int = WindowMode.WINDOWED
var _window_size: Vector2i = Vector2i(1536, 864)
## Sizes offered by the list: the ones that fit on this screen.
var _sizes: Array[Vector2i] = []
var _vfx_settings: Node
## Key capture in progress (`""` when idle).
var _capture_action: String = ""
var _capture_slot: int = -1
var _capture_button: Button


func _ready() -> void:
	_build_sizes()
	_load_settings()
	_build_options()
	_build_controls()
	_apply_window()
	_window_mode_option.item_selected.connect(_on_window_mode_selected)
	_resolution_option.item_selected.connect(_on_resolution_selected)
	_vsync_option.item_selected.connect(_on_vsync_selected)
	_fps_option.item_selected.connect(_on_fps_selected)
	_quality_option.item_selected.connect(_on_quality_selected)
	_language_option.item_selected.connect(_on_language_selected)
	_leaves_check.toggled.connect(_on_leaves_toggled)
	_physics_check.toggled.connect(_on_physics_toggled)
	_debug_check.toggled.connect(_on_debug_toggled)
	_reset_button.pressed.connect(_on_reset_controls)
	_back_button.pressed.connect(_on_back)
	var settings := _get_settings()
	settings.language_changed.connect(_on_language_changed)
	settings.input_changed.connect(_on_input_changed)
	settings.quality_changed.connect(_sync_quality)
	settings.localize_tree(self)
	hide()
	_update_resolution_state()


## Resolves the settings singleton at runtime instead of relying on an autoload
## identifier (same reason as `_get_vfx_settings`).
func _get_settings() -> GameSettings:
	return GameSettings.get_instance()


## Resolves the settings singleton at runtime instead of relying on the autoload
## identifier. The fallback keeps the toggles working while the editor has not
## reloaded an externally edited `project.godot` (T-0096).
func _get_vfx_settings() -> Node:
	if is_instance_valid(_vfx_settings):
		return _vfx_settings
	var tree := get_tree()
	if tree == null:
		return null
	_vfx_settings = tree.root.get_node_or_null("VfxSettings")
	if _vfx_settings == null:
		_vfx_settings = VFX_SETTINGS_SCRIPT.new()
		_vfx_settings.name = "VfxSettings"
		tree.root.add_child(_vfx_settings)
	return _vfx_settings


func open() -> void:
	show()
	_back_button.grab_focus()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	# While capturing, the next key is the binding: Esc cancels.
	if not _capture_action.is_empty():
		var key_event := event as InputEventKey
		if key_event == null or not key_event.pressed or key_event.echo:
			return
		var code := key_event.physical_keycode
		if code == 0:
			code = key_event.keycode
		if code != KEY_ESCAPE:
			_get_settings().set_action_key(_capture_action, _capture_slot, code)
		_cancel_capture()
		get_viewport().set_input_as_handled()
		return
	if event.is_action_pressed("ui_cancel"):
		_on_back()
		get_viewport().set_input_as_handled()


func _on_back() -> void:
	_cancel_capture()
	hide()
	closed.emit()


# ==============================================================================
# OPTIONS
# ==============================================================================
func _build_options() -> void:
	var settings := _get_settings()
	_window_mode_option.clear()
	_window_mode_option.add_item(settings.tr_key("settings.windowed"), WindowMode.WINDOWED)
	_window_mode_option.add_item(settings.tr_key("settings.fullscreen"), WindowMode.FULLSCREEN)
	_window_mode_option.add_item(settings.tr_key("settings.borderless"), WindowMode.BORDERLESS)
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

	_vsync_option.clear()
	for i in VSYNC_KEYS.size():
		_vsync_option.add_item(settings.tr_key(VSYNC_KEYS[i]), i)
	_vsync_option.select(clampi(settings.vsync_mode, 0, VSYNC_KEYS.size() - 1))

	_fps_option.clear()
	for limit in GameSettings.FPS_LIMITS:
		var text := settings.tr_key("settings.fps_unlimited") if limit == 0 else "%d" % limit
		_fps_option.add_item(text, limit)
	var fps_index := GameSettings.FPS_LIMITS.find(settings.fps_limit)
	_fps_option.select(fps_index if fps_index >= 0 else 0)

	_quality_option.clear()
	for i in QUALITY_KEYS.size():
		_quality_option.add_item(settings.tr_key(QUALITY_KEYS[i]), i)
	_quality_option.select(clampi(settings.quality, 0, QUALITY_KEYS.size() - 1))

	_language_option.clear()
	_language_option.add_item("English", 0)
	_language_option.add_item("Español", 1)
	_language_option.select(1 if settings.language == "es" else 0)

	# Set the state before connecting, so opening the panel never writes.
	var vfx := _get_vfx_settings()
	if vfx != null:
		_leaves_check.button_pressed = bool(vfx.get("leaves_enabled"))
		_physics_check.button_pressed = bool(vfx.get("enhanced_vfx_physics"))
	_debug_check.button_pressed = settings.debug_tools


## One row per remappable key; rebuilt after a remap or a language change.
func _build_controls() -> void:
	for child in _controls.get_children():
		_controls.remove_child(child)
		child.queue_free()
	_capture_button = null
	_capture_action = ""
	var settings := _get_settings()
	for entry in GameSettings.ACTION_SLOTS:
		var action := String(entry["action"])
		var slot := int(entry["slot"])
		var row := HBoxContainer.new()
		row.add_theme_constant_override("separation", 6)
		_controls.add_child(row)
		var label := Label.new()
		label.text = settings.tr_key(String(entry["label"]))
		label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		label.add_theme_font_size_override("font_size", 13)
		row.add_child(label)
		var button := Button.new()
		button.custom_minimum_size = Vector2(96, 22)
		button.focus_mode = Control.FOCUS_NONE
		button.add_theme_font_size_override("font_size", 13)
		button.text = settings.action_key_text(action, slot)
		button.pressed.connect(_capture_key.bind(action, slot, button))
		row.add_child(button)


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


func _on_vsync_selected(index: int) -> void:
	_get_settings().set_vsync_mode(_vsync_option.get_item_id(index))


func _on_fps_selected(index: int) -> void:
	_get_settings().set_fps_limit(_fps_option.get_item_id(index))


func _on_quality_selected(index: int) -> void:
	_get_settings().set_quality(_quality_option.get_item_id(index))


func _on_language_selected(index: int) -> void:
	_get_settings().set_language("es" if index == 1 else "en")


func _on_leaves_toggled(pressed: bool) -> void:
	var vfx := _get_vfx_settings()
	if vfx != null:
		vfx.call("set_leaves_enabled", pressed)


func _on_physics_toggled(pressed: bool) -> void:
	var vfx := _get_vfx_settings()
	if vfx != null:
		vfx.call("set_enhanced_vfx_physics", pressed)


## Numpad debug tools (T-0107): off by default and switched from here instead
## of being deleted. Saved and applied live by `DebugTools`.
func _on_debug_toggled(pressed: bool) -> void:
	_get_settings().set_debug_tools(pressed)


# ==============================================================================
# KEY CAPTURE
# ==============================================================================
func _capture_key(action: String, slot: int, button: Button) -> void:
	_capture_action = action
	_capture_slot = slot
	_capture_button = button
	button.text = _get_settings().tr_key("settings.press_key")


func _cancel_capture() -> void:
	if is_instance_valid(_capture_button):
		_capture_button.text = _get_settings().action_key_text(_capture_action, _capture_slot)
	_capture_action = ""
	_capture_slot = -1
	_capture_button = null


func _on_reset_controls() -> void:
	_get_settings().reset_action_keys()
	_build_controls()


func _on_input_changed() -> void:
	_build_controls()


func _on_language_changed() -> void:
	# The static labels are refreshed by GameSettings; the option items and the
	# remap rows are built in code, so they are rebuilt here.
	_build_options()
	_build_controls()


func _sync_quality() -> void:
	_quality_option.select(clampi(_get_settings().quality, 0, QUALITY_KEYS.size() - 1))


# ==============================================================================
# WINDOW
# ==============================================================================
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
	# Keep the `[vfx]` (VfxSettings) and `[video]`/`[language]`/`[input]`
	# (GameSettings) sections.
	config.load(SETTINGS_PATH)
	config.set_value("display", "window_mode", _window_mode)
	config.set_value("display", "width", _window_size.x)
	config.set_value("display", "height", _window_size.y)
	config.save(SETTINGS_PATH)
