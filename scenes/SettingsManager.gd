# SettingsManager.gd
extends Node

# Handles loading, changing, and persisting the settings.
# This script will be auto-loaded, so any settings changes should come through
# here, not directly, e.g. SettingsManager.apply_volume_setting("Master", "1.0")
# vs AudioServer.set_bus_volume_linear("Master", 1.0)
# Settings will take effect in real time but to be persisted,
# SettingsManager.save_settings() must be invoked.

signal ben_mode_changed
signal touch_controls_changed

# Default Settings dict for easy twiddling
const DEFAULT_SETTINGS := {
	"audio": {
		"master_volume": 1.0, 
		"music_volume": 1.0,
		"sfx_volume": 1.0,
		"ben_mode": true,
	},
	"video": {
		"fullscreen": false,
		"vsync": false,
	},
	"controls": {
		"touch_controls": true,
	},
}
const BUSSES := ["Master", "Music", "SFX"]
const SETTINGS_FILE_PATH := "user://game_settings.cfg"

var config = ConfigFile.new()
var _ben_mode: bool
var _touch_controls: bool

func _ready():
	print("User Data Path: " + OS.get_user_data_dir())
	load_settings()

func load_settings():
	var error = config.load(SETTINGS_FILE_PATH)
	if error != OK:
		# If the file doesn't exist, create & save one with default values
		print("Settings file not found. creating default Settings file.")
		apply_defaults()
		save_settings()
		return
	
	# Audio
	var master_vol = config.get_value("Audio", "master_volume", DEFAULT_SETTINGS.audio.master_volume)
	apply_volume_setting("Master", master_vol)
	
	var music_vol = config.get_value("Audio", "music_volume", DEFAULT_SETTINGS.audio.music_volume)
	apply_volume_setting("Music", music_vol)
	
	var sfx_vol = config.get_value("Audio", "sfx_volume", DEFAULT_SETTINGS.audio.sfx_volume)
	apply_volume_setting("SFX", sfx_vol)
	
	_ben_mode = config.get_value("Audio", "ben_mode", DEFAULT_SETTINGS.audio.ben_mode)

	# Video
	var fullscreen = config.get_value("Video", "fullscreen", DEFAULT_SETTINGS.video.fullscreen)
	apply_fullscreen_setting(fullscreen)
	
	var vsync = config.get_value("Video", "vsync", DEFAULT_SETTINGS.video.vsync)
	apply_vsync_setting(vsync)
	
	# Controls
	var touch_controls = config.get_value("Controls", "touch_controls", DEFAULT_SETTINGS.controls.touch_controls)
	
	print("Applied settings: master: " + str(master_vol) + ", music: " + 
		str(music_vol) + ", sfx: " + str(sfx_vol) + ", fullscreen: " +
		str(fullscreen) + ", vsync: " + str(vsync) + ", touch_controls: " + str(touch_controls))

func apply_volume_setting(bus: String, linear_value: float):
	var index = AudioServer.get_bus_index(bus)
	if index != -1:
		AudioServer.set_bus_volume_linear(index, linear_value)

func apply_ben_mode(on: bool):
	_ben_mode = on
	ben_mode_changed.emit()

func apply_fullscreen_setting(on):
	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN if on
		 else DisplayServer.WINDOW_MODE_WINDOWED)

func apply_vsync_setting(on):
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if on
		else DisplayServer.VSYNC_DISABLED)

func apply_touch_controls(on):
	_touch_controls = on
	touch_controls_changed.emit(on)

func save_settings():
	# Persist the current state of settings to the ConfigFile object
	# Audio
	for bus in BUSSES:
		var index = AudioServer.get_bus_index(bus)
		var volume = AudioServer.get_bus_volume_linear(index)
		config.set_value("Audio", bus.to_lower() + "_volume", volume)
	config.set_value("Audio", "ben_mode", _ben_mode)
	
	# Video
	config.set_value("Video", "fullscreen", DisplayServer.WINDOW_MODE_FULLSCREEN
			 == DisplayServer.window_get_mode())
	config.set_value("Video", "vsync", DisplayServer.VSYNC_ENABLED
			 == DisplayServer.window_get_vsync_mode())

	# Controls
	config.set_value("Controls", "touch_controls", _touch_controls)

	# Dump the config object to the disk
	var error = config.save(SETTINGS_FILE_PATH)
	if error != OK:
		push_error("Could not save settings: ", SETTINGS_FILE_PATH)

func apply_defaults():
	apply_volume_setting("Master", DEFAULT_SETTINGS.audio.master_volume)
	apply_volume_setting("Music", DEFAULT_SETTINGS.audio.music_volume)
	apply_volume_setting("SFX", DEFAULT_SETTINGS.audio.sfx_volume)
	apply_fullscreen_setting(DEFAULT_SETTINGS.video.fullscreen)
	apply_vsync_setting(DEFAULT_SETTINGS.video.vsync)
	apply_ben_mode(DEFAULT_SETTINGS.audio.ben_mode)
	apply_touch_controls(DEFAULT_SETTINGS.controls.touch_controls)

func get_ben_mode():
	return _ben_mode

func get_volume_setting_linear(bus_name):
	return AudioServer.get_bus_volume_linear(AudioServer.get_bus_index(bus_name))

func get_vsync_enabled():
	return DisplayServer.window_get_vsync_mode() == DisplayServer.VSYNC_ENABLED
	
func get_fullscreen_enabled():
	return DisplayServer.WINDOW_MODE_FULLSCREEN == DisplayServer.window_get_mode()
	
func get_touch_controls_enabled():
	return _touch_controls

func _init():
	# Seed the random number generator only once courtesy of the autoloader
	randomize()
