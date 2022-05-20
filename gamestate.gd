extends Node

const SERVER_PORT = 10555
const SERVER_IP = "slartibartfast.lysator.liu.se"
const MAX_PEERS = 12

var peer = null

var player_name = "monkee"

var players = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")
	get_tree().connect("connected_to_server", self, "_connected_ok")
	get_tree().connect("connection_failed", self, "_connected_fail")
	
func _connected_fail():
	print("Connection Failed")

func _connected_ok():
	print("Connected!")

func _player_connected(id):
	# give new peer info
	print(str(id) + "connected")
	rpc_id(id, "add_player", peer.get_unique_id())
	add_player(id)

remote func add_player(id):
	var map = get_tree().get_root().get_node("main").get_node("map")
	var player = load("res://player.tscn").instance()
	#var spawn_pos = map.get_node("SpawnPoint").position
	
	# Init player and add to map
	player.set_name(str(id)) # Standard ID for server
	#player.position = spawn_pos
	map.get_node("Players").add_child(player)

func join_game(new_player_name):
		# Set up network peer
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	# setup map
	setup_map(peer.get_unique_id())

func host_game(new_player_name):
	# Set up network peer
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	# setup map
	setup_map(peer.get_unique_id())
	
func setup_map(id):
	# Get and load map, player and spawnpoint
	var map = load("res://map.tscn").instance()
	var player = load("res://Player.tscn").instance()
	#var spawn_pos = map.get_node("SpawnPoint").position
	
	get_tree().get_root().add_child(map)
	get_tree().get_root().get_node("main").get_node("Control").hide()
	
	# Init player and add to map
	player.set_name(str(id)) # Standard ID for server
	#player.position = spawn_pos
	player.set_network_master(id)
	map.get_node("Players").add_child(player)
