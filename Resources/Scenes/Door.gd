extends StaticBody

var rng: RandomNumberGenerator
var nodes: Array
var indexes: Array
var safePrefab: Object
var instance: Object

func _ready():
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	nodes = get_node("../Spawns").get_children()
	indexes = range(nodes.size())
	safePrefab = load("res://Resources//Scenes/Safe.tscn")
	instance = safePrefab.instance()
	get_node("../../../..").add_child(instance);
	respawn()

func respawn():
	var nb = rng.randi_range(0, indexes.size() - 1)
	var value = indexes[nb]
	instance.translation = nodes[nb].translation
	instance.show()
