extends Entity

class_name Boss

export var speed = 5

var path = []

var target: Object
var nav: Object

func _ready():
	target = get_node("../Player")
	nav = get_node("../Navigation")

func _physics_process(delta):
	var direction = Vector3()
	var step_size = delta * speed

	if path.size() > 0:
		var destination = path[0]
		direction = destination - self.translation

		if step_size > direction.length():
			step_size = direction.length()
			path.remove(0)

		self.translation += direction.normalized() * step_size

		direction.y = 0
		if direction:
			var look_at_point = self.translation + direction.normalized()
			self.look_at(look_at_point, Vector3.UP)
	else:
		path = nav.get_simple_path(self.translation, target.translation, true)
		print(path)
