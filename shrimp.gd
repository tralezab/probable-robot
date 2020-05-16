extends RigidBody2D

export var current = false
const SPEED = 150
const MAX_HEALTH = 100
var health = 100

onready var destination = get_parent().get_node("Destination")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	if !current:
		return
	var direction_to = destination.global_position - global_position
	if destination.global_position != global_position:
		rotation = direction_to.angle()
		if abs(rad2deg(rotation)) > 90:
			$Sprite.flip_v = true
		else:
			$Sprite.flip_v = false
			
		##REMINDER: SET THE SHRIMP TO SLOWLY LOSE MOMENTUM FOR COLLISIONS
		linear_velocity = Vector2.ZERO
	if direction_to.length() < 10:
		linear_velocity = Vector2.ZERO
		destination.global_position = global_position
		destination.visible = false
		pass
	else:
		linear_velocity = direction_to.clamped(SPEED) * SPEED * delta

func _process(delta):
	if !current:
		return
	if Input.is_action_pressed("rightclick"):
		destination.global_position = get_global_mouse_position()
		destination.visible = true
	if Input.is_action_just_pressed("leftclick"):
		print("attack")

func set_current(boo):
	current = boo
