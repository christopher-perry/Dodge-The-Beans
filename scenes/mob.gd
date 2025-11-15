# mob.gd
extends RigidBody2D

signal kill

@export var death_sfx_1: AudioStream
@export var death_sfx_2: AudioStream
@export var death_sfx_3: AudioStream
@export var death_sfx_4: AudioStream
@export var death_sfx_5: AudioStream

@onready var sprite = $AnimatedSprite2D
# Audio player per mob allows overlapping death knells
@onready var sfx_player = $AudioStreamPlayer

var audio_bank: Array[AudioStream] = []
var is_dying = false

func _on_visible_on_screen_enabler_2d_screen_exited() -> void:
	queue_free()

func _ready():
	var mob_types = Array(sprite.sprite_frames.get_animation_names())
	sprite.animation = mob_types.pick_random()
	sprite.play()
	audio_bank.append_array([death_sfx_1, death_sfx_2, death_sfx_3, death_sfx_4, death_sfx_5])
	audio_bank = audio_bank.filter(func(s): return s != null)

func take_hit():
	# Prevent double-hitting
	if is_dying:
		return

	is_dying = true
	flash_red()
	play_death_sfx()
	await get_tree().create_timer(0.2).timeout
	kill.emit()
	queue_free()

func flash_red():
	# Apply a red overlay (Modulation)
	sprite.modulate = Color(1.5, 0.5, 0.5) # Increased values for a strong red tint
	
	# Use a Tween to fade the red back to normal over a short time
	var tween = create_tween()
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.15)
	
func play_death_sfx():
	if audio_bank.size() == 0:
		print("WARNING: No death SFX set for mob.")
		return

	var selected_sfx = audio_bank[randi() % audio_bank.size()]
	
	sfx_player.stream = selected_sfx
	sfx_player.play()
	
	# To prevent the sound from cutting off when the mob is deleted:
	# 1. Unparent the AudioStreamPlayer from the mob.
	# 2. Tell the AudioStreamPlayer to delete itself once the sound finishes.
	sfx_player.reparent(get_tree().root)
	sfx_player.finished.connect(sfx_player.queue_free)
