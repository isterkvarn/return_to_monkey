extends Area2D


func _on_Area2D_body_entered(body):
	if body.has_method("set_in_noclimb"):
		body.set_in_noclimb(true)

func _on_Area2D_body_exited(body):
	if body.has_method("set_in_noclimb"):
		body.set_in_noclimb(false)
