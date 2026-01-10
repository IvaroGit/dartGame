extends Node3D

enum GameState { DART_THROW, BAG, TRANSITION }
var game_state = GameState.DART_THROW
@export var cameras: Array[Camera3D]=[]
var current_camera_index=1
var spinBag=false
var bobHight

@onready var camera: Camera3D = $world/Player/cameraPivot/MainCamera
@onready var dart_bag: Node3D = $world/dartBag/Sketchfab_Scene
@onready var bag_view_target: Node3D = $world/dartBag/BagViewTarget

@export var bag_distance := 0.25
@export var bag_height_offset := 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	update_camera()
	
	

func update_camera():
	for i in range(cameras.size()):
		cameras[i].current=(i==current_camera_index)
		
func enter_bag_view():
	game_state = GameState.TRANSITION

	var tween = dart_bag.move_to(
		bag_view_target.global_position,
		bag_view_target.global_rotation
	)

	tween.finished.connect(func():
		dart_bag.open()
		game_state = GameState.BAG
	)
func exit_bag_view():
	game_state = GameState.TRANSITION

	var tween = dart_bag.move_to(
		dart_bag.home_position,
		dart_bag.home_rotation
	)

	dart_bag.close()

	tween.finished.connect(func():
		game_state = GameState.DART_THROW
	)
func _input(event):
	if event.is_action_pressed("1"):
		current_camera_index=(current_camera_index+1)%cameras.size()
		update_camera()


func _on_button_pressed() -> void:
	if(game_state==GameState.BAG):
		exit_bag_view()
	elif (game_state==GameState.DART_THROW):
		enter_bag_view()

func _process(delta: float) -> void:
	pass
	#bobHight=Engine.get_frames_drawn()*0.03

	#if(spinBag):
		#$world/dartBag/Sketchfab_Scene.rotation_degrees.y+=60*delta
		#$world/dartBag/Sketchfab_Scene.position.y+=0.2*sin(bobHight)*delta
