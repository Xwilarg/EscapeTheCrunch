extends StaticBody

var rng: RandomNumberGenerator
var nodes: Array
var indexes: Array
var safePrefab: Object
var currObj: Object

#func _ready():
#	rng = RandomNumberGenerator.new()
#	rng.randomize()
#	nodes = get_node("../Spawns").get_children()
#	indexes = range(nodes.size())
#	safePrefab = load("res://Resources//Scenes/Safe.tscn")
#	currObj = safePrefab.instance()
#	var prevNode = get_node("../../../..")
#	prevNode.add_child(currObj);
#	respawn()

#func respawn():
#	var nb = rng.randi_range(0, indexes.size() - 1)
#	var value = indexes[nb]
#	currObj.translation = nodes[nb].translation
#	currObj.show()
