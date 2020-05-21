extends Node2D

#imsxz, this script handles the player's """MIND""" essentially it lets them pick a shrimp after their shrimp dies.

var player_id = ""
var player_name = ""
var shrimp = null

var test_shrimp = preload("res://testing_shrimp.tscn")
var one_shot_johnny = preload("res://one_shot_johnny.tscn")

#called by world setup and when shrimp die
func spawn_shrimp():
	randomize()
	#var pickable_shrimps = [test_shrimp, one_shot_johnny]
	#pickable_shrimps.shuffle()
	#var chosen_shrimp = pickable_shrimps.front().instance()
	var chosen_shrimp = test_shrimp.instance()
	add_child(chosen_shrimp)
	chosen_shrimp.setup_vars()
	shrimp = chosen_shrimp
	#if !current: need to add the code where bots autospawn


func set_id(new_id):
	player_id = new_id

func set_name(new_name):
	player_name = new_name
