extends Entity


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var speed = 15;

# Called when the node enters the scene tree for the first time.
func _ready():
	move_to(self.translation);

func move_to(pos):
	$NavigationAgent.set_target_location(pos);

func advance():
	var target_point = $NavigationAgent.get_next_location();
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
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	advance();
