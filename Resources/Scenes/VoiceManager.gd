extends Node

export var voices: Array
var rng: RandomNumberGenerator = null
var player: AudioStreamPlayer

func playRandomVoice() -> void:
	if rng == null:
		rng = RandomNumberGenerator.new()
		player = get_node("Player")
	var voice = voices[rng.randi_range(0, voices.size() - 1)]
	voice.set_loop(false)
	player.stream = voice
	player.play()
