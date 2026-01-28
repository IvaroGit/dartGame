extends Node3D

func _ready():
	for child in get_children():
		if child is Area3D:
			child.body_entered.connect(_on_area_body_entered.bind(child))

func _on_area_body_entered(body, area):
	if body is RigidBody3D:
		print(body.name, area.name)
