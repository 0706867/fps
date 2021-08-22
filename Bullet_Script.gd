extends Spatial

var BULLET_SPEED = 70
var BULLET_DAMAGE = 15

const KILL_TIMER = 4
var timer = 0

var hit_something = false

func _ready():
	$Area.connect("body_entered", self, "collided")


func _physics_process(delta):
	var forward_dir = global_transform.basis.z.normalized()							#gets local z axis to find "forward"
	global_translate(forward_dir * BULLET_SPEED * delta)							#moves the bullet forward

	timer += delta
	if timer >= KILL_TIMER:															#if timer is higher than kill timer, bullet gets deleted, stops bullets from overloading the cpu
		queue_free()


func collided(body):
	if hit_something == false:														#check if collided body has "bullet hit" function and do damage
		if body.has_method("bullet_hit"):
			body.bullet_hit(BULLET_DAMAGE, global_transform)

	hit_something = true															#if yes, make "hit something" function true and delete bullet
	queue_free()
