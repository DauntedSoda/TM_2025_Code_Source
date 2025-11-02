extends Control

@export var max_range = 50  # Distance maximale de déplacement
var start_position
var touch_active = false
var movement_vector = Vector2.ZERO
@onready var viewport_size = get_viewport().get_visible_rect().size


func _ready():


	start_position = $JoystickStick.position
	add_to_group("joystick")  # Ajoute le joystick au groupe
	# Vérifie si l'appareil n'a PAS d'interface tactile (donc un PC) et masque le joystick
# Vérifie si l'appareil est un PC et masque le joystick
	var os_name = OS.get_name()
	if os_name == "Windows" or os_name == "Linux" or os_name == "macOS":
		$JoystickStick.visible = false
		$JoystickBase.visible = false


func _input(event):
	if event is InputEventScreenTouch:
		touch_active = event.pressed
		if not touch_active:
			$JoystickStick.rect_position = start_position
			movement_vector = Vector2.ZERO

	if event is InputEventScreenDrag and touch_active:
		var new_pos = event.position - global_position
		var offset = (new_pos - start_position).limit_length(max_range)
		$JoystickStick.position = start_position + offset
		movement_vector = offset.normalized()

func get_movement():
	return movement_vector
