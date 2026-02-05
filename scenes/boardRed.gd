extends Node3D
@onready var dart_zones: Node3D = $board/CollisionShape3D/DartZones
@export var number: PackedScene
signal board_scored(payload)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	dart_zones.zone_scored.connect(process_score)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
func process_score(points,name,hit_index):
	var payload = _build_payload(points,name,hit_index)
	var num_instance = number.instantiate()
	num_instance.position = Vector3(-0.3, randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	(num_instance.mesh as TextMesh).text = "+"+str(points)
	add_child(num_instance)

func _build_payload(base_value: int,zone_id: String, hit_index: int) -> Dictionary:
	var payload := {
		effects = [],
		meta = {
			zone_id = zone_id,
			times_hit = hit_index
		}
	}
	# Board decides what effects it produces
	payload.effects.append({
		type = Effects.EffectType.ADD_POINTS,
		amount = 50
	})
	payload.effects.append({
		type = Effects.EffectType.ADD_DART,
		amount = 10
	})
	# Example: special board
	# payload.effects.append({
	#	type = Effects.EffectType.ADD_COINS,
	#	amount = 2
	# })
	return payload
	
