extends CanvasLayer

var game_over_text = "Still thinking about thos Beans"

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
