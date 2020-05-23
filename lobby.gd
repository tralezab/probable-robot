extends Control

func _ready():
	# Called every time the node is added to the scene.
	gamestate.connect("connection_failed", self, "_on_connection_failed")
	gamestate.connect("connection_succeeded", self, "_on_connection_success")
	gamestate.connect("player_list_changed", self, "refresh_lobby")
	gamestate.connect("game_ended", self, "_on_game_ended")
	gamestate.connect("game_error", self, "_on_game_error")
	# Set the player name according to the system username. Fallback to the path.
	$Connect/Name.text = _pick_name()
	$AudioStreamPlayer.play()

func _on_host_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return
	$Connect.hide()
	$Players.show()
	$Connect/ErrorLabel.text = ""
	var player_name = $Connect/Name.text
	var port = int($Connect/Port.text)
	gamestate.host_game(player_name, port)
	refresh_lobby()

func _on_join_pressed():
	if $Connect/Name.text == "":
		$Connect/ErrorLabel.text = "Invalid name!"
		return
	var ip = $Connect/IPAddress.text
	var port = $Connect/Port.text
	if not ip.is_valid_ip_address():
		$Connect/ErrorLabel.text = "Invalid IP address!"
		return
	$Connect/ErrorLabel.text = ""
	$Connect/Host.disabled = true
	$Connect/Join.disabled = true
	var player_name = $Connect/Name.text
	gamestate.join_game(ip, player_name, port)

func _on_connection_success():
	$Connect.hide()
	$Players.show()

func _on_connection_failed():
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false
	$Connect/ErrorLabel.set_text("Connection failed.")

func _on_game_ended():
	show()
	$Connect.show()
	$Players.hide()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false

func _on_game_error(errtxt):
	$ErrorDialog.dialog_text = errtxt
	$ErrorDialog.popup_centered_minsize()
	$Connect/Host.disabled = false
	$Connect/Join.disabled = false

func refresh_lobby():
	var players = gamestate.get_player_list()
	players.sort()
	$Players/List.clear()
	$Players/List.add_item(gamestate.get_player_name() + " (You)")
	for p in players:
		$Players/List.add_item(p)
	$Players/Start.disabled = not get_tree().is_network_server()

func _on_start_pressed():
	gamestate.begin_game()

func _pick_name():
	var possible_names = [
		"Prawny Brawler", "Supreme Shrimp", "Fishy Fighter",
		"Crustacaen Colossus", "Pathetic Squirt", "Twisted Twerp",
		"Maritime Martini", "Larry Lobster", "Poggers Crab", "Andy Bagsin"
	]
	randomize()
	possible_names.shuffle()
	return possible_names.front()

func _on_togglemusic_pressed():
	if $AudioStreamPlayer.playing:
		$AudioStreamPlayer.stop()
	else:
		$AudioStreamPlayer.play()
