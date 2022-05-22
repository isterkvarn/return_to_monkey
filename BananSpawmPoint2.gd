extends Area2D

const RESPAWNTIME = 10

var time = 0
var isBanana = true
var isActive = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	# Spawn a new banana
	if not isBanana and time > RESPAWNTIME:
		isBanana = true
		time = 0
		rpc("activate_banana")
	# Decrease time to spawn a new banana
	elif not isBanana and time < RESPAWNTIME:
		time += delta

func _on_Node2D_body_entered(body):
	if body.has_method("pick_up_banana") and isActive:
		isActive = false
		body.pick_up_banana()
		rpc("deactivate_banana")
		

func activate_banana():
	$Sprite.show()

remotesync func deactivate_banana():
	$Sprite.hide()

