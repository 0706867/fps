extends Control

export (String, FILE) var replay
export (String, FILE) var main

func _ready():
#connnects the 2 buttons to function below
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$end/replay.connect("pressed", self, "finish", ["replay"])
	$end/main_menu.connect("pressed", self, "finish", ["main_menu"])
	
func finish (button_name):
	if button_name == "replay":
		get_node("/root/Globals").load_new_scene(replay)
	if button_name == "main_menu":
		get_node("/root/Globals").load_new_scene(main)
		print(main)

