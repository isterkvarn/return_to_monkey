extends Node2D


onready var pad_1 = get_node("pad_1/BounceArea")
onready var pad_2 = get_node("pad_2/BounceArea")
onready var pad_3 = get_node("pad_3/BounceArea")

# Called when the node enters the scene tree for the first time.
func _ready():
	pad_3.launch_force = 1500
	pad_2.launch_force = 800


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
