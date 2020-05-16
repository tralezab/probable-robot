extends RigidBody2D

export var current = false
const SPEED = 150
const MAX_HEALTH = 100
var health = 100

const ATTACK_COOLDOWN = 50
var attack_timer = 0
var attack_damage = 50
onready var attacksprite = $Attack
onready var attackarea = $Attack_Area

onready var destination = get_parent().get_node("Destination")
onready var healthhud = get_parent().get_node("Healthbar")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	attack_timer -= 1
	if !current:
		return
	var direction_to = destination.global_position - global_position
	if destination.visible != false:
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
	healthhud.global_position = global_position
	###DOES NOT WOOOORK
	var current_health = health / MAX_HEALTH
	print(current_health)
	healthhud.modulate = Color(1,0,0,current_health)

func _process(_delta):
	if !current:
		return
	if Input.is_action_pressed("rightclick"):
		destination.global_position = get_global_mouse_position()
		destination.visible = true
	if Input.is_action_just_pressed("leftclick") and attack_timer <= 0:
		attack_move()

func attack_move():
	attack_timer = ATTACK_COOLDOWN
	attacksprite.visible = true
	var attacked = attackarea.get_overlapping_bodies()
	for shramp in attacked:
		if shramp == attackarea.get_parent():
			continue
		if shramp is RigidBody2D:
			shramp.health -= attack_damage
			if shramp.health <= 0:
				shramp.queue_free()
	yield(get_tree().create_timer(0.5), "timeout")
	attacksprite.visible = false

func set_current(boo):
	current = boo
