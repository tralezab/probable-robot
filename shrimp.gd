extends RigidBody2D
class_name Shrimp, "res://shrimpclass_icon.png"

var speed = 150
var max_health = 100
var health = 100

var attack_cooldown = 50
var attack_timer = 0
var attack_damage = 25
onready var attacksprite = $Attack
onready var attackarea = $Attack_Area

onready var destination = get_parent().get_node("Destination")
var infoholder = null
var healthbar = null
var namelabel = null

puppet var puppet_pos = Vector2()
puppet var puppet_motion = Vector2()
puppet var puppet_rotation = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	rotation = deg2rad(rand_range(-180,180))
	mode = RigidBody2D.MODE_STATIC

func setup_vars():
	infoholder = get_parent().get_node("bar")
	healthbar = infoholder.get_node("health")
	healthbar.modulate = Color(0,1,0,1)
	namelabel = infoholder.get_node("name")
	#RSETS
	rset("puppet_motion", linear_velocity)
	rset("puppet_pos", position)
	rset("puppet_rotation", rotation)

func _physics_process(delta):
	if is_network_master():
		attack_timer -= 1
		var direction_to = destination.global_position - global_position
		if destination.visible != false:
			rotation = direction_to.angle()
			##REMINDER: SET THE SHRIMP TO SLOWLY LOSE MOMENTUM FOR COLLISIONS
			mode = RigidBody2D.MODE_RIGID
		else:
			mode = RigidBody2D.MODE_STATIC
		if direction_to.length() < 10:
			linear_velocity = Vector2.ZERO
			set_target_position(null)
		else:
			linear_velocity = direction_to.clamped(speed) * speed * delta
		infoholder.position = position
		rset("puppet_motion", linear_velocity)
		rset("puppet_pos", position)
		rset("puppet_rotation", rotation)
	else:
		position = puppet_pos
		infoholder.position = position
		linear_velocity = puppet_motion
		rotation = puppet_rotation

	if abs(rad2deg(rotation)) > 90:
		$Sprite.flip_v = true
	else:
		$Sprite.flip_v = false

func _process(_delta):
	if!is_network_master():
		return
	if Input.is_action_pressed("rightclick"):
		self.rpc("set_target_position", get_global_mouse_position())
	if Input.is_action_just_pressed("leftclick") and attack_timer <= 0:
		attack_move()

remotesync func set_target_position(set_position):
	if is_network_master():
		if set_position != null:
			# No out of bounds action
			var mouse_pos = get_global_mouse_position()
			var world_size = get_viewport().size
			destination.global_position = Vector2(clamp(mouse_pos[0],0,world_size[0]),clamp(mouse_pos[1],0,world_size[1]))
			destination.visible = true
			return
		destination.global_position = global_position
		destination.visible = false

func attack_move():
	attack_timer = attack_cooldown
	rpc("display_attacksprite", 0.5)
	var attacked = attackarea.get_overlapping_bodies()
	for shramp in attacked:
		if shramp == attackarea.get_parent():
			continue
		# Can't reference your own class. At least this won't crash
		if shramp.has_method("adjust_health"):
			shramp.rpc("adjust_health",-attack_damage)

func set_name(name):
	namelabel.set_text(name)

remotesync func adjust_health(amount):
	health += min(amount, max_health)
	var percentage = float(health)/float(max_health)
	healthbar.modulate = Color(1 - percentage,percentage,0,1)
	if health <= 0:
		get_parent().spawn_shrimp()
		queue_free()

# Someone change tex to text instead of a texture stream before you sync this.
func set_cursor(tex):
	destination.get_node("Sprite2").set_texture(tex)

remotesync func display_attacksprite(time):
	attacksprite.visible = true
	yield(get_tree().create_timer(time), "timeout")
	attacksprite.visible = false
