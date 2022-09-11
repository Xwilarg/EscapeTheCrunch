extends Entity

class_name ABoss

var timerRefMin = 3.0
var timerRefMax = 6.0
var timer: float
var rng: RandomNumberGenerator
var vm: Object

func initInternal():
	rng = RandomNumberGenerator.new()
	vm = get_node("/root/FPSController/VoiceManager")
	resetTimer()

func resetTimer():
	timer = rng.randi_range(timerRefMin, timerRefMax)

func processInternal(delta):
	timer -= delta
	if timer <= 0:
		resetTimer()
		vm.playRandomVoice()
