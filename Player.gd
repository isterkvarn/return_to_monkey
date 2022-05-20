extends KinematicBody2D


const MAXSPEED = 500
const GRAVITY = 20

var vel = Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel.x = 0
	
	if Input.is_action_pressed("jump") and is_on_floor():
		vel.y -= 1000
		
	if Input.is_action_pressed("move_left"):
		vel.x = -MAXSPEED
		
	if Input.is_action_pressed("move_right"):
		vel.x = MAXSPEED
	
	if not is_on_floor():
		vel.y += GRAVITY

	move_and_slide(vel, Vector2.UP)
