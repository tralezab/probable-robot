extends Node2D

#imsxz, this script handles the player's """MIND""" essentially it lets them pick a shrimp after their shrimp dies.

var player_id = null
var player_name = ""
var shrimp = null

var picked_shrimp = "res://testing_shrimp.tscn"

#called by world setup and when shrimp die
func spawn_shrimp():
	if player_id == null:
		print("NO PLAYER ID SET FOR SPAWN_SHRIMP FUNCTION")
		return
	var chosen_shrimp = load(picked_shrimp).instance()
	add_child(chosen_shrimp)
	chosen_shrimp.set_network_master(player_id)
	chosen_shrimp.setup_vars()
	shrimp = chosen_shrimp
	$bar.visible = true
	#if !current: need to add the code where bots autospawn

func set_player_name(new_name):
	player_name = new_name
	if shrimp:
		shrimp.rpc("set_label_name",player_name)

func set_player_id(new_id):
	player_id = new_id

func set_cursor(tex):
	if shrimp:
		shrimp.set_cursor(tex)

func sync_up():
	if shrimp:
		shrimp.set_puppet_vars()

func set_shrimp(path):
	picked_shrimp = path

func on_shrimp_death():
	$bar.visible = false
	shrimp = null
