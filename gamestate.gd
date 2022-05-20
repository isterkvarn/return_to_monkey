extends Node

const SERVER_PORT = 10555
const SERVER_IP = "172.20.32.1"
const MAX_PEERS = 12

var peer = null

var player_name = "monkee"

var players = {}

func _ready():
	get_tree().connect("network_peer_connected", self, "_player_connected")

func _player_connected(id):
	# give new peer info
	print(str(id) + "connected")
	rpc_id(id, "add_player", peer.get_unique_id())
	add_player(id)

remote func add_player(id):
	var map = get_tree().get_root().get_node("map")
	var player = load("res://player.tscn").instance()
	var spawn_pos = map.get_node("SpawnPoint").position
	
	# Init player and add to map
	player.set_name(str(id)) # Standard ID for server
	player.position = spawn_pos
	map.get_node("Players").add_child(player)

func join_game(new_player_name):
		# Set up network peer
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(SERVER_PORT, MAX_PEERS)
	get_tree().set_network_peer(peer)
	# setup map
	setup_map(peer.get_unique_id())

func host_game(new_player_name):
	# Set up network peer
	peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_IP, SERVER_PORT)
	get_tree().set_network_peer(peer)
	# setup map
	setup_map(peer.get_unique_id())
	
func setup_map(id):
	# Get and load map, player and spawnpoint
	var map = load("res://map.tscn").instance()
	var player = load("res://player.tscn").instance()
	var spawn_pos = map.get_node("SpawnPoint").position
	
	get_tree().get_root().add_child(map)
	
	# Init player and add to map
	player.set_name(id) # Standard ID for server
	player.position = spawn_pos
	player.set_network_master(id)
	map.get_node("Players").add_child(player)
