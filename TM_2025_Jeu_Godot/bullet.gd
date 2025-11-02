extends Area2D

@export var speed = 5000
@export var damage = 2500
var direction = Vector2.ZERO

func _ready():
	# Auto-destroy bullet after 3 seconds to prevent memory leaks
	await get_tree().create_timer(3.0).timeout
	queue_free()

func _process(delta):
	if direction != Vector2.ZERO:
		position += direction * speed * delta

func set_direction(new_direction: Vector2):
	direction = new_direction.normalized()
	# Rotate bullet to face direction
	rotation = direction.angle()

func _on_body_entered(body):
	# Check if bullet hit an enemy
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()  # Destroy bullet on impact
	# Optional: destroy on hitting walls/obstacles
	elif body is StaticBody2D or body is TileMap:
		queue_free()
