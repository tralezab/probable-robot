extends Node

var tabs = null

var class_dict = {"Basic":"res://testing_shrimp.tscn", "Glass Cannon":"res://one_shot_johnny.tscn", "Ethereal":"res://shrimp_code_scenes/ether.tscn"}

func _ready():
	tabs = get_node("Selection")
	setup_tabs()

func setup_tabs():
	var cursors = tabs.get_node("Cursors")
	for cur in range(16):
		var name = "cross"+str(cur+1)
		cursors.add_item(name, load("res://shrimpicons/"+name+".png"))

	var classes = tabs.get_node("Classes")
	for type in range(len(class_dict)):
		var name = class_dict.keys()[type]
		classes.add_item(name, load("res://shrimpicons/"+name+".png"))

func _on_respawn_pressed():
	if gamestate.player_node.shrimp == null:
		gamestate.player_node.spawn_shrimp()

func _on_Button_pressed():
	tabs.visible = not tabs.visible

func _on_Cursors_item_selected(index):
	var item = $Selection/Cursors.get_item_icon(index)
	gamestate.player_node.set_cursor(item)

#picking a class
func _on_class_selected(index):
	gamestate.player_node.set_shrimp(class_dict[class_dict.keys()[index]])


