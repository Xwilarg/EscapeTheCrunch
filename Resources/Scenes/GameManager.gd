extends Node

export var safeCount = 1

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var nodes = get_node("../Spawns").get_children()
	var indexes = range(nodes.size())
	var scene = load("res://Resources//Scenes/Safe.tscn")
	for i in safeCount:
		var nb = rng.randf_range(0, indexes.size())
		var value = indexes[nb]
		var instance = scene.instance()
		instance.setId(nb)
		instance.global_transform.origin = nodes[nb].global_transform.origin
		indexes.erase(nb)
