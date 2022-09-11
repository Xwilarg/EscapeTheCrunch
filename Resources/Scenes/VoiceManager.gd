extends Node

export var voices: Array
var rng: RandomNumberGenerator = null

func getVoice() -> Object:
	if rng == null:
		rng = RandomNumberGenerator.new()
	return voices[rng.randi_range(0, voices.size() - 1)]
