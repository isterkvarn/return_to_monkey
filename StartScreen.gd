extends Control



func _on_HOST_pressed():
	print("HOST")
	var name = $VBoxContainer/TextEdit.text
	Gamestate.host_game(name)


func _on_JOIN_pressed():
	print("JOIN")
	Gamestate.join_game(name)


func _on_QUIT_pressed():
	get_tree().quit()
