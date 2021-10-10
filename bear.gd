extends KinematicBody

var speed = 200
var current_health = 10
var hit = false
var collider
var target
var walking = Vector3(20, 0,10)
func _ready():
	Globals.enemy_amount +=1														#adds to total enemy amount in global script
	current_health = 20																#bear health
	collider = $CollisionShape

func _process(delta):
	move(delta)
	
func move(delta):
	var direction = (get_parent().transform.origin - transform.origin).normalized()
	move_and_slide(direction * speed * delta, Vector3.UP)


func bullet_hit(damage, bullet_pos):															#allows the target to take damage
	hit = true																		#enemy is hit
	if hit:																	#if enemy is hit, lower the enemy amount
		Globals.enemy_amount -=1
		collider.disabled = true
		visible = false

