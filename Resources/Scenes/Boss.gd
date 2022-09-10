extends Entity

class_name Boss

export var speedWalk = 5
export var speedRun = 10

var speed: int
var jail: Object

var targetOverride: Vector3	= Vector3.ZERO

var path = []

var rng = RandomNumberGenerator.new()

var target = self.translation

func _ready():
	jail = get_node("/root/FPSController/Navigation/NavigationMeshInstance/World/Map/Jail")
	rng.randomize()
	var spawns = get_node("/root/FPSController/Navigation/Waypoints").get_children()
	if spawns.size() > 0:
		var nb = rng.randi_range(0, spawns.size() - 1)
		target = spawns[nb].translation;
		$NavigationAgent.set_target_location(target);
	else:
		target = self.translation
	pass

func advance():
	var target_point: Vector3
	if targetOverride == Vector3.ZERO:
		target_point = $NavigationAgent.get_next_location()
		speed = speedWalk
	else:
		target_point = targetOverride;
		speed = speedRun
	var pos = get_global_transform().origin;
	var vel = Vector3(0, 0, 0);
	# Floor normal.
	var n = $RayCast.get_collision_normal();
	if n.length_squared() < 0.001:
		# Set normal to Y+ if on air.
		n = Vector3(0, 1, 0);
	if pos.distance_to(target_point) > 1:
		# Calculate the velocity.
		vel = (target_point - pos).slide(n).normalized() * speed;
	move_and_slide(vel, Vector3(0, 1, 0));
	look_at(transform.origin - vel, Vector3.UP)

func _physics_process(delta):
	if target.distance_to(self.translation) < 2.5:
		targetOverride = Vector3.ZERO
		var spawns = get_node("/root/FPSController/Navigation/Waypoints").get_children()
		if spawns.size() > 0:
			var nb = rng.randi_range(0, spawns.size() - 1)
			target = spawns[nb].translation;
			$NavigationAgent.set_target_location(target);
		else:
			target = self.translation
	else:
		advance();
	
	var from = self.translation + Vector3(0, 1, 0)
	var to = from + global_transform.basis.z * 100
	var result = get_world().direct_space_state.intersect_ray(from, to)
	if result and "Player" in result.collider.name:
		targetOverride = result.collider.translation
