extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("scoreboard"):
		show()
		var names = "Player\n"
		var kills = "Kills\n"
		var deaths = "Deaths\n"
		var players = get_tree().get_root().get_node("main").get_node("map").get_node("Players").get_children()
		for player in players:
			names += player.get_node("Label").text
			names += "\n"
			kills += str(player.kills)
			kills += "\n"
			deaths += str(player.deaths)
			deaths += "\n"
		get_node("Name").text = names
		get_node("Kills").text = kills
		get_node("Deaths").text = deaths
	else:
		hide()
