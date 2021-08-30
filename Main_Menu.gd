extends Control

var start_menu
var level_select_menu
var options_menu
#lets us assign scenes to variables.
export (String, FILE) var testing_area_scene
export (String, FILE) var space_level_scene
export (String, FILE) var ruins_level_scene
export (String, FILE) var main_level_scene
func _ready():
	start_menu = $Start_Menu
	level_select_menu = $Level_Select_Menu
	options_menu = $Options_Menu
#connect functions to nodes
	$Start_Menu/Button_Start.connect("pressed", self, "start_menu_button_pressed", ["start"])
	$Start_Menu/Button_Open_Godot.connect("pressed", self, "start_menu_button_pressed", ["open_godot"])
	$Start_Menu/Button_Options.connect("pressed", self, "start_menu_button_pressed", ["options"])
	$Start_Menu/Button_Quit.connect("pressed", self, "start_menu_button_pressed", ["quit"])

	$Level_Select_Menu/Button_Back.connect("pressed", self, "level_select_menu_button_pressed", ["back"])
	$Level_Select_Menu/Button_Level_Testing_Area.connect("pressed", self, "level_select_menu_button_pressed", ["testing_scene"])
	$Level_Select_Menu/Button_Level_Space.connect("pressed", self, "level_select_menu_button_pressed", ["space_level"])
	$Level_Select_Menu/Button_Level_Ruins.connect("pressed", self, "level_select_menu_button_pressed", ["ruins_level"])

	$Options_Menu/Button_Back.connect("pressed", self, "options_menu_button_pressed", ["back"])
	$Options_Menu/Button_Fullscreen.connect("pressed", self, "options_menu_button_pressed", ["fullscreen"])
	$Options_Menu/Check_Button_VSync.connect("pressed", self, "options_menu_button_pressed", ["vsync"])
	$Options_Menu/Check_Button_Debug.connect("pressed", self, "options_menu_button_pressed", ["debug"])

#make cursor visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
#set the sensitivity using globals script
	var globals = get_node("/root/Globals")
	$Options_Menu/HSlider_Mouse_Sensitivity.value = globals.mouse_sensitivity
	$Options_Menu/HSlider_Joypad_Sensitivity.value = globals.joypad_sensitivity


func start_menu_button_pressed(button_name):
	if button_name == "start":														#if button is named start, load the level selection scene and make menu invisible
		level_select_menu.visible = true
		start_menu.visible = false
	elif button_name == "open_godot":												#if button is named open godot, open this link on web browser 
		OS.shell_open("https://www.youtube.com/watch?v=ekXLVU0PcTg")
	elif button_name == "options":													#if button is named options, load ooptions scene and make menu invisible
		options_menu.visible = true
		start_menu.visible = false
	elif button_name == "quit":														#if button is named quit, close the game
		get_tree().quit()


func level_select_menu_button_pressed(button_name):									#buttons in level select
	if button_name == "back":														#if button named back is pressed, hide level selection and open menu
		start_menu.visible = true
		level_select_menu.visible = false
		
#assign scenes to each button and set mouse and joypad sensitivity
	elif button_name == "testing_scene":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(testing_area_scene)
	elif button_name == "space_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(space_level_scene)
	elif button_name == "ruins_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(ruins_level_scene)
	elif button_name == "main_level":
		set_mouse_and_joypad_sensitivity()
		get_node("/root/Globals").load_new_scene(main_level_scene)

#assigns scenes and functions to buttons in options scene
func options_menu_button_pressed(button_name):
	if button_name == "back":
		start_menu.visible = true
		options_menu.visible = false
	elif button_name == "fullscreen":
		OS.window_fullscreen = !OS.window_fullscreen
	elif button_name == "vsync":
		OS.vsync_enabled = $Options_Menu/Check_Button_VSync.pressed
	elif button_name == "debug":
		get_node("/root/Globals").set_debug_display($Options_Menu/Check_Button_Debug.pressed)

#sets mouse and joypad sensitivity using globals script
func set_mouse_and_joypad_sensitivity():
	var globals = get_node("/root/Globals")
	globals.mouse_sensitivity = $Options_Menu/HSlider_Mouse_Sensitivity.value
	globals.joypad_sensitivity = $Options_Menu/HSlider_Joypad_Sensitivity.value
