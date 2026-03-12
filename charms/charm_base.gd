extends Node3D
class_name CharmBase
enum rarities {common,uncommon,rare,legendary,secret}
# Metadata
@export var charm_name: String = "New Charm"
@export var description: String = ""
@export var num_instance: PackedScene
@export var rarity := rarities.common
var triggered=false
# Score logic
func apply(ctx) -> void:
	# Minimal implementation: override this in child scenes
	pass
