extends Button

const SERVER_PORT = 8000
const MAX_PLAYERS = 20

func _ready():
	pass

func _on_HostButton_pressed():
	# set up netwrok peer as server
	var peer = NetworkedMultiplayerENet.new()
	peer.create_server(SERVER_PORT, MAX_PLAYERS)
	get_tree().network_peer = peer
