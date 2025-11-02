extends CharacterBody2D

@export var max_health = 100
@export var enemy_speed = 200
@export var attack_range = 150  # La portée de l'attaque
@export var attack_cooldown = 1.0  # Temps d'attente entre les attaques en secondes
@export var knife_chance: float = 0.5
@export var sword_chance: float = 0.3
@export var axe_chance: float = 0.2
var weapon_name: String = ""
var attack_damage = 0

var current_health
var time_since_last_attack = 0.0  # Compteur de temps écoulé depuis la dernière attaque
var player: CharacterBody2D = null  # Store the player reference
var player_last_position: Vector2 = Vector2.ZERO  # Initialize properly

func _ready():
	current_health = max_health
	weapon_name = pick_random_weapon()
	
	if ItemDatabase.has_item(weapon_name):
		attack_damage = ItemDatabase.get_item_stat(weapon_name, "damage")
	else:
		attack_damage = 5 #fallback/default damage

func _process(delta: float):
	time_since_last_attack += delta  # Mettre à jour la temporisation à chaque frame
	player_detection()

func _on_area_2d_body_entered(body: Node2D):
	if body.name == "Player":
		player = body  # Store reference to the player
		print("Player has entered the detection area!")

func _on_area_2d_body_exited(body: Node2D):
	if body.name == "Player":
		player = null  # Remove player reference when they exit
		print("Player has left the detection area!")

func take_damage(damage):
	current_health -= damage
	if current_health < 1:
		# Report kill to the main scene
		var main = get_tree().get_first_node_in_group("main")
		if main: #Make sure that main was actually assigned, this way we avoid errors
			main.increment_kill_count()
			# Drop the weapon to player's inventory
		InventoryManager.add_item(weapon_name)
		queue_free()
	print(current_health)


func attack():
	if time_since_last_attack >= attack_cooldown:
		if player and position.distance_to(player.position) <= attack_range:
			time_since_last_attack = 0.0
			print("Attaque réussie!")
			player.take_damage(attack_damage)
			await get_tree().create_timer(2.0).timeout  # wait 2 seconds

func player_detection():
	if player:
		# Set RayCast2D to target the player correctly
		$RayCast2D.target_position = to_local(player.global_position)
		# Check if the RayCast2D is colliding with the player
		if $RayCast2D.is_colliding():
			var collider = $RayCast2D.get_collider()
			if collider == player:
				# Enemy faces the player
				look_at(player.global_position)
				# Update the last known player position
				player_last_position = player.global_position
				# Attack the player if in range
				attack()
	# Move towards last known player position if lost sight
	if player_last_position != Vector2.ZERO:
		var direction = (player_last_position - position).normalized()
		velocity = direction * enemy_speed
		move_and_slide()

func pick_random_weapon() -> String:
	var total_weight = knife_chance + sword_chance + axe_chance
	var roll = randf() * total_weight
	# Drop chances are relative — only proportions matter:
	# 0.5, 0.3, 0.2 works the same as 50, 30, 20 or 5, 3, 2.

	if roll < knife_chance:
		return "Knife"
	elif roll < knife_chance + sword_chance:
		return "Sword"
	elif roll < total_weight:
		return "Axe"
	
	print("Warning: No item selected — check drop rates.")
	return "Knife" # fallback
