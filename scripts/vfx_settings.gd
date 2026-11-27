extends Node

# ==============================================================================
# VFX SETTINGS (autoload)
# ==============================================================================
# Shared by SettingsPanel and the ambient emitters. The panel edits the display
# section; this singleton owns the `[vfx]` section of the same file, so both
# write through a load-modify-save instead of replacing the other section.

## Emitted after any VFX toggle changes, so the live effects can react.
signal changed

const SETTINGS_PATH := "user://settings.cfg"

## Leaves from trees, bushes and the ground litter.
var leaves_enabled := true
## Fancier leaf motion: gravity, bounces, spin and stronger impulses.
var enhanced_vfx_physics := true


func _ready() -> void:
	_load_settings()


func set_leaves_enabled(enabled: bool) -> void:
	if leaves_enabled == enabled:
		return
	leaves_enabled = enabled
	_save_settings()
	changed.emit()


func set_enhanced_vfx_physics(enabled: bool) -> void:
	if enhanced_vfx_physics == enabled:
		return
	enhanced_vfx_physics = enabled
	_save_settings()
	changed.emit()


func _load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) != OK:
		return
	leaves_enabled = bool(config.get_value("vfx", "leaves", true))
	enhanced_vfx_physics = bool(config.get_value("vfx", "enhanced_physics", true))


func _save_settings() -> void:
	var config := ConfigFile.new()
	# Keep the display section written by SettingsPanel.
	config.load(SETTINGS_PATH)
	config.set_value("vfx", "leaves", leaves_enabled)
	config.set_value("vfx", "enhanced_physics", enhanced_vfx_physics)
	config.save(SETTINGS_PATH)
