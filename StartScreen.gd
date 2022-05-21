extends Control



func _on_HOST_pressed():
	var player_name = $VBoxContainer/TextEdit.text
	Gamestate.host_game(player_name)


func _on_JOIN_pressed():
	var player_name = $VBoxContainer/TextEdit.text
	Gamestate.join_game(player_name)


func _on_QUIT_pressed():
	get_tree().quit()
