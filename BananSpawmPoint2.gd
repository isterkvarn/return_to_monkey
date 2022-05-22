extends Area2D

const RESPAWNTIME = 10

var time = 0
var isBanana = true


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
	# There is banana so check for players to give it to
		

remotesync func activate_banana():
	$Sprite.show()
	var overlapping_bodies = get_overlapping_bodies()
	if overlapping_bodies.size() != 0:
		pick_up_helper(overlapping_bodies[0])

remotesync func deactivate_banana():
	$Sprite.hide()
	isBanana = false

func _on_Node2D_body_entered(body):
	pick_up_helper(body)

func pick_up_helper(body):
	if body.has_method("pick_up_banana"):
		body.pick_up_banana()
		time = 0
		rpc("deactivate_banana")
