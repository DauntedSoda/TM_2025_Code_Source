extends Node2D
var base_url = JavaScriptBridge.eval("window.origin") if JavaScriptBridge.eval("window.location.origin") else "undefined"

@export var mob_scene: PackedScene
@onready var debug_label1 = $DebugLabel1
@onready var debug_label2 = $DebugLabel2
@onready var save_debug_label = $SaveDebugLabel
var player: CharacterBody2D
var score
var kill_count = 0
var accumulated_time: float = 0.0
var saved_inventory = {}
var saved_position: Vector2 = Vector2.ZERO
var has_saved_position = false
var total_kills = 0
var total_playtime: float = 0.0

func _ready() -> void:
	player = get_node_or_null("/root/Main/Player")
	score = 0
	$StartTimer.start()
	check_session()
	load_game_state()

func _process(delta):
	total_playtime += delta
	accumulated_time += delta
	var save_interval = 10.0
	if accumulated_time >= save_interval:
		accumulated_time = 0.0
		print(str(save_interval) + " seconds passed. Total Playtime: ", int(total_playtime), " seconds")

func game_over():
	save_game_state()
	$ScoreTimer.stop()
	$MobTimer.stop()
	await get_tree().process_frame
	print("toggling menu")
	$Player/CanvasLayer/ui/pause_menu.toggle_menu("Restart")

func _on_mob_timer_timeout() -> void:
	var enemy = mob_scene.instantiate()
	var mob_spawn_location = $MobPath/MobSpawnLocation
	mob_spawn_location.progress_ratio = randf()
	var direction = mob_spawn_location.rotation + PI / 2
	enemy.position = mob_spawn_location.position
	direction += randf_range(-PI / 4, PI / 4)
	enemy.rotation = direction
	add_child(enemy)

func _on_score_timer_timeout() -> void:
	score += 1

func _on_start_timer_timeout() -> void:
	$MobTimer.start()
	$ScoreTimer.start()

func update_debug_label():
	debug_label2.text = "This label is reloaded on every kill:\nEnemies killed: %d\nTotal kills: %d\nTotal Playtime: %d" % [kill_count, total_kills, int(total_playtime)]

func increment_kill_count():
	kill_count += 1
	total_kills += 1
	print("Enemies killed:", kill_count)
	print("Total enemies killed:", total_kills)
	update_debug_label()

func check_session():
	var http = HTTPRequest.new()
	var url = base_url + "/check_session.php"
	add_child(http)
	http.request_completed.connect(_on_check_session_response)
	http.request(url)

func _on_check_session_response(result, response_code, headers, body):
	var text = body.get_string_from_utf8()
	print("Session check response:", text)
	debug_label1.text = "Server says: " + text

func save_game_state():
	var http = HTTPRequest.new()
	add_child(http)

	var inventory = InventoryManager.inventory
	var position = player.global_position if player else Vector2.ZERO
	print(position)

	var body = {
		"kill_count": kill_count,
		"inventory": inventory,
		"position_x": player.global_position.x,
		"position_y": player.global_position.y,
		"last_total_kills": total_kills,
		"last_total_playtime": int(total_playtime),
	}
	save_debug_label.text = str(body)
	var url = base_url + "/save_gamestate.php"
	var json_body = JSON.stringify(body)
	print(json_body)
	var headers = ["Content-Type: application/json"]

	http.request_completed.connect(on_save_response)
	http.request(
		url,
		headers,
		HTTPClient.METHOD_POST,
		json_body
	)
	save_debug_label.text = ("Request sent!")

func on_save_response(result, response_code, headers, body):
	var response_text = body.get_string_from_utf8()
	save_debug_label.text = ("Save response from server:" + response_text)

func load_game_state():
	var http = HTTPRequest.new()
	add_child(http)

	http.request_completed.connect(on_load_response)

	var url = base_url + "/load_gamestate.php"
	var headers = ["Content-Type: application/json"]
	http.request(url, headers)

func on_load_response(result, response_code, headers, body):
	var response = JSON.parse_string(body.get_string_from_utf8())
	
	if response and response.success:
		save_debug_label.text = "Load recieved"
		if response.inventory:
			if typeof(response.inventory) == TYPE_DICTIONARY:
				saved_inventory = response.inventory
				InventoryManager.inventory = saved_inventory
				print("Inventory loaded: ", saved_inventory)
			else:
				print("Inventory is not a dictionary:", response.inventory)

		if response.position_x != null and response.position_y != null:
			saved_position = Vector2(response.position_x, response.position_y)
			if player:
				player.set_global_position(saved_position)

		if response.last_total_kills:
			total_kills = response.last_total_kills
		if response.last_total_playtime:
			total_playtime = response.last_total_playtime
	else:
		save_debug_label.text = "Failed to load save data"
