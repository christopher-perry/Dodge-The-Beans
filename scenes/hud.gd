extends CanvasLayer

signal start_game
var game_over_text = "Still thinking about thos Beans"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func show_temp_message(text):
	show_message(text)
	$MessageTimer.start()
	
func show_message(text):
	$Message.text = text
	$Message.show()
	$BillFoster.show()
	
func show_gameover():
	show_temp_message("Game Over")
	await $MessageTimer.timeout
	
	show_message(game_over_text)
	
	await get_tree().create_timer(1.0).timeout
	$StartButton.show()
	
func update_score(score): 
	$ScoreLabel.text = str(score)

func _on_start_button_pressed() -> void:
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout() -> void:
	$Message.hide()
	$BillFoster.hide()
