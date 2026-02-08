extends Node3D
@onready var dart_zones: Node3D = $board/CollisionShape3D/DartZones
@export var number: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func process_score(points,name,hit_index):
	var num_instance = number.instantiate()
	num_instance.position = Vector3(-0.3, randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	(num_instance.mesh as TextMesh).text = "+"+str(points)
	add_child(num_instance)
