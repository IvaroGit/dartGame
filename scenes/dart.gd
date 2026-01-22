extends RigidBody3D
var stuck := false

func _ready() -> void:
	for dart in get_tree().get_nodes_in_group("darts"):
		if dart != self:
			PhysicsServer3D.body_add_collision_exception(self.get_rid(), dart.get_rid())

func _physics_process(delta):
	if stuck:
		return

	var v := linear_velocity
	if v.length() < 0.001:
		return

	var dir := v.normalized()

	var right := Vector3.UP.cross(dir)
	if right.length() < 0.001:
		right = Vector3.RIGHT
	right = right.normalized()

	var up := dir.cross(right).normalized()

	var basis := Basis(
		right,
		-dir,
		up
	)
	global_transform.basis = basis

func _integrate_forces(state):
	if stuck:
		return

	if state.get_contact_count() > 0:
		var collider = state.get_contact_collider_object(0)
		if collider and collider.is_in_group("board"):
			stuck = true
			linear_velocity = Vector3.ZERO
			angular_velocity = Vector3.ZERO
			gravity_scale = 0
