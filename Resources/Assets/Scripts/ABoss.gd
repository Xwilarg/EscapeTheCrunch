extends Entity

class_name ABoss

var timerRefMin = 4.0
var timerRefMax = 6.0
var timer: float
var rng: RandomNumberGenerator

func initInternal():
	rng = RandomNumberGenerator.new()

func processInternal(delta):
	pass
