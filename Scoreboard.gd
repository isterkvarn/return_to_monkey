extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("scoreboard"):
		show()
		var string = "Player	Kills	Deaths\n"
		var players = get_tree().get_root().get_node("main").get_node("map").get_node("Players").get_children()
		for player in players:
			string += player.get_name()
			string += "		"
			string += str(player.kills)
			string += "		"
			string += str(player.deaths)
			string += "\n"
		get_node("RichTextLabel").text = string
	else:
		hide()
