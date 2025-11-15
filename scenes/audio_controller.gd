# AudioController.gd (Autoload)
extends Node

# Auto-loaded controller to provide access to MusicPlayer and SFXPlayer
@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: AudioStreamPlayer = $SFXPlayer

func play_sfx(sound_stream: AudioStream, bus_name: String = "SFX"):
	sfx_player.stream = sound_stream
	sfx_player.bus = bus_name
	sfx_player.play()

func stop_sfx():
	sfx_player.stop()

func play_music(music_stream: AudioStream, bus_name: String = "Music"):
	music_player.stream = music_stream
	music_player.bus = bus_name
	music_player.play()

func stop_music():
	music_player.stop()
