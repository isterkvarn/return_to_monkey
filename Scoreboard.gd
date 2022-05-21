extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var players = get_tree().get_root().get_node("main").get_node("map").get_node("Players").get_children()
	for player in players:
		print(player.kills, player.deaths)
