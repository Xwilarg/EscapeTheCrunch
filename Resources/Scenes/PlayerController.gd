extends KinematicBody

export var speed = 15
export var xSens = 1

var velocity = Vector3.ZERO

func _ready():
	pass

func _input(event):         
	if event is InputEventMouseMotion:
		$Camera.rotate_z(deg2rad(event.relative.x * xSens))

func _physics_process(delta):
	var direction = Vector3.ZERO

	if Input.is_action_pressed("move_right"):
		direction.x += 1
	elif Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		direction.z += 1
	elif Input.is_action_pressed("move_forward"):
		direction.z -= 1
	
	direction = direction.normalized()
	
	var forward = global_transform.basis
	velocity = forward.z * direction.z * speed + forward.x * direction.x * speed
	velocity = move_and_slide(velocity, Vector3.UP)
