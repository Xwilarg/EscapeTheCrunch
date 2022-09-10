extends StaticBody

var rng: RandomNumberGenerator
var nodes: Array
var indexes: Array
var safePrefab: Object

func _ready():
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	nodes = get_node("../Spawns").get_children()
	indexes = range(nodes.size())
	safePrefab = load("res://Resources//Scenes/Safe.tscn")


func respawn():
	var nb = rng.randi_range(0, indexes.size() - 1)
	var value = indexes[nb]
	var instance = safePrefab.instance()
	instance.setId(nb)
	get_node("../../../..").add_child(instance);
	instance.translation = nodes[nb].translation
	
