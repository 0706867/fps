extends RigidBody

const BASE_BULLET_BOOST = 9;														#force applied when shot

func _ready():
	pass

func bullet_hit(damage, bullet_global_trans):										#get the direction fo the bullet and apply the BASE BULLET BOOST to it in the direction
	var direction_vect = bullet_global_trans.basis.z.normalized() * BASE_BULLET_BOOST
	apply_impulse((bullet_global_trans.origin - global_transform.origin).normalized(), direction_vect * damage)
