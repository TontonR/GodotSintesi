class_name GameSettings
extends Node

# ==============================================================================
# GAME SETTINGS (video, language and controls)
# ==============================================================================
# Owns the `[video]`, `[language]` and `[input]` sections of
# `user://settings.cfg`. The `[display]` section stays in SettingsPanel and the
# `[vfx]` toggles in VfxSettings; every writer loads the file before saving, so
# none of them replaces the other sections.
#
# It is a lazily created singleton instead of an autoload on purpose: the editor
# can be open while these files change, and a missing autoload identifier makes
# every script that references it fail to parse. `get_instance()` adds the node
# to the tree the first time a screen asks for it, so F5 picks everything up
# without reopening the project.
#
# Language is a plain dictionary, not `TranslationServer`: the UI is small and
# its texts already live in scenes and scripts. Labels carry a `locale_key`
# metadata and `localize_tree()` re-applies them after a switch; the screens
# rebuild their dynamic texts (slot summaries, shop rows, prompts) on
# `language_changed`.

## Emitted after the language changes and the static labels are refreshed.
signal language_changed
## Emitted when the graphics quality changes, so the particle emitters adapt.
signal quality_changed
## Emitted after a key is remapped or the defaults are restored.
signal input_changed
## Emitted when the debug tools of the settings panel are switched on or off.
signal debug_tools_changed(enabled: bool)

const SETTINGS_PATH := "user://settings.cfg"

enum Vsync { OFF, ON, ADAPTIVE }
enum Quality { LOW, HIGH }

## FPS caps offered in the panel; 0 means "no limit".
const FPS_LIMITS: Array[int] = [0, 30, 60, 120, 144]

## Remappable keys, in panel order. The slot is the index inside the action's
## key event list (movement is D then A, inventory is Tab then I).
const ACTION_SLOTS: Array[Dictionary] = [
	{"action": "movement", "slot": 0, "label": "controls.move_right"},
	{"action": "movement", "slot": 1, "label": "controls.move_left"},
	{"action": "interact", "slot": 0, "label": "controls.interact"},
	{"action": "inventory", "slot": 0, "label": "controls.inventory"},
	{"action": "inventory", "slot": 1, "label": "controls.inventory_alt"},
	{"action": "use_slot_1", "slot": 0, "label": "controls.slot_1"},
	{"action": "use_slot_2", "slot": 0, "label": "controls.slot_2"},
	{"action": "use_slot_3", "slot": 0, "label": "controls.slot_3"},
]

## English first, Spanish second. Format strings keep their `%` placeholders.
const TRANSLATIONS := {
	"settings.title": ["Settings", "Ajustes"],
	"settings.window_mode": ["Window mode", "Modo de ventana"],
	"settings.windowed": ["Windowed", "Ventana"],
	"settings.fullscreen": ["Fullscreen", "Pantalla completa"],
	"settings.borderless": ["Borderless fullscreen", "Pantalla completa sin bordes"],
	"settings.resolution": ["Resolution", "Resolución"],
	"settings.vsync": ["VSync", "VSync"],
	"settings.vsync_off": ["Off", "Desactivado"],
	"settings.vsync_on": ["On", "Activado"],
	"settings.vsync_adaptive": ["Adaptive", "Adaptativo"],
	"settings.fps": ["FPS limit", "Límite de FPS"],
	"settings.fps_unlimited": ["Unlimited", "Sin límite"],
	"settings.quality": ["Graphics quality", "Calidad gráfica"],
	"settings.quality_low": ["Low", "Baja"],
	"settings.quality_high": ["High", "Alta"],
	"settings.language": ["Language", "Idioma"],
	"settings.leaves": ["Leaf particles", "Partículas de hojas"],
	"settings.physics": ["Enhanced VFX physics", "Físicas VFX mejoradas"],
	"settings.debug_tools": ["Debug tools", "Herramientas de desarrollo"],
	"settings.controls": ["Controls", "Controles"],
	"settings.reset_keys": ["Reset keys", "Restaurar teclas"],
	"settings.press_key": ["Press a key…", "Pulsa una tecla…"],
	"settings.back": ["Back", "Volver"],
	"controls.move_right": ["Move right", "Mover a la derecha"],
	"controls.move_left": ["Move left", "Mover a la izquierda"],
	"controls.interact": ["Interact", "Interactuar"],
	"controls.inventory": ["Inventory", "Inventario"],
	"controls.inventory_alt": ["Inventory (2nd)", "Inventario (2.ª)"],
	"controls.slot_1": ["Slot 1", "Hueco 1"],
	"controls.slot_2": ["Slot 2", "Hueco 2"],
	"controls.slot_3": ["Slot 3", "Hueco 3"],
	"menu.new_game": ["New Game", "Nueva partida"],
	"menu.continue": ["Continue", "Continuar"],
	"menu.load": ["Load", "Cargar"],
	"menu.settings": ["Settings", "Ajustes"],
	"menu.quit": ["Quit", "Salir"],
	"menu.new_world": ["New world", "Mundo nuevo"],
	"menu.seed_label": ["World seed (empty = random)", "Semilla del mundo (vacío = aleatoria)"],
	"menu.empty_random": ["Empty = random", "Vacío = aleatoria"],
	"menu.back": ["Back", "Volver"],
	"menu.start": ["Start", "Empezar"],
	"menu.load_run": ["Load run", "Cargar partida"],
	"menu.overwrite_run": [
		"No free slots — overwrite which run?",
		"Sin huecos libres — ¿qué partida sobrescribir?",
	],
	"menu.erase": ["Erase", "Borrar"],
	"menu.slot_empty": ["Slot %d — Empty", "Hueco %d — Vacío"],
	"menu.slot_summary": ["Slot %d — %d m · %d coins", "Hueco %d — %d m · %d monedas"],
	"pause.title": ["Paused", "En pausa"],
	"pause.resume": ["Resume", "Reanudar"],
	"pause.settings": ["Settings", "Ajustes"],
	"pause.save_quit": ["Save and quit", "Guardar y salir"],
	"death.title": ["You died", "Has muerto"],
	"death.subtitle": ["The run is over.", "La partida ha terminado."],
	"death.stats": ["Seed %d · %d coins", "Semilla %d · %d monedas"],
	"death.menu": ["Main menu", "Menú principal"],
	"death.quit": ["Quit", "Salir"],
	"inv.consumables": ["Consumables", "Consumibles"],
	"inv.collectibles": ["Collectibles", "Coleccionables"],
	"inv.page": ["Page %d/%d", "Página %d/%d"],
	"shop.title": ["Merchant", "Mercader"],
	"shop.coins": ["%d coins", "%d monedas"],
	"shop.hint": [
		"W/S pick · E buy · F leave",
		"W/S elegir · E comprar · F salir",
	],
	"shop.sold_out": ["Sold out", "Agotado"],
	"shop.no_coins": ["Not enough coins", "Sin monedas suficientes"],
	"shop.no_slot": ["No free slot", "Sin hueco libre"],
	"shop.bought": ["Bought %s", "Comprado %s"],
	"shop.sold": ["sold", "vendido"],
	"prompt.enter": ["F: enter", "F: entrar"],
	"prompt.exit": ["F: exit", "F: salir"],
	"prompt.shop": ["F: shop", "F: tienda"],
	"hud.page": ["Page %d/%d", "Página %d/%d"],
	"stats.damage": ["Damage", "Daño"],
	"stats.attack_speed": ["Atk. speed", "Vel. ataque"],
	"stats.crit_damage": ["Crit. damage", "Daño crítico"],
	"stats.crit_chance": ["Crit. chance", "Prob. crítico"],
	"stats.speed": ["Speed", "Velocidad"],
	"stats.luck": ["Luck", "Suerte"],
}

## Lazily created node, shared by every screen.
static var _instance: GameSettings = null

## VSync mode (see the `Vsync` enum).
var vsync_mode: int = Vsync.ON
## `Engine.max_fps`; 0 = unlimited.
var fps_limit: int = 0
## Particle budget of the ambient and combat effects.
var quality: int = Quality.HIGH
## "en" or "es".
var language: String = "en"
## Numpad debug tools and their notice. Off in a normal run: the settings panel
## is the switch (T-0107).
var debug_tools: bool = false

## Key codes from `project.godot`, captured before any override is applied.
var _defaults: Dictionary = {}
## Remapped key codes per action, only for the actions the player changed.
var _overrides: Dictionary = {}


func _ready() -> void:
	# Defaults first: loading the file must not overwrite the project bindings.
	_capture_default_bindings()
	_load_settings()
	_apply_video()
	_apply_all_bindings()
	# A run started in Spanish must not wait for a language switch to show it.
	localize_tree(get_tree().root if is_inside_tree() else null)


## The shared node, created on first use. Safe to call before the scene tree is
## ready (returns a detached instance in that case).
static func get_instance() -> GameSettings:
	if is_instance_valid(_instance):
		return _instance
	var tree := Engine.get_main_loop() as SceneTree
	if tree == null or tree.root == null:
		_instance = GameSettings.new()
		return _instance
	_instance = tree.root.get_node_or_null("GameSettings") as GameSettings
	if _instance == null:
		_instance = GameSettings.new()
		_instance.name = "GameSettings"
		tree.root.add_child(_instance)
	return _instance


# ==============================================================================
# VIDEO
# ==============================================================================
func set_vsync_mode(mode: int) -> void:
	vsync_mode = clampi(mode, Vsync.OFF, Vsync.ADAPTIVE)
	_apply_vsync()
	_save_settings()


func set_fps_limit(limit: int) -> void:
	if not FPS_LIMITS.has(limit):
		limit = 0
	fps_limit = limit
	Engine.max_fps = fps_limit
	_save_settings()


## Turns the numpad debug tools on or off while the game runs.
func set_debug_tools(enabled: bool) -> void:
	if enabled == debug_tools:
		return
	debug_tools = enabled
	_save_settings()
	debug_tools_changed.emit(debug_tools)


func set_quality(value: int) -> void:
	value = clampi(value, Quality.LOW, Quality.HIGH)
	if value == quality:
		return
	quality = value
	_save_settings()
	quality_changed.emit()


## Multiplier the emitters apply to their particle counts (T-0101).
func particle_scale() -> float:
	return 0.5 if quality == Quality.LOW else 1.0


func _apply_video() -> void:
	_apply_vsync()
	Engine.max_fps = fps_limit


func _apply_vsync() -> void:
	var mode := DisplayServer.VSYNC_ENABLED
	match vsync_mode:
		Vsync.OFF:
			mode = DisplayServer.VSYNC_DISABLED
		Vsync.ADAPTIVE:
			mode = DisplayServer.VSYNC_ADAPTIVE
	DisplayServer.window_set_vsync_mode(mode)


# ==============================================================================
# LANGUAGE
# ==============================================================================
func set_language(value: String) -> void:
	var target := "es" if value == "es" else "en"
	if target == language:
		return
	language = target
	_save_settings()
	localize_tree(get_tree().root if is_inside_tree() else null)
	language_changed.emit()


## Translated text for `key` in the current language.
func tr_key(key: String) -> String:
	var entry: Array = TRANSLATIONS.get(key, [])
	if entry.is_empty():
		return key
	return String(entry[1] if language == "es" else entry[0])


## Re-applies every `locale_key` metadata in the tree. Static labels in the
## scenes carry the key, so a switch updates them without extra wiring.
func localize_tree(root: Node) -> void:
	if root == null:
		return
	if root.has_meta("locale_key"):
		var key := str(root.get_meta("locale_key"))
		if "text" in root:
			root.set("text", tr_key(key))
	if root is LineEdit and root.has_meta("locale_placeholder"):
		root.placeholder_text = tr_key(str(root.get_meta("locale_placeholder")))
	for child in root.get_children():
		localize_tree(child)


# ==============================================================================
# CONTROLS
# ==============================================================================
## Key codes of `action` in the current layout (overrides first).
func action_keys(action: String) -> Array:
	if _overrides.has(action):
		var override: Array = _overrides[action]
		return override
	if _defaults.has(action):
		var defaults: Array = _defaults[action]
		return defaults
	return []


## Printable label of the key bound to `action`/`slot`.
func action_key_text(action: String, slot: int) -> String:
	var keys := action_keys(action)
	if slot < 0 or slot >= keys.size():
		return "—"
	var code := int(keys[slot])
	return "—" if code == 0 else OS.get_keycode_string(code)


## Rebinds one key. The same code is removed from the other slots of the action,
## so movement can never end up with both directions on the same key.
func set_action_key(action: String, slot: int, keycode: int) -> void:
	if keycode == 0 or not _defaults.has(action):
		return
	var keys: Array = action_keys(action).duplicate()
	while keys.size() <= slot:
		keys.append(0)
	for i in keys.size():
		if i != slot and int(keys[i]) == keycode:
			keys[i] = 0
	keys[slot] = keycode
	_overrides[action] = keys
	_apply_action(action)
	_save_settings()
	input_changed.emit()


## Back to the keys defined in `project.godot`.
func reset_action_keys() -> void:
	_overrides.clear()
	_apply_all_bindings()
	_save_settings()
	input_changed.emit()


func _capture_default_bindings() -> void:
	_defaults.clear()
	for entry in ACTION_SLOTS:
		var action := String(entry["action"])
		if _defaults.has(action):
			continue
		var keys: Array[int] = []
		for event in InputMap.action_get_events(action):
			var key_event := event as InputEventKey
			if key_event != null:
				keys.append(_keycode_of(key_event))
		_defaults[action] = keys


func _keycode_of(event: InputEventKey) -> int:
	return event.physical_keycode if event.physical_keycode != 0 else event.keycode


func _apply_all_bindings() -> void:
	for action in _defaults.keys():
		_apply_action(String(action))


func _apply_action(action: String) -> void:
	if not InputMap.has_action(action):
		return
	InputMap.action_erase_events(action)
	for value in action_keys(action):
		var code := int(value)
		if code == 0:
			continue
		var event := InputEventKey.new()
		event.physical_keycode = code
		InputMap.action_add_event(action, event)


# ==============================================================================
# PERSISTENCE
# ==============================================================================
func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	vsync_mode = clampi(
		int(config.get_value("video", "vsync", vsync_mode)), Vsync.OFF, Vsync.ADAPTIVE
	)
	fps_limit = int(config.get_value("video", "fps_limit", fps_limit))
	if not FPS_LIMITS.has(fps_limit):
		fps_limit = 0
	quality = clampi(int(config.get_value("video", "quality", quality)), Quality.LOW, Quality.HIGH)
	var stored_language := str(config.get_value("language", "locale", language))
	language = "es" if stored_language == "es" else "en"
	debug_tools = bool(config.get_value("debug", "tools", debug_tools))
	var bindings: Dictionary = config.get_value("input", "bindings", {})
	_overrides = bindings


func _save_settings() -> void:
	var config := ConfigFile.new()
	# Keep `[display]` (SettingsPanel) and `[vfx]` (VfxSettings).
	config.load(SETTINGS_PATH)
	config.set_value("video", "vsync", vsync_mode)
	config.set_value("video", "fps_limit", fps_limit)
	config.set_value("video", "quality", quality)
	config.set_value("language", "locale", language)
	config.set_value("input", "bindings", _overrides)
	config.set_value("debug", "tools", debug_tools)
	config.save(SETTINGS_PATH)
