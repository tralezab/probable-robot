extends Node

var tabs = null

func _ready():
	tabs = get_node("Selection")
	setup_tabs()

func setup_tabs():
	var cursors = tabs.get_node("Cursors")
	for cur in range(16):
		var name = "cross"+str(cur+1)
		cursors.add_item(name, load("res://shrimpicons/"+name+".png"))

func _on_Button_pressed():
	tabs.visible = not tabs.visible
