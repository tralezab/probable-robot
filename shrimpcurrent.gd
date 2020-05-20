extends Node2D

#imsxz, this script handles the player's """MIND""" essentially it lets them pick a shrimp after their shrimp dies.

export var current = false
var player_id = ""
var player_name = ""
var current_possessed_shrimp = null

var test_shrimp = preload("res://testing_shrimp.tscn")
var one_shot_johnny = preload("res://one_shot_johnny.tscn")

#called by world setup and when shrimp die
func spawn_shrimp():
	randomize()
	var pickable_shrimps = [test_shrimp, one_shot_johnny]
	pickable_shrimps.shuffle()
	var chosen_shrimp = pickable_shrimps.front().instance()
	add_child(chosen_shrimp)
	chosen_shrimp.setup_vars()
	current_possessed_shrimp = chosen_shrimp
	var viewport_size = get_tree().get_root().get_size()
	var vector_x = rand_range(0, viewport_size.x)
	var vector_y = rand_range(0, viewport_size.y)
	global_position = Vector2(vector_x,vector_y) 
	#if !current: need to add the code where bots autospawn
	if current:
		$Shrimp.set_current(true)

func set_id(new_id):
	player_id = new_id

func set_name(new_name):
	player_name = new_name
