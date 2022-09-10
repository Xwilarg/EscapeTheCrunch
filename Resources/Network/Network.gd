extends Node

const MAX_CLIENTS = 12;

var server = null;
var client = null;

var defaultPort = 28960;
var ip_address = "127.0.0.1";
var current_player_username = "";

var team = 0
var playerID = -1

var peers = [];
var teams = [];

func _ready() -> void:
	get_tree().connect("connected_to_server", self, "_connected_to_server");
	get_tree().connect("server_disconnected", self, "_server_disconnected");
	get_tree().connect("connection_failed", self, "_connection_failed");
	get_tree().connect("network_peer_connected", self, "_peer_connected");
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected");

func spawn_player(nom) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var spawns = get_node("/root/FPSController/Navigation/Spawns").get_children()
	var pl = load("res://Resources/Scenes/Player.tscn")
	var nb = rng.randi_range(0, spawns.size() - 1)
	var instance = pl.instance()
	instance.name = nom;
	instance.translation = spawns[nb].translation;
	get_node("/root/FPSController/Navigation/").add_child(instance);

func spawn_boss(nom) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var spawns = get_node("/root/FPSController/Navigation/Spawns").get_children()
	var pl = load("res://Resources/Scenes/Boss.tscn")
	var nb = rng.randi_range(0, spawns.size() - 1)
	var instance = pl.instance()
	instance.name = nom;
	instance.translation = spawns[nb].translation;
	get_node("/root/FPSController/Navigation/").add_child(instance);

func create_server() -> void:
	print("creating server");
	server = NetworkedMultiplayerENet.new();
	server.create_server(int(defaultPort), MAX_CLIENTS);
	get_tree().set_network_peer(server);
	playerID = "PlayerServer"
	spawn_player(playerID);
	spawn_boss("Boss 1");
	var timer = get_node("/root/FPSController/Timer");
	timer.set_wait_time(0.05);
	timer.connect("timeout", get_node("/root/FPSController/Navigation/"), "_refresh_game");
	timer.start();

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, int(defaultPort))
	get_tree().set_network_peer(client)

func reset_network_connection() -> void:
	if get_tree().has_network_peer():
		get_tree().network_peer = null

func _connected_to_server() -> void:
	print("Successfully connected to the server")

func _server_disconnected() -> void:
	print("Disconnected from the server")
	reset_network_connection()

func _client_connection_timeout():
	print("Client has been timed out")
	reset_network_connection()

func _connection_failed():
	print("Connection failed")
	reset_network_connection()

static func sort_ascending(a, b):
	if a < b:
		return true
	return false

func _peer_connected(id):
	peers.append(id);
	teams.append(0);
	rpc_id(id, "r_init_player", "Player" + str(id));
	print("Player id: " + str(id) + " connected");
	print(peers);
	print(teams);

func _peer_disconnected(id):
	var i = -1;
	while i < peers.size():
		i += 1;
		if peers[i] == id:
			peers.pop_at(i);
			teams.pop_at(i);
	
	var tmp = get_node_or_null("/root/FPSController/Navigation/Player" + id);
	if tmp:
		tmp.free();
	
	print("Player id: " + str(id) + " disconnected");
	print(peers);

puppet func r_init_player(r_playerID):
	team = 1;
	playerID = r_playerID;
	spawn_player(playerID);
