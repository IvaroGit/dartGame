extends Object
class_name Charm
@export var priority: int = 0
func modify_payload(payload: Dictionary) -> void:
	# Override this in child classes
	pass
