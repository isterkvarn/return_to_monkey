extends Area2D

const BLINK_COLOR = Color(1,0.5,0.5)
const BLINK_INTERVALL = 0.4

onready var collisionBox = get_node("CollisionShape2D")
var time = 0
var doBlink = false
var isColorChanged = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("pick_up_banana"):
			body.pick_up_banana();
			queue_free()
	
	if (doBlink):
		blink(delta)
		
func doBlink():
	doBlink = true

func blink(delta):
	if time > BLINK_INTERVALL:
		# Reset the color
		if isColorChanged:
			$Sprite.modulate = Color(1, 1, 1)
		else:
			$Sprite.modulate = BLINK_COLOR
		isColorChanged = !isColorChanged
		time = 0
	time += delta
	
