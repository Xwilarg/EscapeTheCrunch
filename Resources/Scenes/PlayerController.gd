extends Entity

class_name PlayerController

export var speed = 15
export var xSens = -1.0
export var interactionDistance = 3
export var doorDistance = 5

export var sprintCooldownRef = 6.0
export var sprintDuration = 2.0

var sprintCooldown = 0
var sprintDurationTimer = 0

var door: Object
var label: Object
var safeTarget: Object
var id = 1
var currentKey: bool = false;

var sprintUI: Object

var bgmCalm: Object
var bgmChase: Object

var verRot: float

func isReadyToExit() -> bool:
	return currentKey and isOnDoorRange()

func isOnDoorRange() -> bool:
	return global_transform.origin.distance_to(door.global_transform.origin) < doorDistance

func _ready():
	door = get_node("../NavigationMeshInstance/World/Map/Door")
	sprintUI = get_node("Sprint")
	bgmCalm = get_node("BGMCalm")
	bgmChase = get_node("BGMChase")
	bgmCalm.play()
	label = get_node("Label")
	label.hide()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func setBGMCalm():
	bgmChase.stop()
	bgmCalm.play()
	
func setBGMChase():
	bgmChase.play()
	bgmCalm.stop()

func _input(event):         
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(event.relative.x * xSens))
		var value = event.relative.y * xSens
		if value + verRot > -50 and value + verRot < 50:
			verRot += value
			$Camera.rotate_x(deg2rad(value))
	if Input.is_action_pressed("action") and safeTarget != null and !currentKey:
		currentKey = true;
		Network.take_badge(Network.playerID);
		label.hide()
		safeTarget = null
	if Input.is_action_pressed("sprint") and !currentKey and sprintCooldown <= 0.0:
		sprintDurationTimer = sprintDuration
		sprintCooldown = sprintCooldownRef + sprintDuration
		sprintUI.hide()

func lose_badge():
	if currentKey:
		currentKey = false;
		Network.drop_badge(Network.playerID);

func _physics_process(delta):
	if sprintDurationTimer > 0.0:
		sprintDurationTimer -= delta
	if sprintCooldown > 0.0:
		sprintCooldown -= delta
		if sprintCooldown <= 0.0:
			sprintUI.show()

	label.hide()

	# Controls
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

	var currSpeed = speed
	if sprintDurationTimer > 0.0:
		currSpeed *= 2
	var velocity = (global_transform.basis.y * y + global_transform.basis.x * x).normalized() * currSpeed
	move_and_slide(velocity)
	
	var center = get_viewport().size/2
	var from = $Camera.project_ray_origin(center)
	var to = from + $Camera.project_ray_normal(center) * 100
	var result = get_world().direct_space_state.intersect_ray(from, to)
	if result and result.collider.name == "Safe" and global_transform.origin.distance_to(result.collider.global_transform.origin) < interactionDistance && result.collider.is_visible() and !currentKey:
		label.show()
		label.set_text("Press E")
		safeTarget = result.collider
	elif isOnDoorRange():
		label.show()
		if !currentKey:
			label.set_text("You need to find the key first!")
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			get_tree().reload_current_scene()
	else:
		safeTarget = null
