extends StaticBody

const TARGET_HEALTH = 40
var current_health = 40

var broken_target_holder

# The collision shape for the target.
# NOTE: this is for the whole target, not the pieces of the target.
var target_collision_shape

const TARGET_RESPAWN_TIME = 14
var target_respawn_timer = 0

export (PackedScene) var destroyed_target

func _ready():
	broken_target_holder = get_parent().get_node("Broken_Target_Holder")
	target_collision_shape = $Collision_Shape


func _physics_process(delta):
	if target_respawn_timer > 0:													#if timer is higher than 0, reduce the timer
		target_respawn_timer -= delta

		if target_respawn_timer <= 0:												#if the tiemr is below or equal to 0

			for child in broken_target_holder.get_children():						#all broken pieces of the target, get deleted
				child.queue_free()

			target_collision_shape.disabled = false									#enable the original shape
			visible = true															#make it visible
			current_health = TARGET_HEALTH											#reset the target HP


func bullet_hit(damage, bullet_transform):											#aloows the atrget to takedamage
	current_health -= damage														#reduce the damage from current health

	if current_health <= 0:															#if health is below 0
		var clone = destroyed_target.instance()										#creates a new instance of the broken pieces
		broken_target_holder.add_child(clone)										#add child tp the holder

		for rigid in clone.get_children():											#makes teh being destroyed effect using the centre of the target and direction
			if rigid is RigidBody:
				var center_in_rigid_space = broken_target_holder.global_transform.origin - rigid.global_transform.origin
				var direction = (rigid.transform.origin - center_in_rigid_space).normalized()
				# Apply the impulse with some additional force (I find 12 works nicely).
				rigid.apply_impulse(center_in_rigid_space, direction * 12 * damage)

		#reset the timer and disable the collider 
		target_respawn_timer = TARGET_RESPAWN_TIME

		target_collision_shape.disabled = true
		visible = false
