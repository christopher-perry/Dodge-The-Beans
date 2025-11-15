# level_1.gd
extends Control

@onready var start_button: Button = $MenuOptionsContainer/StartButton
@onready var options_button: Button = $MenuOptionsContainer/OptionsButton
@onready var exit_button: Button = $MenuOptionsContainer/ExitButton

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/Options.tscn")

func _ready():
	start_button.grab_focus()

	# Connect button pressed signals
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://scenes/levels/level_1.tscn")
func _on_options_button_pressed():
	var options_menu_instance = OPTIONS_SCENE.instantiate()
	add_child(options_menu_instance)
	set_process_unhandled_input(false)
	set_menu_buttons_disabled(true)
	
	# Hook up the callback to restore main menu navigation
	options_menu_instance.closed.connect(_on_options_menu_closed) 

func _on_options_menu_closed():
	# Restore main menu focus and navigation
	set_process_unhandled_input(true)
	set_menu_buttons_disabled(false)
	options_button.grab_focus()

func _on_exit_button_pressed():
	# play_click_sfx() # Optional
	print("Exit Game Pressed!")
	get_tree().quit() # Quits the game

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ENTER or event.keycode == KEY_SPACE:
			var focused_button = get_viewport().gui_get_focus_owner()
			if focused_button is Button and focused_button.is_ancestor_of(self):
				 # Check if focused button is part of this menu
				pass

func set_menu_buttons_disabled(disabled: bool):
	var f_mode = Control.FOCUS_NONE if disabled else FOCUS_ALL
	for button in [start_button, options_button, exit_button]:
		button.focus_mode = f_mode
