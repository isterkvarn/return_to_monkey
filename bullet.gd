extends Node2D

const BULLET_SPEED = 500
var speed = Vector2()
var parent_id
var removed = false

func set_parent_id(id):
	parent_id = id

func _ready():
	speed.x = BULLET_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(speed * delta)

remotesync func remove():
	removed = true
	queue_free()

func shoot(origin, angle):
	translate(origin)
	rotate(angle)
	speed = speed.rotated(angle)
	
func _on_Area2D_area_entered(area):
	queue_free()

func _on_Area2D_body_entered(body):
	# Collision detection
	var player_id = body.get_name()
	if player_id != parent_id:
		# Colliding with a player
		if body.has_method("hit_by_bullet"):
				body.rpc("hit_by_bullet")
				print("PLAYER")
		# Colliding with the map
		rpc("remove")
