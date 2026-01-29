extends Node3D
class_name main
enum GameState { DART_SELECT,DART_THROW, BAG, BAG_TRANSITION,DART_DROP_TRANSITION,DART_CHARGE}
@export var game_state := GameState.DART_THROW
@export var cameras: Array[Camera3D]=[]

@onready var power_label: Label = $UI/HUD/powerLabel

var current_camera_index=1
var spinBag=false
var throw_button_visible=false
var bobHight
var mouse = Vector2()
var selected_dart_index: int = -1
@onready var camera: Camera3D = $world/Player/cameraPivot/MainCamera
@onready var dart_bag: Node3D = $world/dartBag/Sketchfab_Scene
@onready var bag_view_target: Node3D = $world/dartBag/BagViewTarget
@onready var dart_drop_target: Node3D = $world/dartArea/dart_drop_target
var dart_home_positions: Array = []
var dart_home_rotations: Array = []
@onready var shop: Node3D = $world/shop
@onready var dart_zones: Node3D = $world/dartArea/board/CollisionShape3D/DartZones
@onready var hud: Control = $UI/HUD
@onready var player: Node3D = $world/Player
@onready var dart: Node3D = $world/Player/DartRig
@onready var throw_button: Control = $UI/HUD/button_container/Control
@onready var zone_label: Label = $UI/HUD/zoneLabel
@export var bag_distance := 0.25
@export var bag_height_offset := 0



func _ready() -> void:
	update_camera()
	dart_zones.zone_hit.connect(update_zone_label)
func update_zone_label(text):
	zone_label.set_text("Hit : "+ text)
func update_camera():
	for i in range(cameras.size()):
		cameras[i].current=(i==current_camera_index)
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
	var result := space.intersect_ray(query)
	if not result:
		return

	var hit_node: Node = result.collider

	while hit_node and not player.darts.has(hit_node):
		hit_node = hit_node.get_parent()

	if hit_node == null:
		player.hovered_index = -1
		return

	player.hovered_index = player.darts.find(hit_node)
	if Input.is_action_just_released("mouseLeft") and player.darts.has(hit_node):
		selected_dart_index = player.darts.find(hit_node)

		# Offset from dart tip toward top (local space)
		var pos = Vector3(hit_node.get_child(4).global_position)
		
		var screen_pos = camera.unproject_position(pos)

		var offset = Vector2(-72,-90)
		throw_button.position = screen_pos + offset
		throw_button.show()
		throw_button_visible = true

	player.lineup_darts()

func _on_button_pressed() -> void:
	pass

func _process(delta: float) -> void:
	if(game_state==GameState.DART_CHARGE):
		power_label.show()
		var text = str("Throw power: ",round(player.current_throw_force))
		power_label.set_text(text)
	else:
		power_label.hide()
func _on_throw_button_pressed() -> void:
	if(throw_button_visible):
		throw_button.hide()
		throw_button_visible=false
		player.selected_index = selected_dart_index
		selected_dart_index = -1
		player.hovered_index=-1
		game_state = GameState.DART_THROW
		
		player.lineup_darts()
		


func _on_throw_cancel_button_pressed() -> void:
	player.selected_index = -1
	throw_button.hide()
	throw_button_visible=false
	player.hovered_index=-1
	game_state = GameState.DART_SELECT
	
	player.lineup_darts()
