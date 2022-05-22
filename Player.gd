extends KinematicBody2D

const FAST_SPEED = 500
const SLOW_SPEED = 350
var MAX_SPEED = SLOW_SPEED

const CLIMB_SPEED = 200
const CEILING_FACTOR = 0.8
const JUMP_FORCE = 425
const GRAVITY = 20
const DOUBLE_JUMPS = 2
const START_BULLETS = 3
const ZOOM_SPEED = 0.9
const LAUNCH_FORCE = 1000

var bullets = START_BULLETS
var vel = Vector2()
var banana_angle = 0
var jumps = -1
var in_noclimb = false
var touched_launch = 0

var kills = 0
var deaths = 0

var puppet_pos = position
var puppet_vel = vel
var puppet_banana_angle = 0


onready var sprites = get_node("sprites")
onready var sprite_feet = get_node("sprites/sprite_feet")
onready var sprite_body = get_node("sprites/sprite_body")
onready var sprite_pants = get_node("sprites/sprite_pants")
onready var sprite_banana = get_node("sprites/sprite_banana")
onready var banana_anchor = get_node("sprites/Position2D")
onready var death_noise = get_node("sprites/death_noise")

# Called when the node enters the scene tree for the first time.
func _ready():
	preload("res://bullet.tscn")
	preload("res://dead_monkey.tscn")
	set_safe_margin(0.1)

func _input(event):
	if event is InputEventMouseButton and \
	event.pressed and bullets > 0 and is_network_master():
		var angle = get_angle_to(get_global_mouse_position())
		if  event.button_index == 2 and bullets > 2:
			var spread = PI/8
			bullet_fire_helper(global_position, angle)
			bullet_fire_helper(global_position, angle - spread)
			bullet_fire_helper(global_position, angle + spread)
			
			bullets -= 3
		elif event.button_index == 1:
			bullet_fire_helper(global_position, angle)
			bullets -= 1
		rpc("hide_banana", bullets == 0)
	# scroll up
	if event is InputEventMouseButton and event.button_index == 5 and 0.8 > get_node("Camera2D").zoom.length():
		get_node("Camera2D").zoom *= 1/ZOOM_SPEED
	# scroll down
	if event is InputEventMouseButton and event.button_index == 4 and 0.1 < get_node("Camera2D").zoom.length():
		get_node("Camera2D").zoom *= ZOOM_SPEED

remotesync func hide_banana(hidden):
	if hidden:
		sprite_banana.hide()
	else:
		sprite_banana.show()

func bullet_fire_helper(pos, angle):
	rpc("fire", {"pos":pos, "angle":angle})

 
master func hit_by_bullet(speed):
	#death_noise.play()
	pick_up_banana()
	var old_position =  Vector2(global_position.x, global_position.y-20)
	position = get_tree().get_root().get_node("main").get_node("map").get_node("SpawnPoints").get_random_spawn_position()
	rpc("create_body", speed, Gamestate.color_hue, old_position)
	
remotesync func create_body(speed, color, death_position):
	var body = load("res://dead_monkey.tscn").instance()
	body.get_node("sprites").get_node("sprite_pants").modulate = Color.from_hsv(color,0.8,0.9,1)
	body.set_linear_velocity(speed.clamped(10))
	body.position = death_position
	get_tree().get_root().get_node("main").get_node("map").add_child(body)

remotesync func killed(from):
	deaths += 1
	var players = get_tree().get_root().get_node("main").get_node("map").get_node("Players").get_children()
	for player in players:
		if player.get_name() == from:
			player.kills += 1

func pick_up_banana():
	if is_network_master():
		bullets = 3
		sprite_banana.show()
		rpc("hide_banana", bullets == 0)

func remove_banana():
	sprite_banana.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	vel.x = 0

	# gravity
	# should be checked before jump (else it resets the vel.y to 0)
	if not is_on_floor():
		vel.y += GRAVITY
	else:
		jumps = DOUBLE_JUMPS
		vel.y = 0
		
	
	if is_network_master():
		if bullets == 0:
			MAX_SPEED = FAST_SPEED
		else:
			MAX_SPEED = SLOW_SPEED
		# jumps and double jumps
		if Input.is_action_just_pressed("jump") and jumps > 0:
			jumps -= 1
			vel.y = -JUMP_FORCE
		
		# wall climbing
		if Input.is_action_pressed("climb") and is_on_wall() and vel.y > -CLIMB_SPEED and not in_noclimb:
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
		
		# calculate banana angle
		banana_angle = -banana_anchor.get_angle_to(get_global_mouse_position())
		
		if touched_launch > 0:
			vel.y -= touched_launch
			touched_launch = 0
		
		var move_dict = {}
		move_dict["pos"] = position
		move_dict["vel"] = vel
		move_dict["banana_angle"] = banana_angle
		
		rpc_unreliable("update_movement", move_dict)
		
	else:
		vel = puppet_vel
		position = puppet_pos
		banana_angle = puppet_banana_angle
		
	# do animation calculation
	if vel.x > 0.1:
		sprite_feet.play("running")
		flip_sprites_h(false)
		
	elif vel.x < -0.1:
		sprite_feet.play("running")
		flip_sprites_h(true)
	else:
		sprite_feet.play("default")
		
	if not is_on_floor() and not is_on_ceiling():
		sprite_feet.play("falling")
		
	if is_on_ceiling():
		flip_sprites_v(true)
	else:
		flip_sprites_v(false)
	
	if sprite_banana.flip_h:
		banana_angle += PI
		# banana
	#sprite_banana.rotation = banana_angle
	rotate_around(sprite_banana, banana_anchor.position, banana_angle)
	
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
		
		if banana_anchor.position.y != -abs(banana_anchor.position.y):
			rotate_around(sprite_banana, banana_anchor.position, 0)
			banana_anchor.position.y = -abs(banana_anchor.position.y)
			#sprite_banana.rotation = 0
			sprite_banana.position.y = 1
		
	else:
		$Label.rect_position.y = -22
		
		if banana_anchor.position.y != abs(banana_anchor.position.y):
			rotate_around(sprite_banana, banana_anchor.position, 0)
			banana_anchor.position.y = abs(banana_anchor.position.y)
			#sprite_banana.rotation = 0
			sprite_banana.position.y = -1
		
		
func flip_sprites_h(flipped):
	sprite_body.flip_h = flipped
	sprite_feet.flip_h = flipped
	sprite_pants.flip_h = flipped
	#var original_banana_pos = sprite_banana.position.x
	#sprite_banana.position = Vector2(0, 0)
	sprite_banana.flip_h = flipped
	
	if flipped:
		if banana_anchor.position.x != -abs(banana_anchor.position.x):
			rotate_around(sprite_banana, banana_anchor.position, 0)
			banana_anchor.position.x = -abs(banana_anchor.position.x)
			#sprite_banana.rotation = 0
			sprite_banana.position.x = -20
	else:
		if banana_anchor.position.x != abs(banana_anchor.position.x):
			rotate_around(sprite_banana, banana_anchor.position, 0)
			banana_anchor.position.x = abs(banana_anchor.position.x)
			#sprite_banana.rotation = 0
			sprite_banana.position.x = 20

func rotate_around(obj, point, angle):
	var rot = angle + obj.rotation
	var tStart = point
	obj.global_translate (-tStart)
	obj.transform = obj.transform.rotated(-rot)
	obj.global_translate (tStart)


func set_in_noclimb(bool_value):
	in_noclimb = bool_value

func touched_launchpad(force):
	touched_launch = force

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
	puppet_banana_angle = move_dict["banana_angle"]
