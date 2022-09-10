extends StaticBody

var players = []
var rng: RandomNumberGenerator
var nodes: Array
var indexes: Array
var safePrefab: Object

func registerPlayer(p: Object) -> void:
	players.push_back(p)
	
	if rng == null:
		_ready()
	var nb = rng.randi_range(0, indexes.size() - 1)
	var value = indexes[nb]
	var instance = safePrefab.instance()
	instance.setId(nb)
	instance.translation = nodes[nb].translation
	indexes.erase(nb)
	self.add_child(instance);

func removePlayer(p: Object) -> void:
	players.erase(p)

func areAllPlayersReady() -> bool:
	for p in players:
		if !p.isReadyToExit():
			return false
	return true

func _ready():
	rng = RandomNumberGenerator.new()
	rng.randomize()
	nodes = get_node("../Spawns").get_children()
	indexes = range(nodes.size())
	safePrefab = load("res://Resources//Scenes/Safe.tscn")
