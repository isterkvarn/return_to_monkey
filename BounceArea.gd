extends Area2D

var launch_force = 1000

func _on_BounceArea_body_entered(body):
	if body.has_method("touched_launchpad"):
		body.touched_launchpad(launch_force)
