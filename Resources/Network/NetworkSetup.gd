extends Control



func _on_IpAddress_text_changed(new_text):
	Network.ip_address = new_text;


func _on_Port_text_changed(new_text):
	Network.defaultPort = new_text;


func _on_Host_pressed():
	Network.create_server();
	print(Network.server);
	hide();


func _on_Join_pressed():
	Network.join_server();
	hide();


func _on_JoinMain_pressed():
	Network.join_main_server()
	hide()
