extends Spatial
var current_health = 10

func _ready():
	Globals.enemy_amount +=1														#adds to total enemy amount in global script
	current_health = 20																#bear health

func bullet_hit(damage):															#allows the target to take damage
	current_health -= damage														#reduce the damage from current health
	Globals.enemy_amount -=1														#lowers number of enemies in the game

	if current_health <= 0:															#if health is below 0
		print("hi")
