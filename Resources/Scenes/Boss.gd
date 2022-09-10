extends Entity

class_name Boss

export var speedWalk = 7
export var speedRun = 7

var speed: int
var jail: Object
var playerTarget: Object = null

var path = []

var rng = RandomNumberGenerator.new()

var target = self.translation

func _ready():
	speed = speedWalk
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
	var target_point = $NavigationAgent.get_next_location()
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
	if vel.length() > 0:
		look_at(transform.origin - vel, Vector3.UP)

func patrol():
	if target.distance_to(self.translation) < 2.5:
		var spawns = get_node("/root/FPSController/Navigation/Waypoints").get_children()
		if spawns.size() > 0:
			var nb = rng.randi_range(0, spawns.size() - 1)
			target = spawns[nb].translation;
		else:
			target = self.translation

func check_chase():
	var from = self.translation + Vector3(0, 1, 0)
	var to = from + global_transform.basis.z * 100
	var result = get_world().direct_space_state.intersect_ray(from, to)
	if result and "Player" in result.collider.name:
		target = result.collider.translation;
		if global_transform.origin.distance_to(result.collider.global_transform.origin) < 1.1:
			Network.move_entity(result.collider.name, jail.translation);

func set_target():
	patrol();
	check_chase();

func _physics_process(delta):
	set_target();
	$NavigationAgent.set_target_location(target);
	advance();
