extends RigidBody

var current_health = 10
var hit = false
var collider

func _ready():
	Globals.enemy_amount +=1														#adds to total enemy amount in global script
	current_health = 20																#bear health
	collider = $CollisionShape

func bullet_hit(damage, bullet_pos):															#allows the target to take damage
	hit = true																		#enemy is hit
	if hit == true:																	#if enemy is hit, lower the enemy amount
		Globals.enemy_amount -=1
		collider.disabled = true
		visible = false
