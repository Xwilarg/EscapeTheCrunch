extends Node

export var safeCount = 1

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var nodes = get_node("../Spawns").get_children()
	var indexes = range(nodes.size())
	var scene = load("res://Resources//Scenes/Safe.tscn")
	for i in safeCount:
		var nb = rng.randi_range(0, indexes.size() - 1)
		var value = indexes[nb]
		var instance = scene.instance()
		instance.setId(nb)
		instance.position = nodes[nb].position
		indexes.erase(nb)
