extends RigidBody2D

export var current = false
const SPEED = 150
const MAX_HEALTH = 100
var health = 100

const ATTACK_COOLDOWN = 50
var attack_timer = 0
var attack_damage = 25
onready var attacksprite = $Attack
onready var attackarea = $Attack_Area

onready var destination = get_parent().get_node("Destination")
var healthhud = null
var healthbar = null

# Called when the node enters the scene tree for the first time.
func _ready():
	mode = RigidBody2D.MODE_STATIC
	pass # Replace with function body.

func setup_vars():
	healthhud = get_parent().get_node("bar")
	healthbar = get_parent().get_node("bar").get_node("health")
	healthhud.global_position = global_position - Vector2(0, -40)
	healthbar.modulate = Color(0,1,0,1)
	pass

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
		mode = RigidBody2D.MODE_RIGID
	else:
		mode = RigidBody2D.MODE_STATIC
	if direction_to.length() < 10:
		linear_velocity = Vector2.ZERO
		destination.global_position = global_position
		destination.visible = false
		pass
	else:
		linear_velocity = direction_to.clamped(SPEED) * SPEED * delta
	healthhud.global_position = global_position - Vector2(0, -40)

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
			var percentage = float(shramp.health)/float(shramp.MAX_HEALTH)
			shramp.healthbar.modulate = Color(1 - percentage,percentage,0,1)
			if shramp.health <= 0:
				shramp.get_parent().spawn_shrimp()
				shramp.queue_free()
				#shramp.healthhud.modulate = Color(0,0,0,0)
	yield(get_tree().create_timer(0.5), "timeout")
	attacksprite.visible = false

func set_current(boo):
	current = boo
