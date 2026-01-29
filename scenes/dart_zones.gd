extends Node3D
signal zone_hit(name)
signal zone_scored(score)
var darts_hit := {}
func _ready():
	for child in get_children():
		if child is Area3D:
			child.body_entered.connect(_on_area_body_entered.bind(child))

func _on_area_body_entered(body, area):
	
	if body is not RigidBody3D:
		return
	if darts_hit.has(body):
		return
	darts_hit[body] = true
	
	var points
	var name_str = str(area.name) 

	if name_str.begins_with("zone_tripple_nr"):
		points = int(name_str.split("_")[-1]) * 3
	elif name_str.begins_with("zone_dubble_nr"):
		points = int(name_str.split("_")[-1]) * 2
	elif name_str.begins_with("zone_inner_slice_") or name_str.begins_with("zone_outer_slice_"):
		points = int(name_str.split("_")[-1])
	elif name_str == "zone_bull":
		points = 50
	elif name_str == "zone_outer_bull":
		points = 25
	else:
		points=0
	if body is RigidBody3D:
		emit_signal("zone_hit",area.name)
		emit_signal("zone_scored",points)
