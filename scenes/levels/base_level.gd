# base_level.gd
extends Node2D

# Base Level script containing common Level behaviors
# Adds pause support and a mechanism to auto-play the designated music on _ready
class_name BaseLevel

@export var mob_scene: PackedScene
var bean_scene: PackedScene = preload("res://scenes/Bean.tscn")

# Turn off the vulgarity for Ben
@export
var benMode = true

var music_pending_update: bool = false

const PAUSE_MENU: PackedScene = preload("res://scenes/ui/pause_menu.tscn")
const GAME_OVER: PackedScene = preload("res://scenes/ui/game_over.tscn")
const MAIN_MENU: PackedScene = preload("res://scenes/ui/MainMenu.tscn")

var pause_menu_instance: CanvasLayer = null
var game_over_instance: CanvasLayer = null
var score

var ben_song = preload("res://art/audio/music/takedown.mp3")
var normal_song = preload("res://art/audio/music/She Made Beans WTF But Its Safe And Sound By Capital Cities.mp3")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_start_music()
	new_game()
	SettingsManager.ben_mode_changed.connect(func(): music_pending_update = true)
	$Player.bean_launched.connect(_on_player_bean_launched)
	$Player.hit.connect(_on_game_over)
	$MobTimer.timeout.connect(_on_mob_timer_timeout)
	$ScoreTimer.timeout.connect(_on_score_timer_timeout)
	$StartTimer.timeout.connect(_on_start_timer_timeout)

func _notification(what: int) -> void:
	if what == NOTIFICATION_UNPAUSED:
		if music_pending_update:
			_start_music()
			music_pending_update = false

func _start_music():
	var  music = ben_song if SettingsManager.get_ben_mode() else normal_song
	AudioController.play_music(music)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_pause", false):
		get_viewport().set_input_as_handled()
		if is_instance_valid(pause_menu_instance):
			# If pause menu is already open (or an Options menu inside it is open),
			# pressing 'ui_cancel' should be handled by the pause menu itself (e.g., to resume).
			# If you are HERE, it means the input made it all the way up, so we should ignore it.
			pass
		else:
			show_pause_menu()

func show_pause_menu():
	if not is_instance_valid(pause_menu_instance):
		pause_menu_instance = PAUSE_MENU.instantiate()
		add_child(pause_menu_instance)
		_hook_up_quit_and_restart(pause_menu_instance)

func _on_pause_menu_closed():
	pause_menu_instance = null

# Launch a game over instance and hook up the signals
func _on_game_over():
	AudioController.stop_music()
	$ScoreTimer.stop()
	$MobTimer.stop()
	if not is_instance_valid(game_over_instance):
		game_over_instance = GAME_OVER.instantiate()
		add_child(game_over_instance)
		
		_hook_up_quit_and_restart(game_over_instance)

func _hook_up_quit_and_restart(instance: CanvasLayer):
	if instance.has_signal("quit_requested"):
		instance.quit_requested.connect(_on_quit_signal)
	if instance.has_signal("restart_requested"):
		instance.restart_requested.connect(_on_restart_signal)

func _on_quit_signal():
	_stop_scene()
	get_tree().change_scene_to_packed(MAIN_MENU)

func _stop_scene():
	# Any additional state cleanup we need to do in the future goes here
	get_tree().paused = false
	AudioController.stop_music()
	AudioController.stop_sfx()

func _on_restart_signal():
	_stop_scene()
	get_tree().reload_current_scene()

func _on_score_timer_timeout():
	score += 1
	$Hud.update_score(score)

func _on_start_timer_timeout():
	$MobTimer.start()
	$ScoreTimer.start()

func new_game():
	_start_music()
	score = 0
	$Hud.update_score(score)
	$Hud.show_temp_message("Get Ready")
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
	var velocity = Vector2(randf_range(1.0, 200.0), 0.0)
	mob.linear_velocity = velocity.rotated(direction)
	
	add_child(mob)
	mob.kill.connect(_on_score_timer_timeout)

func _on_player_bean_launched(launch_pos: Vector2, direction: Vector2):
	# Instantiate the bean
	var bean = bean_scene.instantiate()
	bean.start(launch_pos, direction)
	
	add_child(bean)
