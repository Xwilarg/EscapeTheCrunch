extends KinematicBody

class_name Objective

func getColor() -> int:
	return id

func setId(value: int):
	id = value
	print("ID set to ", id)

var id: int

func _physics_process(delta):
	rotate_y(delta)
