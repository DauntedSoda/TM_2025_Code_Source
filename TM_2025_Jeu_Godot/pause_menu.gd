extends VBoxContainer

var base_url: String = ""
var self_opened: bool = false
var is_dead = false
var mode = ""
var locked = false

func _ready() -> void:
	if OS.get_name() == "Web":
		base_url = JavaScriptBridge.eval("window.location.origin")
	else:
		base_url = "undefined"

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		toggle_menu("Resume")

func toggle_menu(text) -> void:
	if !locked:
		$Resume.text = text
		self_opened = !self_opened
		self.visible = self_opened
		get_tree().paused = true
		get_parent().get_node("pause_icon").visible = true
		if text == "Restart":
			locked = true

func _on_resume_pressed() -> void:
	if $Resume.text == "Restart":
		if OS.get_name() == "Web":
			JavaScriptBridge.eval("window.location.reload();")
	if !locked:
		get_parent().get_node("pause_icon").visible = false	
		toggle_menu("Resume")
		get_tree().paused = false
		get_parent().get_node("pause_icon").visible = false

func _on_exit_pressed() -> void:
	if OS.get_name() == "Web":
		var main_node = get_tree().get_first_node_in_group("main")
		main_node.save_game_state()
		await get_tree().create_timer(0.1).timeout
		var target_url = base_url + "/index.php"
		JavaScriptBridge.eval("window.location.href = '%s';" % target_url)
	else:
		print("Link error: Offline")
