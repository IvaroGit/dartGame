extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bagLight = get_node("bagLight")
var opening=false
var closing=false
var fullyOpened=false
var fullyClosed=false

var home_position: Vector3
var home_rotation: Vector3

# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	 # Replace with function body.
	home_position = global_position
	home_rotation = global_rotation

# Called every frame. 'delta' is the elapsed time since the previous frame.
func move_to(target_pos: Vector3, target_rot: Vector3, duration := 0.6):
	var tween := create_tween()
	tween.set_parallel(true)
	tween.set_ease(Tween.EASE_IN_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)

	tween.tween_property(self, "global_position", target_pos, duration)
	tween.tween_property(self, "global_rotation", target_rot, duration)

	return tween

func open():
	animation_player.play("open")

func close():
	animation_player.play_backwards("open")
