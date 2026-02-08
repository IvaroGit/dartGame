extends CharmBase

@onready var particle: GPUParticles3D = $GPUParticles3D

var trigger_zones = ["zone_bull", "zone_outer_bull", "zone_outer_slice_1"]
var bonus_score = 100

func apply(ctx) -> void:
	if ctx.zone_id not in trigger_zones:
		return
	ctx.score += bonus_score
	particle.emitting = true
	var popup := num_instance.instantiate()
	popup.position = Vector3(0, 0.4, 0)
	popup.rotation_degrees.y=0
	var mesh_instance := popup as MeshInstance3D
	mesh_instance.mesh = mesh_instance.mesh.duplicate()  # ⭐ FIX ⭐
	var text_mesh := mesh_instance.mesh as TextMesh
	text_mesh.text = "+" + str(bonus_score)
	add_child(popup)
