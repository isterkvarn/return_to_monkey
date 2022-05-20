extends Control



func _on_HOST_pressed():
	print("HOST")
	var player_name = $VBoxContainer/TextEdit.text
	Gamestate.host_game(player_name)


func _on_JOIN_pressed():
	print("JOIN")
	var player_name = $VBoxContainer/TextEdit.text
	Gamestate.join_game(player_name)


func _on_QUIT_pressed():
	get_tree().quit()
