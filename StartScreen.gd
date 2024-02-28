extends Control


func _ready():
	Gamestate.host_game("server")

func _on_HOST_pressed():
	var player_name = $VBoxContainer/VBoxContainer/text_name.text
	Gamestate.host_game(player_name)


func _on_JOIN_pressed():
	var player_name = $VBoxContainer/VBoxContainer/text_name.text
	var ip = $VBoxContainer/VBoxContainer2/text_ip/.text
	Gamestate.join_game(player_name, ip)


func _on_QUIT_pressed():
	get_tree().quit()
