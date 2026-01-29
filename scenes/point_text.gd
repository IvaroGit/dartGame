extends MeshInstance3D
@export var lifetime = 1
var timer
var rise = 0.1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	timer=lifetime


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if(timer>0):
		timer-=delta
		position.y+=rise*delta
		if(timer<=0):
			queue_free()
