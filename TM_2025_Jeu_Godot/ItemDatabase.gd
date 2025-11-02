extends Node

var items = {
	"Knife": {"damage": 5, "description": "A small sharp blade."},
	"Sword": {"damage": 10, "description": "A sharp blade with reach."},
	"Axe": {"damage": 15, "description": "Heavy but strong."}
}

func has_item(name: String) -> bool:
	return items.has(name)

func get_item_stat(name: String, stat: String):
	return items.get(name, {}).get(stat, null)
