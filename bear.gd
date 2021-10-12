extends KinematicBody

var speed = 30																		#bear speed
var hit = false																		#has the bear been hit
var collider																		#bears collision shape
var timer 																			#local timer used for how long bear walks for
var turn = false																	#has the bear turned

func _ready():
	Globals.enemy_amount +=1														#adds to total enemy amount in global script
	collider = $CollisionShape														#connect bears collisionshape to the variable
	timer = 0																		#reset the timer


func _process(delta):
	move(delta)
	timer += 1 * delta 																#time is being added based on frame rate, which wouldnt be affected by CPU power


func move(delta):
	var location_x = Vector3(transform.origin.x + (1*speed), 0,0)					#gets the local x position and add speed to it
	move_and_slide(location_x, Vector3())											#use the x position for moving
	
	if timer >= 2:																	#if timer hits 2 secs
		turn = true																	#make turn true
		if turn:																	#if turn in true
			rotate_object_local(Vector3(0,1,0), deg2rad(180))						#rotate the bear 180 degrees
			speed = -speed															#walk in opposite direction
			timer = 0																#reset the timer
			turn = false															#make turn false, whcih enables this loop to occur


func bullet_hit(damage, bullet_pos):															#allows the target to take damage
	hit = true																		#enemy is hit
	if hit:																	#if enemy is hit, lower the enemy amount
		Globals.enemy_amount -=1
		collider.disabled = true
		visible = false

