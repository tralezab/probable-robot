extends Node

# Max number of players.
const MAX_PEERS = 6

# Name for my player.
var player_name = "Armhulen"
# Node of this client
var player_node = null

# Names for remote players in id:name format.
var players = {}
var players_ready = []

# Signals to let lobby GUI know what's going on.
signal player_list_changed()
signal connection_failed()
signal connection_succeeded()
signal game_ended()
signal game_error(what)

# Callback from SceneTree.
func _player_connected(id):
	# Registration of a client beings here, tell the connected player that we are here.
	rpc_id(id, "register_player", player_name)


# Callback from SceneTree.
func _player_disconnected(id):
	if has_node("/root/World"): # Game is in progress.
		if get_tree().is_network_server():
			emit_signal("game_error", "Player " + players[id] + " disconnected")
			end_game()
	else: # Game is not in progress.
		# Unregister this player.
		unregister_player(id)


# Callback from SceneTree, only for clients (not server).
func _connected_ok():
	# We just connected to a server
	emit_signal("connection_succeeded")


# Callback from SceneTree, only for clients (not server).
func _server_disconnected():
	emit_signal("game_error", "Server disconnected")
	end_game()


# Callback from SceneTree, only for clients (not server).
func _connected_fail():
	get_tree().set_network_peer(null) # Remove peer
	emit_signal("connection_failed")


# Lobby management functions.

remote func register_player(new_player_name):
	var id = get_tree().get_rpc_sender_id()
	print(id)
	players[id] = new_player_name
	emit_signal("player_list_changed")


func unregister_player(id):
	players.erase(id)
	emit_signal("player_list_changed")


remote func pre_start_game(spawning_positions_for_players):
	# Change scene.
	print(spawning_positions_for_players)
	var world = load("res://World.tscn").instance()
	get_tree().get_root().add_child(world)

	get_tree().get_root().get_node("Lobby").hide()

	var player_scene = load("res://shrimp.tscn")

	for p_id in spawning_positions_for_players:
		var player = player_scene.instance()
		player.global_position = spawning_positions_for_players[p_id]
		# This is extremely important. This name is what determines everything.
		player.set_name(str(p_id))
		player.set_player_id(p_id)
		if p_id == get_tree().get_network_unique_id():
			player_node = player
		world.add_child(player)

	player_node.set_player_name(player_name)

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())

	if not get_tree().is_network_server():
		# Tell server we are ready to start.
		rpc_id(1, "ready_to_start", get_tree().get_network_unique_id())
	elif players.size() == 0:
		post_start_game()


remote func post_start_game():
	get_tree().set_pause(false) # Unpause and unleash the game!


remote func ready_to_start(id):
	assert(get_tree().is_network_server())

	if not id in players_ready:
		players_ready.append(id)

	if players_ready.size() == players.size():
		for p in players:
			rpc_id(p, "post_start_game")
		post_start_game()


func host_game(new_player_name, port):
	player_name = new_player_name
	var host = NetworkedMultiplayerENet.new()
	host.create_server(port, MAX_PEERS)
	get_tree().set_network_peer(host)


func join_game(ip, new_player_name, port):
	player_name = new_player_name
	var client = NetworkedMultiplayerENet.new()
	client.create_client(ip, int(port))
	get_tree().set_network_peer(client)


func get_player_list():
	return players.values()


func get_player_name():
	return player_name


func begin_game():
	assert(get_tree().is_network_server())

	# Create a dictionary with peer id and a coordinate for them to move on
	var spawning_positions_for_players = {}
	var spawnx = 200
	var spawny = 200
	spawning_positions_for_players[1] = Vector2(spawnx,spawny) #reserved for server itself
	spawnx += 100
	for player_id in players:
		spawning_positions_for_players[player_id] = Vector2(spawnx,spawny)
		spawnx += 100
	for peer in players:
		rpc_id(peer, "pre_start_game", spawning_positions_for_players)
	pre_start_game(spawning_positions_for_players)


func end_game():
	if has_node("/root/World"): # Game is in progress.
		# End it
		get_node("/root/World").queue_free()

	emit_signal("game_ended")
	players.clear()


func _ready():
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_connected", self, "_player_connected")
# warning-ignore:return_value_discarded
	get_tree().connect("network_peer_disconnected", self,"_player_disconnected")
# warning-ignore:return_value_discarded
	get_tree().connect("connected_to_server", self, "_connected_ok")
# warning-ignore:return_value_discarded
	get_tree().connect("connection_failed", self, "_connected_fail")
# warning-ignore:return_value_discarded
	get_tree().connect("server_disconnected", self, "_server_disconnected")
