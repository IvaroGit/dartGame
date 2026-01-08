extends RigidBody3D

var stuck := false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_body_entered(body):
	if stuck:
		return

	if body.is_in_group("board"):
		stuck = true
		call_deferred("stick")

func stick():
	freeze = true
	collision_layer = 0
	collision_mask = 0
