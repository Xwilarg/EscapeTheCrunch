extends KinematicBody

export var speed = 15
export var xSens = -1

func _ready():
	pass

func _input(event):         
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(event.relative.x * xSens))

func _physics_process(delta):
	var x = 0
	var y = 0

	if Input.is_action_pressed("move_right"):
		x = 1
	elif Input.is_action_pressed("move_left"):
		x = -1
	if Input.is_action_pressed("move_back"):
		y = 1
	elif Input.is_action_pressed("move_forward"):
		y = -1

	var velocity = (global_transform.basis.y * y + global_transform.basis.x * x).normalized() * speed
	move_and_slide(velocity)
