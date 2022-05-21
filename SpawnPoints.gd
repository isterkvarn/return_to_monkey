extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

remotesync func get_random_spawn_position():
	var spawns = get_children()
	var rand_index = randi() % spawns.size()
	return spawns[rand_index].position
