extends Area2D

const RESPAWNTIME = 10

var time = 0
var isBanana = true


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	var overlapping_bodies = get_overlapping_bodies()
	
	# Spawn a new banana
	if not isBanana and time > RESPAWNTIME:
		isBanana = true
		time = 0
		rpc("activate_banana")
	# Decrease time to spawn a new banana
	elif not isBanana and time < RESPAWNTIME:
		time += delta
	# There is banana so check for players to give it to
	else:
		if overlapping_bodies.size() != 0:
			if overlapping_bodies[0].has_method("pick_up_banana"):
				overlapping_bodies[0].pick_up_banana()
				time = 0
				isBanana = false
				rpc("deactivate_banana")

remotesync func activate_banana():
	$Sprite.show()

remotesync func deactivate_banana():
	$Sprite.hide()

