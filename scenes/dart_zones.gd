extends Node3D

const HITBOX_GROUP := "hitboxes"
const DART_GROUP := "darts"

func _ready() -> void:
	_add_hitboxes_to_group()
	_connect_all_hitboxes()

func _add_hitboxes_to_group() -> void:
	for hitbox in get_children():
		if hitbox is Area3D:
			hitbox.add_to_group(HITBOX_GROUP)

func _connect_all_hitboxes() -> void:
	for hitbox in get_tree().get_nodes_in_group(HITBOX_GROUP):
		if hitbox is Area3D:
			if not hitbox.is_connected("body_entered", Callable(self, "_on_hitbox_body_entered")):
				hitbox.connect("body_entered", Callable(self, "_on_hitbox_body_entered"))

func _on_hitbox_body_entered(hitbox: Area3D, body: Node) -> void:
	if body.is_in_group(DART_GROUP):
		print("Dart hit:", body.name, "on hitbox:", hitbox.name)
