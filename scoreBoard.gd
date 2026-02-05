extends Node3D
@onready var label_3d: Label3D = $Label3D
var score=0
@onready var dart_zones: Node3D = $"../board/board/CollisionShape3D/DartZones"

func _ready() -> void:
	pass
func update_scoring_label(points):
	score+=points
	var text = str(score)
	label_3d.set_text(text)
