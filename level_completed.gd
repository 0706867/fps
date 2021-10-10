extends Control

export (String, FILE) var replay
export (String, FILE) var main

func _ready():
#connnects the 2 buttons to function below
	Globals.enemy_amount = 0
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	$end/replay.connect("pressed", self, "finish", ["replay"])			#replay button to the main_level scene
	$end/main_menu.connect("pressed", self, "finish", ["main_menu"])	#main_menu button to the main_menu scene
	
func finish (button_name):
	if button_name == "replay":											#copied from the main_menu.gd script, names chanegd to fit this script
		get_node("/root/Globals").load_new_scene(replay)
	if button_name == "main_menu":
		get_node("/root/Globals").load_new_scene(main)
		print(main)

