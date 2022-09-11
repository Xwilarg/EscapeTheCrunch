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

var rng;

var isHeadless: bool

func _ready() -> void:
	rng = RandomNumberGenerator.new()
	rng.randomize()
	get_tree().connect("connected_to_server", self, "_connected_to_server");
	get_tree().connect("server_disconnected", self, "_server_disconnected");
	get_tree().connect("connection_failed", self, "_connection_failed");
	get_tree().connect("network_peer_connected", self, "_peer_connected");
	get_tree().connect("network_peer_disconnected", self, "_peer_disconnected");
	isHeadless = "--server" in OS.get_cmdline_args()
	if isHeadless:
		create_server()

func delete_jd() -> void:
	var tmp = get_node_or_null("/root/FPSController/Navigation/JailD");
	if tmp:
		tmp.free();

func spawn_jd() -> void:
	var pl = load("res://Resources/Scenes/JailDoor.tscn")
	var instance = pl.instance()
	instance.name = "JailD";
	instance.translation = Vector3(25, 0, -20);
	get_node("/root/FPSController/Navigation/").add_child(instance);

func spawn_player(nom) -> void:
	var spawns = get_node("/root/FPSController/Navigation/Spawns").get_children()
	var pl = load("res://Resources/Scenes/Player.tscn")
	var nb = rng.randi_range(0, spawns.size() - 1)
	var instance = pl.instance()
	instance.name = nom;
	instance.translation = spawns[nb].translation;
	get_node("/root/FPSController/Navigation/").add_child(instance);

func spawn_boss(nom) -> void:
	var spawns = get_node("/root/FPSController/Navigation/Spawns_boss").get_children()
	var pl = load("res://Resources/Scenes/Boss.tscn")
	var nb = rng.randi_range(0, spawns.size() - 1)
	var instance = pl.instance()
	instance.name = nom;
	instance.translation = spawns[nb].translation;
	get_node("/root/FPSController/Navigation/").add_child(instance);

remote func show_badge(nom) -> void:
	var tmp = get_node_or_null("/root/FPSController/Navigation/" + nom);
	if tmp && tmp.name != playerID:
		tmp.badge_show();
	pass

remote func hide_badge(nom) -> void:
	var tmp = get_node_or_null("/root/FPSController/Navigation/" + nom);
	if tmp && tmp.name != playerID:
		tmp.badge_hide();
	pass

remote func take_badge(nom) -> void:
	if server == null:
		rpc_id(1, "take_badge", playerID);
	else:
		var tmp = get_node_or_null("/root/FPSController/Navigation/Safe");
		if tmp:
			tmp.free();
		delete_jd();
		rpc("show_badge", nom);
	pass

remote func drop_badge(nom) -> void:
	if server == null:
		rpc_id(1, "drop_badge", playerID);
	else:
		rpc("hide_badge", nom);
		spawn_badge("Safe");
		spawn_jd();
	pass

func spawn_badge(nom) -> void:
	var spawns = get_node("/root/FPSController/Navigation/Spawns_badge").get_children()
	var pl = load("res://Resources/Scenes/Safe.tscn")
	var nb = rng.randi_range(0, spawns.size() - 1)
	var instance = pl.instance()
	instance.name = nom;
	instance.translation = spawns[nb].translation;
	get_node("/root/FPSController/Navigation/").add_child(instance);

remote func end_single_game():
	var tmp = get_node_or_null("/root/FPSController/Navigation/" + playerID);
	if tmp:
		tmp.end_game();
	pass


remote func end_mult_game():
	if server == null:
		rpc_id(1, "end_mult_game");
	else:
		rpc("end_single_game");
		if !isHeadless:
			end_single_game()
		else:
			get_tree().quit()
	pass

remote func boss_target(pos: Vector3) -> void:
	if server == null:
		rpc_id(1, "boss_target", playerID);
	else:
		var tmp = get_node_or_null("/root/FPSController/Navigation/Boss 1");
		if tmp:
			tmp.speed = tmp.speed + 1;
			tmp.target = pos;

func who_is_this(nom) -> int:
	var id = -1;
	for _x in peers:
			if str(_x) in nom:
				id = _x;
	return id;

func move_entity(nom, pos) -> void:
	if "Server" in nom || "Boss" in nom:
		var tmp = get_node_or_null("/root/FPSController/Navigation/" + nom);
		if tmp:
			tmp.translation = pos;
	else:
		var id = who_is_this(nom);
		if id != -1:
			rpc_id(id, "p_teleport", pos)

puppet func p_teleport(pos) -> void:
	var tmp = get_node_or_null("/root/FPSController/Navigation/" + playerID);
	if tmp:
		tmp.translation = pos;
		tmp.lose_badge();

func create_server() -> void:
	print("creating server");
	server = NetworkedMultiplayerENet.new();
	server.create_server(int(defaultPort), MAX_CLIENTS);
	get_tree().set_network_peer(server);
	playerID = "PlayerServer"
	if !isHeadless:
		spawn_player(playerID);
	spawn_boss("Boss 1");
	spawn_badge("Safe");
	spawn_jd();
	var timer = get_node("/root/FPSController/Timer");
	timer.set_wait_time(0.05);
	timer.connect("timeout", get_node("/root/FPSController/Navigation/"), "_refresh_game");
	timer.start();

func join_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client(ip_address, int(defaultPort))
	get_tree().set_network_peer(client)

func join_main_server() -> void:
	client = NetworkedMultiplayerENet.new()
	client.create_client("51.159.6.4", int(defaultPort))
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
	if server != null:
		rpc_id(id, "r_init_player", "Player" + str(id));
	print("Player id: " + str(id) + " connected");
	print(peers);
	print(teams);

func _peer_disconnected(id):
	var i = 0;
	while i < peers.size():
		if peers[i] == id:
			peers.pop_at(i);
			teams.pop_at(i);
		i += 1;
	
	var tmp = get_node_or_null("/root/FPSController/Navigation/Player" + str(id));
	if tmp:
		tmp.free();
	
	print("Player id: " + str(id) + " disconnected");
	print(peers);

puppet func r_init_player(r_playerID):
	team = 1;
	playerID = r_playerID;
	spawn_player(playerID);
