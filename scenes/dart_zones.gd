extends Node3D
signal zone_hit(name)
func _ready():
	for child in get_children():
		if child is Area3D:
			child.body_entered.connect(_on_area_body_entered.bind(child))

func _on_area_body_entered(body, area):
	var points
	if area.name == "zone_tripple_nr18":
		points = 200
		print("hit tripple 18")
	if body is RigidBody3D:
		emit_signal("zone_hit",area.name)
