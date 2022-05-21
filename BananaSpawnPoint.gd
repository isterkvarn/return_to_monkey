extends Position2D

const BANANA = preload("res://Banana.tscn")
var spawnedBanana = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawnBanana():
	spawnedBanana = weakref(BANANA.instance())
	spawnedBanana.get_ref().global_position = self.global_position
	get_parent().get_parent().add_child(spawnedBanana.get_ref())
	
func despawnBanana():
	get_parent().get_parent().remove_child(spawnedBanana.get_ref())
	spawnedBanana = null

func doBlink():
	if spawnedBanana.get_ref():
		spawnedBanana.get_ref().doBlink()
	
func hasBanana():
	return spawnedBanana != null
