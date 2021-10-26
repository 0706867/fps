extends KinematicBody

const GRAVITY = -70																#how hard the player is pulled to the ground
var vel = Vector3()																	#player velocity
const MAX_SPEED = 35																#maximum speed the player can travel
const JUMP_SPEED = 35																#speed when jumping
const ACCEL = 4.5																	#player's speed of acceleration
const MAX_SPRINT_SPEED = 60															#maximum speed while sprinting
const SPRINT_ACCEL = 20																#acceleration when spriniting
var is_sprinting = false															#is the player sprinting?
var reloading_weapon = false														#is the player reloading a weapon?
var flashlight																		#placeholder for a flashlight
var dir = Vector3()																	#direction of an object in a (vector)3 dimentional space
const DEACCEL= 15																	# rate of deceleration
const MAX_SLOPE_ANGLE = 40															#maximum angle the player can climb
var camera																			#PH for camera
var rotation_helper																	#helps the player rotate locally without moving the global body
var MOUSE_SENSITIVITY = 0.5															#sensitivity of the camera for looking around
var animation_manager																#manages animations
var current_weapon_name = "UNARMED"													#starting weapon
var weapons = {"UNARMED":null, "KNIFE":null, "PISTOL":null, "RIFLE":null}			#all the weapons
const WEAPON_NUMBER_TO_NAME = {0:"UNARMED", 1:"KNIFE", 2:"PISTOL", 3:"RIFLE"}		#assigns weapons to numbers so the player can change weapons by using numbers
const WEAPON_NAME_TO_NUMBER = {"UNARMED":0, "KNIFE":1, "PISTOL":2, "RIFLE":3}		#same as above
var changing_weapon = false															#is the player changing weapons
var changing_weapon_name = "UNARMED"												#name of the weapon changed to
var health = 100																	# player health
var UI_status_label																	#is the UI displaying?
var UI_enemy_label																	#shows details related to the enemy
var simple_audio_player = preload("res://Simple_Audio_Player.tscn")					#loads audioplayer
var JOYPAD_SENSITIVITY = 2															#joypad sensitivity
const JOYPAD_DEADZONE = 0.15														#joypad deadzone to stop jitters 
var mouse_scroll_value = 0															#amount of scrolls done
const MOUSE_SENSITIVITY_SCROLL_WHEEL = 0.5											#how much does 1 physical mouse scroll add up to in game mouse scroll
const MAX_HEALTH = 150																#maximum health allowed for the player
var grenade_amounts = {"Grenade":2, "Sticky Grenade":2}								#amount of each grenade
var current_grenade = "Grenade"														#current grenade/spawning grenade
var grenade_scene = preload("res://Grenade.tscn")									#load grenade scene and assign it to "grenade"
var sticky_grenade_scene = preload("res://Sticky_Grenade.tscn")						#load sticky grenade scene and assign it to "sticky_grenade"
const GRENADE_THROW_FORCE = 50														#how far and fast the grenade will be thrown
var grabbed_object = null															#is the player grabbing anything
const OBJECT_THROW_FORCE = 120														#how far and fast the grabbed object will be thrown
const OBJECT_GRAB_DISTANCE = 7														#how far away the grabbed object will be from the player
const OBJECT_GRAB_RAY_DISTANCE = 10													#how far away can the player grab something
const RESPAWN_TIME = 4																#time required to respawn after death
var dead_time = 0																	#how long has the player been dead
var is_dead = false																	#is the player dead?
var globals
export (String, FILE) var endgame
var zoom

func _ready():																		#function called when the project starts
	var zoom = false
#assign names to nodes
	camera = $Rotation_Helper/Camera
	rotation_helper = $Rotation_Helper

	animation_manager = $Rotation_Helper/Model/Animation_Player
	animation_manager.callback_function = funcref(self, "fire_bullet")

	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

	weapons["KNIFE"] = $Rotation_Helper/Gun_Fire_Points/Knife_Point
	weapons["PISTOL"] = $Rotation_Helper/Gun_Fire_Points/Pistol_Point
	weapons["RIFLE"] = $Rotation_Helper/Gun_Fire_Points/Rifle_Point

	var gun_aim_point_pos = $Rotation_Helper/Gun_Aim_Point.global_transform.origin


	for weapon in weapons:															#for every weapon in weapons array, if the weapon is not "unarmed", add the gun to the player, rotate it locally and set the gun aim point
		var weapon_node = weapons[weapon]
		if weapon_node != null:
			weapon_node.player_node = self
			weapon_node.look_at(gun_aim_point_pos, Vector3(0, 1, 0))
			weapon_node.rotate_object_local(Vector3(0, 1, 0), deg2rad(180))


	current_weapon_name = "UNARMED"
	changing_weapon_name = "UNARMED"
#assigns names ot nodes
	UI_status_label = $HUD/Panel/Gun_label
	UI_enemy_label = $HUD/Panel2/Gun_label
	flashlight = $Rotation_Helper/Flashlight
#gets globals script
	globals = get_node("/root/Globals")
#gets spawn location
	global_transform.origin = globals.get_respawn_position()


func _physics_process(delta):														#handles physics and other processes
	if !is_dead:																	#if the player is not dead, enable input, view input and movement functions
		process_input(delta)
		process_view_input_xbox(delta)
		process_view_input_ps(delta)
		process_movement(delta)
	if (grabbed_object == null):													#if the player is not holding something, let the player change and reload weapons
		process_changing_weapons(delta)
		process_reloading(delta)
#always show UI and let the player respawn
	process_UI(delta)
	process_respawn(delta)



func process_input(delta):															#processes input types
# Changing weapons.
	var weapon_change_number = WEAPON_NAME_TO_NUMBER[current_weapon_name]			#assigns number to weapons in current_weapon_name array

	if Input.is_key_pressed(KEY_1):													#key 1 is fourth weapon in array (this gives us the rifle, i did this to keep consistency with other FPS)
		weapon_change_number = 3
	if Input.is_key_pressed(KEY_2):													#key 2 is third weapon in array (this gives us pistol, to keep consistency with other FPS)
		weapon_change_number = 2
	if Input.is_key_pressed(KEY_3):													#key 3 is second weapon in array (this gives us the knife, also keeps consistency with other FPS)
		weapon_change_number = 1
	if Input.is_key_pressed(KEY_4):													#key 4 is first weapon in array (this gives us the unarmed/hands, althoguh most fps dont have this, i thought it kept consistency with the numbers)
		weapon_change_number = 0

	if Input.is_action_just_pressed("shift_weapon_positive"):						#if "shift weapon positive" is pressed get the next weapon in current weapon name array
		weapon_change_number += 1
	if Input.is_action_just_pressed("shift_weapon_negative"):						#if "shift weapon negative" is pressed get the previous weapon in current weapon name array
		weapon_change_number -= 1

	weapon_change_number = clamp(weapon_change_number, 0, WEAPON_NUMBER_TO_NAME.size() - 1)#stops the player from going past or below the weapon amount in array

	if changing_weapon == false:													#if the player is not changing weapons
		if reloading_weapon == false:												#if the player is not reloading weapons
			if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:	#if the weapon requested is not already equipped, change the current weapon to requested e.g key 2 is pressed but knife is already equipped this code will not run
				changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
				changing_weapon = true
		if WEAPON_NUMBER_TO_NAME[weapon_change_number] != current_weapon_name:		#if player is not changing weapons and the requested weapon is not equpped, change weapons, set changing weapons to true  and change the weapons to scroll value, e.g. knife will equip when mouse is scrolled 2 times.
			changing_weapon_name = WEAPON_NUMBER_TO_NAME[weapon_change_number]
			changing_weapon = true
			mouse_scroll_value = weapon_change_number
# ----------------------------------
# Firing the weapons
	if Input.is_action_pressed("fire"):												#if fire button is pressed, player is not reloading or changing weapons, and the ammo in current weapon is higher than 0, shoot
		if reloading_weapon == false:
			if changing_weapon == false:
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:
					if current_weapon.ammo_in_weapon > 0:
						if animation_manager.current_state == current_weapon.IDLE_ANIM_NAME:
							animation_manager.set_animation(current_weapon.FIRE_ANIM_NAME)
					else:															#if not, reload the weapon
						reloading_weapon = true
# ----------------------------------
# Sprinting
	if Input.is_action_pressed("movement_sprint"):									#if sprinting is pressed,enable it else disable it, this enables hold sprinting, to make it toggle replace, below with commented code:
		#if(is_sprinting == true and Input.is_action_pressed("movement_sprint"):
			#is_sprinting = false
		#else 
		#is_sprinting = true 
		is_sprinting = true
	else:
		is_sprinting = false
# ----------------------------------
# Turning the flashlight on/off
	if Input.is_action_just_pressed("flashlight"):									#if key for flashlight is pressed, check if its on, disable if it is, if not enable it
		if flashlight.is_visible_in_tree():
			flashlight.hide()
		else:
			flashlight.show()
# ----------------------------------
# Walking
	dir = Vector3()																	#gets direction from  all 3 axis
	var cam_xform = camera.get_global_transform()									#puts the camera in the face of the player

	var input_movement_vector = Vector2()											#set movement to 2d, only using x and y

	if Input.is_action_pressed("movement_forward"):									#add to y if forward is pressed
		input_movement_vector.y += 1
		if $Timer.time_left <= 1:													#timer for how often the audio will play
			create_sound("Footstep", transform.origin)
			$Timer.start(1.25)
	if Input.is_action_pressed("movement_backward"):								#subtract from  y if backwards is pressed
		input_movement_vector.y -= 1
		if $Timer.time_left <= 1:													#timer for how often the audio will play
			create_sound("Footstep", transform.origin)
			$Timer.start(1.25)
	if Input.is_action_pressed("movement_left"):									#subtract from  x if left  is pressed
		input_movement_vector.x -= 1
		if $Timer.time_left <= 1:													#timer for how often the audio will play
			create_sound("Footstep", transform.origin)
			$Timer.start(1.25)
	if Input.is_action_pressed("movement_right"):									#add to x if right is pressed
		input_movement_vector.x += 1
		if $Timer.time_left <= 1:													#timer for how often the audio will play
			create_sound("Footstep", transform.origin)
			$Timer.start(1.25)
	# Add joypad input if one is present (changes depending on the function provided)
	if Input.get_connected_joypads().size() > 0:

		var joypad_vec = Vector2(0, 0)

		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 0), -Input.get_joy_axis(0, 1))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))

		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))
		input_movement_vector += joypad_vec

# Add joypad input if one is present == PS
	if Input.get_connected_joypads().size() > 0:

		var joypad_vec = Vector2(0, 0)

		if OS.get_name() == "Windows" or OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 0), -Input.get_joy_axis(0, 1))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 1), Input.get_joy_axis(0, 2))

		if joypad_vec.length() < JOYPAD_DEADZONE:
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		input_movement_vector += joypad_vec
	
	input_movement_vector = input_movement_vector.normalized()

#zooming in
	if Input.is_action_pressed("ads") :												#if ads key is preseed (right click)
		camera.fov = 50																#camera fov will be 50
	else :																			#if not, (by default)
		camera.fov = 90																#fov will be 90


# Basis vectors are already normalized.
	dir += -cam_xform.basis.z * input_movement_vector.y
	dir += cam_xform.basis.x * input_movement_vector.x
# ----------------------------------
# Jumping
	if is_on_floor():																#if the player is in the air, can not jump
		if Input.is_action_just_pressed("movement_jump"):							#if jump key is pressed, set y of velocity to jump speed
			vel.y = JUMP_SPEED
# ----------------------------------
	# Capturing/Freeing the cursor
	if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:							#if mouse if visible, make hide it/ not let it leave the screen.
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
# ----------------------------------
# Reloading
	if reloading_weapon == false:													#if weapon is being reloaded or changed
		if changing_weapon == false:
			if Input.is_action_just_pressed("reload"):								#if the reload key is pressed, get the current weapon being used
				var current_weapon = weapons[current_weapon_name]
				if current_weapon != null:											#if th current wepaon is not unarmed
					if current_weapon.CAN_RELOAD == true:							#if the weapon can reload, set the reloading animation, change the reloading stage to yes
						var current_anim_state = animation_manager.current_state
						var is_reloading = false
						for weapon in weapons:										#for every weapon in the array, get the current weapon
							var weapon_node = weapons[weapon]
							if weapon_node != null:									#if weapon is not unarmed and current animation  is reloading, set realodign variable to true
								if current_anim_state == weapon_node.RELOADING_ANIM_NAME:
									is_reloading = true
						if is_reloading == false:									#if the weapon can reload but is not in the array and the reloading weapon variable is false, make it true
							reloading_weapon = true
# ----------------------------------
# Changing and throwing grenades

	if Input.is_action_just_pressed("change_grenade"):								#if change grenade is pressed, change it from current to different one
		if current_grenade == "Grenade":
			current_grenade = "Sticky Grenade"
		elif current_grenade == "Sticky Grenade":
			current_grenade = "Grenade"
	
	if Input.is_action_just_pressed("fire_grenade"):								#if grenade is thrown, and there is more than 0 ammo, reduce the ammo by 1
		if grenade_amounts[current_grenade] > 0:
			grenade_amounts[current_grenade] -= 1

			var grenade_clone
			if current_grenade == "Grenade":										#make a new instance depending on the current grenade
				grenade_clone = grenade_scene.instance()
			elif current_grenade == "Sticky Grenade":
				grenade_clone = sticky_grenade_scene.instance()
				# Sticky grenades will stick to the player if we do not pass ourselves
				grenade_clone.player_body = self									#treats player body as self, so it wont stick to it

			get_tree().root.add_child(grenade_clone)								#add the thrown greande to the scene, get the location and rotation
			grenade_clone.global_transform = $Rotation_Helper/Grenade_Toss_Pos.global_transform
			grenade_clone.apply_impulse(Vector3(0, 0, 0), grenade_clone.global_transform.basis.z * GRENADE_THROW_FORCE)
# ----------------------------------

# Grabbing and throwing objects

	if Input.is_action_just_pressed("throw") and current_weapon_name == "UNARMED":	#if throw is pressed and current weapon is unarmed
		if grabbed_object == null:													#if there is nothing grabbed
			var state = get_world().direct_space_state

			var center_position = get_viewport().size / 2
			var ray_from = camera.project_ray_origin(center_position)
			var ray_to = ray_from + camera.project_ray_normal(center_position) * OBJECT_GRAB_RAY_DISTANCE

			var ray_result = state.intersect_ray(ray_from, ray_to, [self, $Rotation_Helper/Gun_Fire_Points/Knife_Point/Area])
			if !ray_result.empty():													#if ray is interacting with soemthing
				if ray_result["collider"] is RigidBody:								#if the interacted object has rigidbody collider, grab it
					grabbed_object = ray_result["collider"]
					grabbed_object.mode = RigidBody.MODE_STATIC

					grabbed_object.collision_layer = 0
					grabbed_object.collision_mask = 0

		else:																		#if there is something grabbed, we throw it in the direction the camera is facing
			grabbed_object.mode = RigidBody.MODE_RIGID

			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE)

			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1

			grabbed_object = null

	if grabbed_object != null:														#if something is being grabbed, set its location and rotation
		grabbed_object.global_transform.origin = camera.global_transform.origin + (-camera.global_transform.basis.z.normalized() * OBJECT_GRAB_DISTANCE)
# ----------------------------------
	for i in get_slide_count():														#gets the colliders player is interacting with
		var collision = get_slide_collision(i)
		if collision.collider.name == "endzone" and Globals.enemy_amount <= 0:									#if named endzone, scene changes to endgame
			get_node("/root/Globals").load_new_scene(endgame)



func process_movement(delta):                                                    #handles the movement / lets the player move
	dir.y = 0
	dir = dir.normalized()

	vel.y += delta * GRAVITY

	var hvel = vel
	hvel.y = 0

	var target = dir
	if is_sprinting:																#if player is sprinting, change the speed to max sprining speed, if not sprinting change the current speed to max walking speed
		target *= MAX_SPRINT_SPEED
	else:
		target *= MAX_SPEED

	var accel
	if dir.dot(hvel) > 0:															#if the player is moving and sprinting is pressed, sprint
		if is_sprinting:
			accel = SPRINT_ACCEL
		else:
			accel = ACCEL
	else:																			#if the player is not moving, decelerate
		accel = DEACCEL

	hvel = hvel.linear_interpolate(target, accel * delta)
	vel.x = hvel.x
	vel.z = hvel.z
	vel = move_and_slide(vel, Vector3(0, 1, 0), 0.05, 4, deg2rad(MAX_SLOPE_ANGLE))

func _input(event):																	#lets the player use cursor when widow is not focused
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotation_helper.rotate_x(deg2rad(event.relative.y * MOUSE_SENSITIVITY))
		self.rotate_y(deg2rad(event.relative.x * MOUSE_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot

	if event is InputEventMouseButton and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:	#if mouse button is pressed when mouse is in captured mode
		if event.button_index == BUTTON_WHEEL_UP or event.button_index == BUTTON_WHEEL_DOWN:	#if mouse button is either scroll up or scroll down
			if event.button_index == BUTTON_WHEEL_UP:											#if its scroll up, add to the scroll value 
				mouse_scroll_value += MOUSE_SENSITIVITY_SCROLL_WHEEL
			elif event.button_index == BUTTON_WHEEL_DOWN:										#if its scroll down, subtract from the scroll value
				mouse_scroll_value -= MOUSE_SENSITIVITY_SCROLL_WHEEL

			mouse_scroll_value = clamp(mouse_scroll_value, 0, WEAPON_NUMBER_TO_NAME.size() - 1)	#assigns scroll value to wepaons in the array

			if changing_weapon == false:														#if a mouse buttons is pressed, player can only change weapons when not reloading or changing weapons 
				if reloading_weapon == false:
					var round_mouse_scroll_value = int(round(mouse_scroll_value))
					if WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value] != current_weapon_name:
						changing_weapon_name = WEAPON_NUMBER_TO_NAME[round_mouse_scroll_value]
						changing_weapon = true
						mouse_scroll_value = round_mouse_scroll_value

	if is_dead:																		#if the player is dead, dont run this code again
		return

func process_changing_weapons(delta):												#lets the player change weapons
	if changing_weapon == true:														#if the weapon is being changed
	
		var weapon_unequipped = false												#make weapon unequipped false
		var current_weapon = weapons[current_weapon_name]							#get the current weapon

		if current_weapon == null:													#if the current weapon is unarmed, make the weapon unequip-able
			weapon_unequipped = true
		else:																		#if its not unarmed
			if current_weapon.is_weapon_enabled == true:							#if the current weapon is in use
				weapon_unequipped = current_weapon.unequip_weapon()					#unequip the current weapon
			else:																	#if the weapon is not in use, unequip it
				weapon_unequipped = true

		if weapon_unequipped == true:												#if the weapon is unequipped

			var weapon_equipped = false												#the weapon is not yet equipped
			var weapon_to_equip = weapons[changing_weapon_name]						#get the requested weapon

			if weapon_to_equip == null:												#same as above but for equipping weapon
				weapon_equipped = true
			else:
				if weapon_to_equip.is_weapon_enabled == false:
					weapon_equipped = weapon_to_equip.equip_weapon()
				else:
					weapon_equipped = true

			if weapon_equipped == true:
				changing_weapon = false
				current_weapon_name = changing_weapon_name
				changing_weapon_name = ""

func fire_bullet():																	#lets the player fire bullets
	if changing_weapon == true:														#if player is changing the weapon, dont fire
		return
	weapons[current_weapon_name].fire_weapon(transform.origin)										#fire the current weapon when this function is called


func process_UI(delta):																#controls User Interface for the player
	if current_weapon_name == "UNARMED" or current_weapon_name == "KNIFE":			#gets variables and converts them to strings, which lets the canvas display it 
		# First line: Health, second line: Grenades, third line: enemies
		UI_status_label.text = "HEALTH: " + str(health) + \
			"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade]) 
	else:
		var current_weapon = weapons[current_weapon_name]
		# First line: Health, second line: weapon and ammo, third line: grenades, fourth line: enemies
		UI_status_label.text = "HEALTH: " + str(health) + \
			"\nAMMO: " + str(current_weapon.ammo_in_weapon) + "/" + str(current_weapon.spare_ammo) + \
			"\n" + current_grenade + ": " + str(grenade_amounts[current_grenade])
	
	UI_enemy_label.text = "Enemies Left: " + str(Globals.enemy_amount) + \
							"\nScore: " + str(Globals.score)


func process_reloading(delta):														#lets the player reload
	if reloading_weapon == true:													#if weapon is able to reload
		var current_weapon = weapons[current_weapon_name]							#get the current weapon
		if current_weapon != null:													#if its not unarmed
			current_weapon.reload_weapon()											#reload weapon
		reloading_weapon = false													#make the weapon unable to reload

func create_sound(sound_name, position=null):										#using sounds, function required sound name, position is required if used in 3D
	globals.play_sound(sound_name, false, position)									#plays the sound it recieves(sound_name), dont loop the audio (false), set the position of the audio (position)


# XBOX
func process_view_input_xbox(delta):														#camera controller for xbox 

	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

	# NOTE: Until some bugs relating to captured mice are fixed, we cannot put the mouse view
	# rotation code here. Once the bug(s) are fixed, code for mouse view rotation code will go here!

	# ----------------------------------
	# Joypad rotation

	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() > 0:

		if OS.get_name() == "Windows":
			joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "X11":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))
		elif OS.get_name() == "OSX":
			joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))

		if joypad_vec.length() < JOYPAD_DEADZONE:									#helps make the controls smooth by only letting the controller work when not in the deadzone
			joypad_vec = Vector2(0, 0)
		else:
			joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		rotation_helper.rotate_x(deg2rad(joypad_vec.y * JOYPAD_SENSITIVITY))

		rotate_y(deg2rad(joypad_vec.x * JOYPAD_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot
	# ----------------------------------

#PS - same code as xbox, using different keys
func process_view_input_ps(delta):													#camera controller for play station (made usable using a different name as according to the tutorial only 1 was supposed to be used)
	if Input.get_mouse_mode() != Input.MOUSE_MODE_CAPTURED:
		return

   # NOTE: Until some bugs relating to captured mice are fixed, we cannot put the mouse view
   # rotation code here. Once the bug(s) are fixed, code for mouse view rotation code will go here!

   # ----------------------------------
   # Joypad rotation

	var joypad_vec = Vector2()
	if Input.get_connected_joypads().size() > 0:

		if OS.get_name() == "Windows" or OS.get_name() == "X11":
		   joypad_vec = Vector2(Input.get_joy_axis(0, 2), Input.get_joy_axis(0, 3))
		elif OS.get_name() == "OSX":
		   joypad_vec = Vector2(Input.get_joy_axis(0, 3), Input.get_joy_axis(0, 4))

		if joypad_vec.length() < JOYPAD_DEADZONE:
		   joypad_vec = Vector2(0, 0)
		else:
		   joypad_vec = joypad_vec.normalized() * ((joypad_vec.length() - JOYPAD_DEADZONE) / (1 - JOYPAD_DEADZONE))

		rotation_helper.rotate_x(deg2rad(joypad_vec.y * JOYPAD_SENSITIVITY))

		rotate_y(deg2rad(joypad_vec.x * JOYPAD_SENSITIVITY * -1))

		var camera_rot = rotation_helper.rotation_degrees
		camera_rot.x = clamp(camera_rot.x, -70, 70)
		rotation_helper.rotation_degrees = camera_rot 
   # ----------------------------------

func add_health(additional_health):													#runs when called
	health += additional_health														#add additonal health to the current health
	health = clamp(health, 0, MAX_HEALTH)											#stops the health from going over the maximum

func add_ammo(additional_ammo):
	if (current_weapon_name != "UNARMED"):											#if the current weapon is not unarmed
		if (weapons[current_weapon_name].CAN_REFILL == true):						#if the weapon can refill (has lower than default ammo)
			weapons[current_weapon_name].spare_ammo += weapons[current_weapon_name].AMMO_IN_MAG * additional_ammo #add amounts of ammo depending on the pickup size

func add_grenade(additional_grenade):												#same as above but for grenades
	grenade_amounts[current_grenade] += additional_grenade
	grenade_amounts[current_grenade] = clamp(grenade_amounts[current_grenade], 0, 4)

func bullet_hit(damage, bullet_hit_pos):											#gets the the location of bullet's collision area and the damage from the source
	health -= damage																#reduce HP based on damage of the source

func process_respawn(delta):														#lets the player respawn

	# If we've just died
	if health <= 0 and !is_dead:													#if the health is below 0 and the player is not dead
		$Body_CollisionShape.disabled = true										#disable body
		$Feet_CollisionShape.disabled = true

																					#change the current weapon to unarmed
		changing_weapon = true
		changing_weapon_name = "UNARMED"

																					#show the death screen
		$HUD/Death_Screen.visible = true

																					#hide the UI and crosshair
		$HUD/Panel.visible = false
		$HUD/Crosshair.visible = false

	#reset the death time
		dead_time = RESPAWN_TIME
		is_dead = true

																					#drop any picked up item
		if grabbed_object != null:
			grabbed_object.mode = RigidBody.MODE_RIGID
			grabbed_object.apply_impulse(Vector3(0, 0, 0), -camera.global_transform.basis.z.normalized() * OBJECT_THROW_FORCE / 2)

			grabbed_object.collision_layer = 1
			grabbed_object.collision_mask = 1

			grabbed_object = null

																					#if player is dead (works the same as (if is_dead == true), written shorter for convenience) 
	if is_dead:
		dead_time -= delta

		var dead_time_pretty = str(dead_time).left(3)
		$HUD/Death_Screen/Label.text = "You died\n" + dead_time_pretty + " seconds till respawn"

																					#if the respawn time is 0, set the location as one of the spawning locations
		if dead_time <= 0:
			global_transform.origin = Globals.get_respawn_position()

																					#enable body colliders
			$Body_CollisionShape.disabled = false
			$Feet_CollisionShape.disabled = false

																					#hide death screen
			$HUD/Death_Screen.visible = false

																					#show UI and crosshair
			$HUD/Panel.visible = true
			$HUD/Crosshair.visible = true

																					#reset the weapons (ammo and default)
			for weapon in weapons:
				var weapon_node = weapons[weapon]
				if weapon_node != null:
					weapon_node.reset_weapon()
	
																					#reset health and grenades
			health = 100
			grenade_amounts = {"Grenade":2, "Sticky Grenade":2}
			current_grenade = "Grenade"

																					#make the player alive
			is_dead = false
