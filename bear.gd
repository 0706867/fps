extends KinematicBody

var speed = 15
var current_health = 10
var hit = false
var collider
var target
var timer 
var turn = false

func _ready():
	Globals.enemy_amount +=1														#adds to total enemy amount in global script
	current_health = 20																#bear health
	collider = $CollisionShape
	timer = 0
	#location = Vector3(get_parent().transform.origin)

func _process(delta):
	move(delta)
	timer += 0.015 


func move(delta):
#	var direction = (get_parent().transform.origin).normalized()
	var direction = Vector3(-2,0,0) 
	var location_x = Vector3(transform.origin.x + (1*speed), 0,0)
	move_and_slide(location_x, Vector3())
	
	if timer >= 2:
		turn = true
		if turn:
			if rotation.y == 0 :
				rotation.y = 180
			if rotation.y == 180 :
				rotation.y = 0
			speed = -speed
			timer = 0
			turn = false


func bullet_hit(damage, bullet_pos):															#allows the target to take damage
	hit = true																		#enemy is hit
	if hit:																	#if enemy is hit, lower the enemy amount
		Globals.enemy_amount -=1
		collider.disabled = true
		visible = false

