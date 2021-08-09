extends RigidBody

const GRENADE_DAMAGE = 60

const GRENADE_TIME = 2
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 0.48
var explosion_wait_timer = 0

var rigid_shape
var grenade_mesh
var blast_area
var explosion_particles

func _ready():																		#assign names to nodes for convenience 
	rigid_shape = $Collision_Shape
	grenade_mesh = $Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion

	explosion_particles.emitting = false											#are particle contantly playing
	explosion_particles.one_shot = true												#are particles showing up once

func _process(delta):

	if grenade_timer < GRENADE_TIME:												#if the alive time for the grenade is lower than time until it explodes, add delta time to the time alive.
		grenade_timer += delta
		return
	else:
		if explosion_wait_timer <= 0:												#if time since exploded is <=0, emit the particle, make the grenade invisiblie, disable physics, make the body static so it doesn't move
			explosion_particles.emitting = true

			grenade_mesh.visible = false
			rigid_shape.disabled = true

			mode = RigidBody.MODE_STATIC

			var bodies = blast_area.get_overlapping_bodies()
			for body in bodies:														#for every "body"/object in blast radius which has "bullet hit" function, do damage.
				if body.has_method("bullet_hit"):
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0)))

			# This would be the perfect place to play a sound!


		if explosion_wait_timer < EXPLOSION_WAIT_TIME:								#if time since explosion is lower than time until grenade gets removed, add delta
			explosion_wait_timer += delta

			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:							#iftime since explosion ius higher than time until grenade gets removed, remove it.
				queue_free()
