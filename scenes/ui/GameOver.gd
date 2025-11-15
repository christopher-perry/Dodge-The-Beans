# GameOver.gd
extends CanvasLayer

signal restart_requested
signal quit_requested

const GAME_OVER_TEXT = "You Got Beaned!"
@export var game_over_sfx: AudioStream
@onready var game_over_label: Label = $GameOverText
@onready var restart_button: Button = $OptionsBox/Buttons/RestartButton
@onready var quit_button: Button = $OptionsBox/Buttons/QuitButton

func _ready() -> void:
	get_tree().paused = true
	AudioController.play_sfx(game_over_sfx)
	game_over_label.text = GAME_OVER_TEXT
	
	restart_button.pressed.connect(_on_restart_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

func _on_restart_pressed():
	get_tree().paused = false 
	restart_requested.emit() 
	hide()

func _on_quit_pressed():
	quit_requested.emit()
