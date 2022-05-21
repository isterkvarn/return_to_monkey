extends Node2D

const BULLET_SPEED = 100
var speed = Vector2()
var parent_id

func set_parent_id(id):
	parent_id = id

func _ready():
	speed.x = BULLET_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(speed * delta)

func shoot(origin, angle):
	translate(origin)
	rotate(angle)
	speed = speed.rotated(angle)
	
func _on_Area2D_area_entered(area):
	queue_free()

func _on_Area2D_body_entered(body):
	# Collision detection
	
	# Colliding with a player
	if body.has_method("hit_by_bullet"):
		if body.has_method("get_player_id"):
			var player_id = body.get_name()
			if player_id != parent_id:
				body.hit_by_bullet()
				print("PLAYER")
				
	# Colliding with the map
	elif body.name == "StaticBody2D":
		print("STATIC")
