extends Node2D

#imsxz, this script handles the player's """MIND""" essentially it lets them pick a shrimp after their shrimp dies.

var player_name = ""
var player_id = null
var shrimp = null

var picked_shrimp = "res://testing_shrimp.tscn"

#called by client when they want to spawn a new shrimp.
func spawn_shrimp():
	if shrimp:
		return
	rpc("setup_shrimp_node", picked_shrimp)
	sync_up()

remotesync func setup_shrimp_node(new_shrimp):
	var chosen_shrimp = load(new_shrimp).instance()
	add_child(chosen_shrimp)
	chosen_shrimp.set_network_master(player_id)
	chosen_shrimp.setup_vars()
	shrimp = chosen_shrimp
	$bar.visible = true

remotesync func set_player_name(new_name):
	player_name = new_name
	$bar/name.text = new_name

func set_player_id(new_id):
	player_id = new_id

func set_cursor(tex):
	$destination/Sprite2.set_texture(tex)

func sync_up():
	if shrimp:
		shrimp.set_puppet_vars()

func set_shrimp(path):
	picked_shrimp = path

func on_shrimp_death():
	$bar.visible = false
	shrimp.queue_free()
	shrimp = null
