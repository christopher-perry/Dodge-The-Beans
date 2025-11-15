# PauseMenu.gd
extends CanvasLayer

signal unpause
signal restart_requested
signal quit_requested

const OPTIONS_SCENE: PackedScene = preload("res://scenes/ui/Options.tscn")

@onready var resume_button: Button = $PauseBar/Buttons/ResumeButton
@onready var options_button: Button = $PauseBar/Buttons/OptionsButton
@onready var quit_button: Button = $PauseBar/Buttons/TerminalButtons/QuitButton
@onready var restart_button: Button = $PauseBar/Buttons/TerminalButtons/RestartButton

func _ready() -> void:
	get_tree().paused = true
	resume_button.grab_focus()
	
	# Signals
	resume_button.pressed.connect(_on_resume_pressed)
	options_button.pressed.connect(_on_options_pressed)
	quit_button.pressed.connect(_on_quit_pressed)
	restart_button.pressed.connect(_on_restart_pressed)

func _input(event: InputEvent):
	# We want "ESC", start, B all to cancel
	if (event.is_action_pressed("ui_cancel", false) or event.is_action_pressed("ui_pause", false)):
		get_viewport().set_input_as_handled()
		_on_resume_pressed()

func _on_resume_pressed():
	get_tree().paused = false
	unpause.emit()
	queue_free()

func _on_options_pressed():
	var options_instance = OPTIONS_SCENE.instantiate()
	add_child(options_instance)
	
	# Connect signal to re-focus the options button once options is closed
	if options_instance.has_signal("closed"):
		options_instance.closed.connect(func(): options_button.grab_focus())
		
func _on_quit_pressed():
	quit_requested.emit()

func _on_restart_pressed():
	restart_requested.emit()
