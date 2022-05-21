extends Area2D

var removed = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



remotesync func remove():
	removed = true
	queue_free()

func _on_Banana_body_entered(body):
	if body.has_method("pick_up_banana"):
		body.pick_up_banana()
		rpc("remove")
