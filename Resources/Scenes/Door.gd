extends StaticBody

func _ready():
	var rng: RandomNumberGenerator
	var nodes: Array
	var indexes: Array
	var safePrefab: Object
	
	rng = RandomNumberGenerator.new()
	rng.randomize()
	nodes = get_node("../Spawns").get_children()
	indexes = range(nodes.size())
	safePrefab = load("res://Resources//Scenes/Safe.tscn")

	var nb = rng.randi_range(0, indexes.size() - 1)
	var value = indexes[nb]
	var instance = safePrefab.instance()
	instance.setId(nb)
	instance.translation = nodes[nb].translation
	indexes.erase(nb)
	nodes[nb].add_child(instance);
