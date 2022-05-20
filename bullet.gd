extends Node2D

const BULLET_SPEED = 100
var speed = Vector2()

func _ready():
	speed.x = BULLET_SPEED

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	translate(speed * delta)

func shoot(origin, angle):
	print("created bullet at", origin, "with angle", angle)
	translate(origin)
	rotate(angle)
	speed = speed.rotated(angle)
	
func _on_Area2D_area_entered(area):
	queue_free()
