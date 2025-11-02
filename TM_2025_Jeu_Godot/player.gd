extends CharacterBody2D

var inventory: Array = []
@export var speed = 400
var screen_size
@export var max_health = 10
var current_health
@onready var health_bar = $"CanvasLayer/Control/TextureProgressBar"
@export var attack_damage = 250
@onready var raycast = $"RayCast2D"
@export var min_distance_from_enemy = 20
@onready var joystick = $"CanvasLayer/Joystick"
var is_dead = false

# Bullet shooting variables
@export var bullet_scene: PackedScene  # Assign in editor
@export var shoot_cooldown = 0.3  # Time between shots
var time_since_last_shot = 0.0

func _ready():
	screen_size = get_viewport_rect().size
	current_health = max_health
	update_health_bar()
	raycast.enabled = false
	await get_tree().create_timer(0.25).timeout
	Input.action_release("ui_up")
	Input.action_release("ui_down")
	Input.action_release("ui_left")
	Input.action_release("ui_right")
	
	var joystick_nodes = get_tree().get_nodes_in_group("joystick")
	if joystick_nodes.size() > 0:
		joystick = joystick_nodes[0]
		print("Joystick trouvé :", joystick)
	else:
		print("Aucun joystick trouvé !")
	print(joystick)

func _input(event):
	if event is InputEventScreenTouch and event.pressed:
		shoot_bullet()  # Changed from perform_attack to shoot_bullet

func _process(delta: float):
	time_since_last_shot += delta
	
	player_movement(delta, speed)
	
	# Shoot with keyboard/mouse
	if Input.is_action_just_pressed("attack"):
		shoot_bullet()
	
	# Alternative: Hold to shoot continuously
	# if Input.is_action_pressed("attack") and time_since_last_shot >= shoot_cooldown:
	#     shoot_bullet()
	
	if DisplayServer.window_is_focused():
		player_movement(delta, speed)
	else:
		velocity = Vector2.ZERO

	if should_stop_moving():
		velocity = Vector2.ZERO
	else:
		move_and_slide()

func player_movement(delta, player_speed):
	var movement_direction = Vector2.ZERO
	var joystick_direction = joystick.get_movement()
	
	if joystick_direction != Vector2.ZERO:
		movement_direction = joystick_direction
	else:
		if Input.is_action_pressed("ui_up"):
			movement_direction.y -= 1
		if Input.is_action_pressed("ui_down"):
			movement_direction.y += 1
		if Input.is_action_pressed("ui_left"):
			movement_direction.x -= 1
		if Input.is_action_pressed("ui_right"):
			movement_direction.x += 1
	
	movement_direction = movement_direction.normalized()
	velocity = movement_direction * player_speed
	
	var mouse_position = get_global_mouse_position()
	var angle_to_mouse = (mouse_position - global_position).angle()
	rotation = angle_to_mouse
	move_and_slide()

func should_stop_moving() -> bool:
	for enemy in get_tree().get_nodes_in_group("enemies"):
		if position.distance_to(enemy.position) < min_distance_from_enemy:
			return true
	return false

# Shoot bullet function
func shoot_bullet():
	if time_since_last_shot < shoot_cooldown:
		return  # Still on cooldown
	
	if bullet_scene == null:
		print("Error: Bullet scene not assigned!")
		return
	
	time_since_last_shot = 0.0
	
	# Instantiate bullet
	var bullet = bullet_scene.instantiate()
	
	# Get the main scene to add bullet as its child
	var main = get_tree().get_first_node_in_group("main")
	if main:
		main.add_child(bullet)
	else:
		get_parent().add_child(bullet)
	
	# Set bullet position at player's position
	bullet.global_position = global_position
	
	# Set bullet direction toward mouse
	var mouse_pos = get_global_mouse_position()
	var direction = (mouse_pos - global_position).normalized()
	bullet.set_direction(direction)
	
	print("Bullet shot!")

# Keep the old melee attack function if you want both options
func perform_melee_attack():
	print("Attempting melee attack")
	raycast.enabled = true
	raycast.force_raycast_update()

	if raycast.is_colliding():
		print("Collision detected!")
		var enemy = raycast.get_collider() as CharacterBody2D
		if enemy:
			enemy.take_damage(attack_damage)
	
	raycast.enabled = false

# Health management functions
func take_damage(damage):
	current_health -= damage
	if current_health < 1:
		print("Player died")
		var main_node = get_tree().get_first_node_in_group("main")
		self.visible = false
		if main_node:
			main_node.game_over()
	update_health_bar()

func heal(heal_amount):
	current_health += heal_amount
	if current_health > max_health:
		current_health = max_health
	update_health_bar()

func update_health_bar():
	health_bar.value = current_health
