extends Node3D


@export var cameras: Array[Camera3D]=[]
var current_camera_index=1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_camera()


func update_camera():
	for i in range(cameras.size()):
		cameras[i].current=(i==current_camera_index)
		

		
func _input(event):
	if event.is_action_pressed("1"):
		current_camera_index=(current_camera_index+1)%cameras.size()
		update_camera()
