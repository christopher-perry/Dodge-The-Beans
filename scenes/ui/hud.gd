extends CanvasLayer

var game_over_text = "Still thinking about thos Beans"

func show_temp_message(text):
	show_message(text)
	$MessageTimer.start()
	
func show_message(text):
	$Message.text = text
	$Message.show()
	
func show_gameover():
	show_temp_message("Game Over")
	await $MessageTimer.timeout
	show_message(game_over_text)
	await get_tree().create_timer(1.0).timeout
	
	
func update_score(score): 
	$ScoreLabel.text = str(score)

func _on_message_timer_timeout() -> void:
	$Message.hide()
