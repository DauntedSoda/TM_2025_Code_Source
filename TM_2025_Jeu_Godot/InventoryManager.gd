extends Node
@onready var debug_label_inventory = get_node("/root/Main/DebugLabelInventory")
var inventory := {}

func add_item(item_name: String, amount := 1):
	if inventory.has(item_name):
		inventory[item_name] += amount
	else:
		inventory[item_name] = amount
	debug_label_inventory.text = "Inventory: " + JSON.stringify(inventory)
