extends Node

const SERVER_PORT = 10555
const SERVER_IP = "192.168.0.102"
const MAX_PEERS = 12

var peer = null

var player_name = "monkee"
var color_hue = 1.0


var players = {}

func _ready():
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	color_hue = rng.randf_range(0, 1.0)
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
	
func _connected_fail():
	print("Connection Failed")

func _connected_ok():
	print("Connected!")

func _player_connected(id):
	# give new peer info
	print(str(id) + " connected")
	rpc_id(id, "add_player", peer.get_unique_id(), player_name, color_hue)

	
func _player_disconnected(id):
	remove_player(id)
	
remote func add_player(id, new_player_name, new_player_hue):
	var map = get_tree().get_root().get_node("main").get_node("map")
	var player = load("res://Player.tscn").instance()
	#var spawn_pos = map.get_node("SpawnPoint").position
	
	# Init player and add to map
	player.set_name(str(id)) # Standard ID for server
	player.set_network_master(id)
	player.get_node("Label").set_text(new_player_name)
	player.get_node("sprites").get_node("sprite_pants").modulate = Color.from_hsv(new_player_hue,0.8,0.9,1)
	player.position = get_tree().get_root().get_node("main").get_node("map").get_node("SpawnPoints").get_random_spawn_position()
	map.get_node("Players").add_child(player)

remote func remove_player(id):
	var map = get_tree().get_root().get_node("main").get_node("map")
	map.get_node("Players").get_node(str(id)).queue_free()

func join_game(new_player_name):
	# Set up network peer
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	# setup map
	if new_player_name != "":
		player_name = new_player_name
	setup_map(peer.get_unique_id())

func host_game(new_player_name):
	# Set up network peer
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	# setup map
	if new_player_name != "":
		player_name = new_player_name
	setup_map(peer.get_unique_id())
	
func setup_map(id):
	# Get and load map, player and spawnpoint
	var player = load("res://Player.tscn").instance()
	#var spawn_pos = map.get_node("SpawnPoint").position
	
	get_tree().get_root().get_node("main").get_node("map").show()
	get_tree().get_root().get_node("main").get_node("Control").hide()
	
	# Init player and add to map
	player.set_name(str(id))
	player.get_node("Camera2D").current = true
	#player.position = spawn_pos
	player.get_node("sprites").get_node("sprite_pants").modulate = Color.from_hsv(color_hue,0.8,0.9,1)
	player.get_node("Label").set_text(player_name)
	player.set_network_master(id)
	get_tree().get_root().get_node("main").get_node("map").get_node("Players").add_child(player)
