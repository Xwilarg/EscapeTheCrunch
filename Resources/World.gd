extends Spatial


# Declare member variables here.
#var GameWorld = get_tree().get_root().find_node("Game World");


# Called when the node enters the scene tree for the first time.
var timer;

func _ready():
	pass;

var PlayD = preload("res://Resources/Player/Dummy/PlayerDummy.tscn");
var BossD = preload("res://Resources/Boss/Dummy/BossDummy.tscn");

func create_entity(UInfo):
	var Instance;
	if UInfo["type"] == "Player":
		Instance = PlayD.instance();
	elif UInfo["type"] == "Boss":
		Instance = PlayD.instance();
	else:
		pass
	Instance.name = UInfo["name"];
	Instance.translation = UInfo["pos"];
	self.add_child(Instance);

func update_unit(NewData, currentUnit):
	if (currentUnit.translation.distance_to(NewData["pos"]) > 1.5):
		currentUnit.translation = NewData["pos"];
	currentUnit.move_to(NewData["pos"]);

func prepare_packet(obj):
	var packet = {};
	packet["name"] = obj.get_name();
	if "Player" in obj.get_name():
		packet["type"] = "Player";
	elif "Boss" in obj.get_name():
		packet["type"] = "Boss";
	else:
		packet["type"] = "terrain";
	packet["pos"] = obj.translation;
	return packet;

func _refresh_game():
	var GameWorld = [];
	var _i = 0;
	var tmp = {};
	var NodeTmp = null;
	while _i < self.get_child_count():
		NodeTmp = self.get_child(_i);
		tmp = prepare_packet(NodeTmp);
		if (tmp["type"] != "terrain"):
			GameWorld.append(tmp);
		_i += 1;
	if (Network.peers.size() > 0):
		rpc_unreliable("r_refresh_game", GameWorld);


remote func r_refresh_game(s_NewGameWorld):
	var GameWorld = [];
	var _i = 0;
	var tmp = null;
	while _i < self.get_child_count():
		GameWorld.append(self.get_child(_i).name);
		_i += 1;
	for _x in s_NewGameWorld:
		if (_x["name"] != Network.playerID):
			if (GameWorld.find(_x["name"]) == -1):
					create_entity(_x);
			tmp = get_node_or_null("/root/FPSController/Navigation/" + _x["name"]);
			if tmp:
				update_unit(_x, tmp);
		GameWorld.erase(_x);
	if GameWorld.size() > 0:
		for _x in GameWorld:
			tmp = get_node_or_null("/root/FPSController/Navigation/" + _x["name"]);
			if tmp:
				tmp.free();
	tmp = get_node_or_null("/root/FPSController/Navigation/" + Network.playerID);
	if tmp:
		var toSend = prepare_packet(tmp);
		rpc_id(1, "r_update_player", toSend);
	
remote func r_update_player(toUpdate):
	var currentData = get_node_or_null("/root/FPSController/Navigation/" + toUpdate["name"]);
	if currentData:
		update_unit(toUpdate, currentData);
	else:
		create_entity(toUpdate);
		currentData = get_node_or_null("/root/FPSController/Navigation/" + toUpdate["name"]);
		update_unit(toUpdate, currentData);
