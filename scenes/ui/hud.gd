extends CanvasLayer

class_name HUD

signal pause_req

var game_over_text = "Still thinking about thos Beans"
@onready var pause_button = $Pause
@onready var joystick = $Joystick

func _ready() -> void:
	_set_touch_controls_visibility(SettingsManager.get_touch_controls_enabled())
	SettingsManager.touch_controls_changed.connect(_set_touch_controls_visibility)

func show_temp_message(text):
	show_message(text)
	$MessageTimer.start()
	
func show_message(text):
	$Message.text = text
	$Message.show()
	
func update_score(score): 
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout() -> void:
	$Message.hide()

func _on_pause_pressed() -> void:
	pause_req.emit()

func _set_touch_controls_visibility(enabled: bool):
	pause_button.visible = enabled
	joystick.visible = enabled
