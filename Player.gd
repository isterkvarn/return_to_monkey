extends KinematicBody2D


const MAX_SPEED = 350
const CLIMB_SPEED = 200
const CEILING_FACTOR = 0.8
const JUMP_FORCE = 400
const GRAVITY = 20
const DOUBLE_JUMPS = 2

const MAX_HP = 3
const START_HP = MAX_HP


var vel = Vector2()
var jumps = -1
var hp = START_HP

var puppet_pos = position
var puppet_vel = vel

onready var sprite = get_node("sprite")

# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://bullet.tscn")
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton and event.pressed and is_network_master():
		var bullet_info = {}
		bullet_info["pos"] = global_position
		bullet_info["angle"] = get_angle_to(get_global_mouse_position())
		rpc("fire", bullet_info)
 
master func hit_by_bullet():
	print("APA NERE")
	position = get_tree().get_root().get_node("map").get_node("SpawnPoints").get_random_spawn_position()



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
		
	
	if is_network_master():
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
			vel.y = -GRAVITY - 1
			vel.x *= CEILING_FACTOR
			jumps = DOUBLE_JUMPS - 1
		
		var move_dict = {}
		move_dict["pos"] = position
		move_dict["vel"] = vel
		
		rpc_unreliable("update_movement", move_dict)
		
	else:
		vel = puppet_vel
		position = puppet_pos
		
	# do animation calculation
	if vel.x > 0.1:
		sprite.play("running")
		sprite.flip_h = false
		
	elif vel.x < -0.1:
		sprite.play("running")
		sprite.flip_h = true
	else:
		sprite.play("default")
		
	if not is_on_floor():
		sprite.play("falling")
		
	if is_on_ceiling():
		sprite.flip_v = true
	else:
		sprite.flip_v = false
		
	move_and_slide(vel, Vector2.UP)
	
	if not is_network_master():
		puppet_pos = position

remotesync func fire(bullet_info):
	var bulletScene = load("res://bullet.tscn")
	var instance = bulletScene.instance();
	# Give bullet its parent id
	instance.set_parent_id(get_name())
	get_tree().get_root().add_child(instance)
	instance.shoot(bullet_info["pos"], bullet_info["angle"])
	
	
puppet func update_movement(move_dict):
	puppet_vel = move_dict["vel"]
	puppet_pos = move_dict["pos"]
