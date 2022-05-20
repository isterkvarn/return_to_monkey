extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):


func _on_HOST_pressed():
	print("HOST")


func _on_JOIN_pressed():
	print("JOIN")


func _on_QUIT_pressed():
	get_tree().quit()
