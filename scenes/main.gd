extends Node3D

enum GameState { DART_THROW, BAG, TRANSITION }
var game_state = GameState.DART_THROW
@export var cameras: Array[Camera3D]=[]
var current_camera_index=1
var spinBag=false
var bobHight
var mouse = Vector2()
@onready var camera: Camera3D = $world/Player/cameraPivot/MainCamera
@onready var dart_bag: Node3D = $world/dartBag/Sketchfab_Scene
@onready var bag_view_target: Node3D = $world/dartBag/BagViewTarget
@onready var player: Node3D = $world/Player
@onready var dart: Node3D = $world/Player/DartRig
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
	if event is InputEventMouseMotion:
		mouse = event.position
		get_selection()
	if event is InputEventMouseButton:
		mouse = event.position
		get_selection()


func get_selection():
	var space := get_world_3d().direct_space_state
	
	var ray_origin := camera.project_ray_origin(mouse)
	var ray_dir := camera.project_ray_normal(mouse)
	var ray_end := ray_origin + ray_dir * 1000.0

	var query := PhysicsRayQueryParameters3D.create(ray_origin, ray_end)
	if player.darts.size() > 0:
		query.exclude = [player.darts[player.selected_index]]

	var result := space.intersect_ray(query)
	if not result:
		return

	var hit_node: Node = result.collider

	# Walk up the tree until we find a dart instance
	while hit_node and not player.darts.has(hit_node):
		hit_node = hit_node.get_parent()

	if hit_node == null:
		player.hovered_index =0
	player.hovered_index = player.darts.find(hit_node)
	if Input.is_action_just_pressed("mouseLeft"):
		player.selected_index = player.darts.find(hit_node)	
	
	player.lineup_darts()
func _on_button_pressed() -> void:
	if(game_state==GameState.BAG):
		exit_bag_view()
	elif (game_state==GameState.DART_THROW):
		enter_bag_view()

func _process(delta: float) -> void:
	pass
	#bobHight=Engine.get_frames_drawn()*0.03
