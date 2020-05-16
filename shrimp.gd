extends RigidBody2D


const SPEED = 100
const MAX_SPEED = 200


onready var destination = get_parent().get_node("Destination")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	var direction_to = destination.global_position - global_position
	rotation = direction_to.angle()
	if abs(rad2deg(rotation)) > 90:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false
	linear_velocity = (direction_to * SPEED * delta)
	

func _process(delta):
	if Input.is_action_pressed("rightclick"):
		destination.global_position = get_global_mouse_position()
	pass
