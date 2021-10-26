extends Node

var mouse_sensitivity = 0.08
var joypad_sensitivity = 2

# All the GUI/UI-related variables
var canvas_layer = null
const DEBUG_DISPLAY_SCENE = preload("res://Debug_Display.tscn")
var debug_display = null

# ------------------------------------
const MAIN_MENU_PATH = "res://Main_Menu.tscn"
const FINISH_PATH = "res://level_completed.tscn"
const POPUP_SCENE = preload("res://Pause_Popup.tscn")
var popup = null
var respawn_points = null

# All the audio files.

# You will need to provide your own sound files.
var audio_clips = {																	#attach names to audio clips for easier access
	"Pistol_shot": preload("res://sounds/gun_revolver_pistol_shot_04.wav"),
	"Rifle_shot": preload("res://sounds/gun_rifle_sniper_shot_01.wav"),
	"Gun_cock": preload("res://sounds/gun_semi_auto_rifle_cock_02.wav"),
	"Footstep" : preload("res://sounds/footstep.wav")
}

const SIMPLE_AUDIO_PLAYER_SCENE = preload("res://Simple_Audio_Player.tscn")
var created_audio = []

#amount of enemies alive 
var enemy_amount = 0

#playerscore
var score = 0

func _ready():
	canvas_layer = CanvasLayer.new()												#create a new canvas
	add_child(canvas_layer)															#puts the new canvas on screen
	randomize()
	score = 0

func load_new_scene(new_scene_path):												#defaults for loading new scenes
	get_tree().change_scene(new_scene_path)											#loads requested scene
	respawn_points = null															#makes 0 respawn points by default for each map

	for sound in created_audio:														#for every sound in audio, clear the created audio array. if sound is not empty (audio is playing), delete it
		if (sound != null):
			sound.queue_free()
	created_audio.clear()


func set_debug_display(display_on):
	if display_on == false:															#dont show debug display
		if debug_display != null:													#if display is on, delete it and make it off.
			debug_display.queue_free()
			debug_display = null
	else:																			#if debug display is off, make a new instance of it and add it on the canvas
		if debug_display == null:
			debug_display = DEBUG_DISPLAY_SCENE.instance()
			canvas_layer.add_child(debug_display)

func _process(delta):
	if Input.is_action_just_pressed("ui_cancel"):									#if "ui_cancel" key is pressed, if there is no popup, make a new popup
		if popup == null:
			popup = POPUP_SCENE.instance()

			popup.get_node("Button_quit").connect("pressed", self, "popup_quit")	#connect button quit to go back to main menu
			popup.connect("popup_hide", self, "popup_closed")						#connect button hide to hide the popup
			popup.get_node("Button_resume").connect("pressed", self, "popup_closed")#connect resume to resume the game
			popup.get_node("Button_finish").connect("pressed", self, "popup_finish")#connect button_finish in popup screen to finish function below
			canvas_layer.add_child(popup)											#add popup screen to canvas
			popup.popup_centered()													#starting position for the popup is in the centre of the screen

			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)							#show the cursor

			get_tree().paused = true												#pause the game
			

func popup_closed():																#when popup is closed, resume the game
	get_tree().paused = false

	if popup != null:																#if a popup exists, delete it
		popup.queue_free()
		popup = null


func popup_quit():																	#if quit pressed, resume the game, make the mouse visible, delete the popup and go back to main menu
	get_tree().paused = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if popup != null:
		popup.queue_free()
		popup = null

	load_new_scene(MAIN_MENU_PATH)

func popup_finish():																	#if finish is called, run the level_completed scene
	get_tree().paused = false

	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	if popup != null:
		popup.queue_free()
		popup = null

	load_new_scene(FINISH_PATH)


func get_respawn_position():														#set respawn points
	if respawn_points == null:														#if there are no respawn point, make the x=0,y=0,z=0 default
		return Vector3(0, 0, 0)
	else:																			#if its not empty, get the positions and set up the spawn points
		var respawn_point = int(rand_range(0, respawn_points.size()-1))
		return respawn_points[respawn_point].global_transform.origin

func play_sound(sound_name, loop_sound=false, sound_position=null):					#play the audio clip given, dont loop it (can be enabled) and dont has a position for audio(required for 3d audio)
	if audio_clips.has(sound_name):													#if the audio clips dictionary has audio name, play sound
		var new_audio = SIMPLE_AUDIO_PLAYER_SCENE.instance()						#create new audio instance
		new_audio.should_loop = loop_sound

		add_child(new_audio)
		created_audio.append(new_audio)												#add the audio to array

		new_audio.play_sound(audio_clips[sound_name], sound_position)

	else:																			#if it does not have audio name, send the error message in console
		print ("ERROR: cannot play sound that does not exist in audio_clips!")
