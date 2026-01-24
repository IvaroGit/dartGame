@tool
extends EditorScript

func _run():
	var root = get_tree().edited_scene_root
	var zone_script = load("res://BoardZone.gd")

	for node in root.get_children():
		if node is Area3D:
			node.set_script(zone_script)
