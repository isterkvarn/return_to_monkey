extends Area2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_Area2D_body_entered(body):
	if body.has_method("set_in_noclimb"):
		body.set_in_noclimb(true)

func _on_Area2D_body_exited(body):
	if body.has_method("set_in_noclimb"):
		body.set_in_noclimb(false)
