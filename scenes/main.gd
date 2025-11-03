extends Node

@export 
var mob_scene: PackedScene

var score

# Turn off the vulgarity for Ben
@export
var benMode = false

var music

func _ready() -> void:
	music = $BenMusic if benMode else $Music

func _process(delta: float) -> void:
	pass

func game_over():
	music.stop()
	$DeathSound.play()
	$ScoreTimer.stop()
	$MobTimer.stop()
	$HUD.show_gameover()

func new_game():
	music.play()
	score = 0
	$HUD.update_score(score)
	$HUD.show_message("Get Ready")
	get_tree().call_group("mobs", "queue_free")
	$Player.start($StartPosition.position)
	$StartTimer.start()

func _on_mob_timer_timeout():
	# Make new mob
	var mob = mob_scene.instantiate()
	
	# Pick a random location on the path
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	
	# Set the mob position + orientation, tweaking it randomly
	mob.position = mob_spawn_location.position
	var direction = mob_spawn_location.rotation + PI / 2
	direction += randf_range(-PI / 4, PI / 4)
	mob.rotation = direction
	
	# Set a random velocity
	var velocity = Vector2(randf_range(150.0, 250.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)

func _on_score_timer_timeout():
	score += 1
	$HUD.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()
