# Options.gd
extends CanvasLayer

signal closed

# Script for tying together the Options UI to the SettingsManager backend
# For settings modifications and persistence.

# Load in Node references
@onready var master_slider: HSlider = $OptionsContainer/AudioTab/Audio/MasterVolume/MasterSlider
@onready var music_slider: HSlider = $OptionsContainer/AudioTab/Audio/MusicVolume/MusicSlider
@onready var sfx_slider: HSlider = $OptionsContainer/AudioTab/Audio/SFXVolume/SFXSlider
@onready var ben_mode: CheckBox = $OptionsContainer/AudioTab/Audio/BenMode
@onready var fullscreen_toggle: CheckBox = $OptionsContainer/VideoTab/Video/Fullscreen/FullscreenBox
@onready var vsync_toggle: CheckBox = $OptionsContainer/VideoTab/Video/VSync/VSyncBox
@onready var touch_controls_box = $OptionsContainer/ControlsTab/Controls/Touch/TouchBox
@onready var back_button: Button = $OptionsContainer/Buttons/Back
@onready var restore_defaults_button: Button = $OptionsContainer/Buttons/RestoreDefaults

func _ready() -> void:
	init_ui_values()
	master_slider.value_changed.connect(_on_master_slider_value_changed)
	music_slider.value_changed.connect(_on_music_slider_value_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_value_changed)
	ben_mode.toggled.connect(_on_ben_mode_changed)

	fullscreen_toggle.toggled.connect(_on_fullscreen_enabled_toggled)
	vsync_toggle.toggled.connect(_on_v_sync_enabled_toggled)
	
	touch_controls_box.toggled.connect(_on_touch_controls_toggled)

	back_button.pressed.connect(_on_back_pressed)
	restore_defaults_button.pressed.connect(_on_restore_defaults_pressed)
	
	back_button.grab_focus()

func init_ui_values():
	master_slider.value = SettingsManager.get_volume_setting_linear("Master")
	music_slider.value = SettingsManager.get_volume_setting_linear("Music")
	sfx_slider.value = SettingsManager.get_volume_setting_linear("SFX")
	ben_mode.button_pressed = SettingsManager.get_ben_mode()
	
	fullscreen_toggle.button_pressed = SettingsManager.get_vsync_enabled()
	vsync_toggle.button_pressed = SettingsManager.get_vsync_enabled()
	
	touch_controls_box.button_pressed = SettingsManager.get_touch_controls_enabled()

func set_bus_volume(bus_name: , value: float):
	SettingsManager.apply_volume_setting(bus_name, value)
	# TODO: Provide audible feedback on the appropriate bus to show sound level
	# $UISoundPlayer.play() # Needs an AudioStream and a SFX

func _on_master_slider_value_changed(value: float):
	set_bus_volume("Master", value)

func _on_music_slider_value_changed(value: float):
	set_bus_volume("Music", value)

func _on_sfx_slider_value_changed(value: float):
	set_bus_volume("SFX", value)

func _on_ben_mode_changed(on: bool):
	SettingsManager.apply_ben_mode(on)

func _on_fullscreen_enabled_toggled(on: bool):
	SettingsManager.apply_fullscreen_setting(on)
	
func _on_v_sync_enabled_toggled(on: bool):
	SettingsManager.apply_vsync_setting(on)

func _on_touch_controls_toggled(on: bool):
	SettingsManager.apply_touch_controls(on)

func _on_back_pressed():
	SettingsManager.save_settings()
	emit_signal("closed")
	queue_free()

func _on_restore_defaults_pressed() -> void:
	SettingsManager.apply_defaults()
	init_ui_values()

func _input(event: InputEvent):
	# Tie the 'B' button to "Back"
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()
