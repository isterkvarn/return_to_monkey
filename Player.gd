extends KinematicBody2D


const MAX_SPEED = 350
const CLIMB_SPEED = 200
const CEILING_FACTOR = 0.8
const JUMP_FORCE = 425
const GRAVITY = 20
const DOUBLE_JUMPS = 2
const START_BULLETS = 3
const MAX_HP = 3
const START_HP = MAX_HP
const ZOOM_SPEED = 0.9;

var bullets = START_BULLETS
var vel = Vector2()
var jumps = -1
var hp = START_HP

var kills = 0
var deaths = 0

var puppet_pos = position
var puppet_vel = vel

onready var sprite_feet = get_node("sprites/sprite_feet")
onready var sprite_body = get_node("sprites/sprite_body")
onready var sprite_pants = get_node("sprites/sprite_pants")
onready var sprite_banana = get_node("sprites/sprite_banana")

# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://bullet.tscn")
	set_safe_margin(0.1)

func _input(event):
	if event is InputEventMouseButton and \
	event.pressed and event.button_index == 1 and bullets > 0 and is_network_master():
		var angle = get_angle_to(get_global_mouse_position())
		if Input.is_action_pressed("shotgun") and bullets > 2:
			var spread = PI/8
			bullet_fire_helper(global_position, angle)
			bullet_fire_helper(global_position, angle - spread)
			bullet_fire_helper(global_position, angle + spread)
			
			bullets -= 3
		else:
			bullet_fire_helper(global_position, angle)
			bullets -= 1
	
	# scroll up
	if event is InputEventMouseButton and event.button_index == 4 and 1.5 > get_node("Camera2D").zoom.length():
		get_node("Camera2D").zoom *= 1/ZOOM_SPEED
	# scroll down
	if event is InputEventMouseButton and event.button_index == 5 and 0.1 < get_node("Camera2D").zoom.length():
		get_node("Camera2D").zoom *= ZOOM_SPEED
	rpc("hide_banana", bullets == 0)

remotesync func hide_banana(hidden):
	if hidden:
		sprite_banana.hide()
	else:
		sprite_banana.show()

func bullet_fire_helper(pos, angle):
	rpc("fire", {"pos":pos, "angle":angle})

 
master func hit_by_bullet():
	position = get_tree().get_root().get_node("main").get_node("map").get_node("SpawnPoints").get_random_spawn_position()

remote func killed(from):
	deaths += 1
	var players = get_tree().get_root().get_node("main").get_node("map").get_node("Players").get_children()
	for player in players:
		if player.get_name() == from:
			player.kills += 1

func pick_up_banana():
	bullets = 3
	sprite_banana.show()

func remove_banana():
	sprite_banana.hide()

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
			jumps = DOUBLE_JUMPS 
		
		var move_dict = {}
		move_dict["pos"] = position
		move_dict["vel"] = vel
		
		rpc_unreliable("update_movement", move_dict)
		
	else:
		vel = puppet_vel
		position = puppet_pos
		
	# do animation calculation
	if vel.x > 0.1:
		sprite_feet.play("running")
		flip_sprites_h(false)
		
	elif vel.x < -0.1:
		sprite_feet.play("running")
		flip_sprites_h(true)
	else:
		sprite_feet.play("default")
		
	if not is_on_floor():
		sprite_feet.play("falling")
		
	if is_on_ceiling():
		flip_sprites_v(true)
	else:
		flip_sprites_v(false)
		
	move_and_slide(vel, Vector2.UP)
	
	if not is_network_master():
		puppet_pos = position

func flip_sprites_v(flipped):
	sprite_body.flip_v = flipped
	sprite_feet.flip_v = flipped
	sprite_pants.flip_v = flipped
	sprite_banana.flip_v = flipped
	if flipped:
		$Label.rect_position.y = 22
	else:
		$Label.rect_position.y = -22

func flip_sprites_h(flipped):
	sprite_body.flip_h = flipped
	sprite_feet.flip_h = flipped
	sprite_pants.flip_h = flipped
	sprite_banana.flip_h = flipped
	if flipped:
		sprite_banana.position.x = -20
	else:
		sprite_banana.position.x = 20

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
