extends RigidBody

const GRENADE_DAMAGE = 40

const GRENADE_TIME = 3
var grenade_timer = 0

const EXPLOSION_WAIT_TIME = 0.48
var explosion_wait_timer = 0

var attached = false
var attach_point = null

var rigid_shape
var grenade_mesh
var blast_area
var explosion_particles

var player_body

func _ready():
	rigid_shape = $Collision_Shape
	grenade_mesh = $Sticky_Grenade
	blast_area = $Blast_Area
	explosion_particles = $Explosion

	explosion_particles.emitting = false
	explosion_particles.one_shot = true

	$Sticky_Area.connect("body_entered", self, "collided_with_body")
	

	#same as grenade.gd except this function
func collided_with_body(body):

	if body == self:																#dont attach to itself
		return

	if player_body != null:															#dont attach to the player
		if body == player_body:
			return

	if attached == false:															#if its not attached to anything, set the new position as the collided location
		attached = true
		attach_point = Spatial.new()
		body.add_child(attach_point)
		attach_point.global_transform.origin = global_transform.origin

		rigid_shape.disabled = true													#disable the physics

		mode = RigidBody.MODE_STATIC												#make the rigid body static (wont move)


func _process(delta):

	if attached == true:															#if it is attached
		if attach_point != null:													#if a attached point exists
			global_transform.origin = attach_point.global_transform.origin			#change the location to the location of attached collider

	if grenade_timer < GRENADE_TIME:												#if time till explosion is less than time required to explode
		grenade_timer += delta														#add time
		return
	else:																			#if time till explosion is not less than time required to explode
		if explosion_wait_timer <= 0:												#if explosion animation timer is less than 0
			explosion_particles.emitting = true										#emit particles

			grenade_mesh.visible = false											#make the grenade invisible
			rigid_shape.disabled = true												#disable the body

			mode = RigidBody.MODE_STATIC											#make the grenade static

			var bodies = blast_area.get_overlapping_bodies()						#anything colliders in the blast redius
			for body in bodies:
				if body.has_method("bullet_hit"):									#do damage if they have "bullet_hit" function
					body.bullet_hit(GRENADE_DAMAGE, body.global_transform.looking_at(global_transform.origin, Vector3(0, 1, 0)))



		if explosion_wait_timer < EXPLOSION_WAIT_TIME:								#if explosion animation timer is less than time required, add time
			explosion_wait_timer += delta

			if explosion_wait_timer >= EXPLOSION_WAIT_TIME:							#if explosion animation timer is higher than time required
				if attach_point != null:											#if the grenade is attached to something, destroy the object, the grenade is attached to
					attach_point.queue_free()
				queue_free()														#destroy the grenade when explosion animation tinmer is higher than time requried
