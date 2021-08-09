extends Control

func _ready():
	$OS_Label.text = "OS: " + OS.get_name()											#gets Operating System and displays
	$Engine_Label.text = "Godot version: " + Engine.get_version_info()["string"]	#gets Godot engine version and displays

func _process(delta):
	$FPS_Label.text = "FPS: " + str(Engine.get_frames_per_second())					#gets Frames per second and displays
