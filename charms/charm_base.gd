extends Node3D
class_name CharmBase

# Metadata
@export var charm_name: String = "New Charm"
@export var description: String = ""
@export var num_instance: PackedScene
var triggered=false
# Score logic
func apply(ctx) -> void:
	# Minimal implementation: override this in child scenes
	pass
