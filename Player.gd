extends KinematicBody2D


const MAX_SPEED = 350
const CLIMB_SPEED = 200
const CEILING_FACTOR = 0.8
const JUMP_FORCE = 400
const GRAVITY = 20
const DOUBLE_JUMPS = 2

var vel = Vector2()
var jumps = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://bullet.tscn")
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		print("mouse clicked/unclick at: ", event.position)
		var bulletScene = load("res://bullet.tscn")

		var instance = bulletScene.instance();
		get_tree().get_root().add_child(instance)
		instance.shoot(global_position, get_angle_to(get_global_mouse_position()))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	vel.x = 0

	# gravity
	# should be checked before jump (else it resets the vel.y to 0)
	if not is_on_floor():
		vel.y += GRAVITY
	else:
		jumps = DOUBLE_JUMPS
		vel.y = 0
	
	# jumps and double jumps
	if Input.is_action_just_pressed("jump") and jumps > 0:
		jumps -= 1
		vel.y = -JUMP_FORCE
	
	# wall climbing
	if Input.is_action_pressed("climb") and is_on_wall() and vel.y > -CLIMB_SPEED:
		vel.y = -CLIMB_SPEED
	
	# normal movements
	if Input.is_action_pressed("move_left"):
		vel.x = -MAX_SPEED
	if Input.is_action_pressed("move_right"):
		vel.x = MAX_SPEED

	# ceiling "walk"
	if Input.is_action_pressed("climb") and is_on_ceiling():
		# -1 to stay stuck on the ceiling
		vel.y = -1
		vel.x *= CEILING_FACTOR
		
	move_and_slide(vel, Vector2.UP)
