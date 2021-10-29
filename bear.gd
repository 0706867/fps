extends KinematicBody

var speed = 25																		#bear speed
var hit = false																		#has the bear been hit
var collider																		#bears collision shape
var timer 																			#local timer used for how long bear walks for
var turn = false																	#has the bear turned


func _ready():
	Globals.enemy_amount +=1														#adds to total enemy amount in global script
	collider = $CollisionShape														#connect bears collisionshape to the variable
	timer = 0																		#reset the timer
	if rad2deg((get_parent().rotation.y)) >= 315 and rad2deg((get_parent().rotation.y)) <= 360 or +\
	rad2deg((get_parent().rotation.y)) <= 45 and rad2deg((get_parent().rotation.y)) >= 0 or +\
	rad2deg((get_parent().rotation.y)) >= -45 and rad2deg((get_parent().rotation.y)) <= 0 or +\
	rad2deg((get_parent().rotation.y)) <= -315 and rad2deg((get_parent().rotation.y)) >= 0:
		get_parent().rotation.y = deg2rad(1)											#set face to 0 degrees or facing right
	elif rad2deg((get_parent().rotation.y)) >= 135 and rad2deg((get_parent().rotation.y)) <= 225 or +\
	rad2deg((get_parent().rotation.y)) <= -135 and rad2deg((get_parent().rotation.y)) >= -225:
		get_parent().rotation.y = deg2rad(180)											#set face to 180 degrees or facing left
	elif rad2deg((get_parent().rotation.y)) >= 45 and rad2deg((get_parent().rotation.y)) <= 135 or +\
	rad2deg((get_parent().rotation.y)) <= -45 and rad2deg((get_parent().rotation.y)) >= -135:
		get_parent().rotation.y = deg2rad(90)											#set face to 90 degrees or facing UP
	elif rad2deg((get_parent().rotation.y)) >= 225 and rad2deg((get_parent().rotation.y)) <= 315 or +\
	rad2deg((get_parent().rotation.y)) <= -225 and rad2deg((get_parent().rotation.y)) >= -315:
		get_parent().rotation.y = deg2rad(270)											#set face to 270 degrees or facing down

func _process(delta):
	move(delta)
	timer += 1 * delta 																#time is being added based on frame rate, which wouldnt be affected by CPU power


func move(delta):
	var location_z = Vector3(0,0,transform.origin.z + (1*speed))					#gets the local z position and add speed to it
	var location_x = Vector3(transform.origin.x + (1*speed),0,0)					#gets the local x position and add speed to it

	if !hit:
		if rad2deg((get_parent().rotation.y)) >= 135 and rad2deg((get_parent().rotation.y)) <= 225 or rad2deg((get_parent().rotation.y)) <= -135 and rad2deg((get_parent().rotation.y)) >= -225:
			move_and_slide(location_z, Vector3())											#move left
		elif rad2deg((get_parent().rotation.y)) >= 315 and rad2deg((get_parent().rotation.y)) <= 360 or rad2deg((get_parent().rotation.y)) <= 45 and rad2deg((get_parent().rotation.y)) >= 0 or rad2deg((get_parent().rotation.y)) >= -45 and rad2deg((get_parent().rotation.y)) <= 0 or rad2deg((get_parent().rotation.y)) <= -315 and rad2deg((get_parent().rotation.y)) >= 0:
			move_and_slide(-location_z, Vector3())											#move right
		elif rad2deg((get_parent().rotation.y)) >= 45 and rad2deg((get_parent().rotation.y)) <= 135 or rad2deg((get_parent().rotation.y)) <= -45 and rad2deg((get_parent().rotation.y)) >= -135:
			move_and_slide(-location_x, Vector3())											#move up
		elif rad2deg((get_parent().rotation.y)) >= 225 and rad2deg((get_parent().rotation.y)) <= 315 or rad2deg((get_parent().rotation.y)) <= -225 and rad2deg((get_parent().rotation.y)) >= -315:
			move_and_slide(location_x, Vector3())											#move down
		if timer >= 2:																	#if timer hits 2 secs
			turn = true																	#make turn true
			if turn:																	#if turn in true
				rotate_object_local(Vector3(0,1,0), deg2rad(180))						#rotate the bear 180 degrees
				speed = -speed															#walk in opposite direction
				timer = 0																#reset the timer
				turn = false															#make turn false, whcih enables this loop to occur

func bullet_hit(damage, bullet_pos):												#allows the target to take damage
	hit = true																		#enemy is hit
	if hit:																			#if enemy is hit, lower the enemy amount
		Globals.enemy_amount -=1
		collider.disabled = true													#the player can not collide with the bear if its dead
		get_parent().rotation.z = deg2rad(-90)										#rotate the local z axis to the bear looks dead (lying on the ground)
		get_parent().transform.origin.y = 6											#move the bear up when it dies to avoid unusual clipping of meshes
		Globals.score +=100															#add to the player score
		Globals.play_sound("enemy_death", false, get_parent().transform.origin)		#play the enemy death noise, dont loop, play it at the body
