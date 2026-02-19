extends Node3D

@export var DartScene: PackedScene
@onready var viewport: SubViewport = $"../room/monitor/Sprite3D/SubViewport"
@onready var main_node: main = get_tree().get_root().get_child(0) as main
@onready var dart_rig := $DartRig
@onready var bag: Node3D = $"../dartBag/Sketchfab_Scene"
@onready var main_camera: Camera3D = $cameraPivot/MainCamera
@export var dart_material: StandardMaterial3D

@onready var crosshair: Sprite3D = $crosshair
@onready var gravity_vec: Vector3 = \
	ProjectSettings.get_setting("physics/3d/default_gravity_vector") * \
	ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var aim_plane: Node3D = $aimPlane
@export var rainbow_speed := 0.5 # cycles per second

var darts := []

var selected_index := 0
var hovered_index :=-1
var selected_rotation := 90
var DART_X_SPACING := 0.2
const DART_X_SPACING_BASE := -0.1
const DART_ROTAION_Z_SPACING_BASE := 90
var DART_ROTAION_Z_SPACING := 0
const total_angle = 110
const DART_Z_SPACING := 0.01
const ACTIVE_Z_OFFSET := -0.05
const ACTIVE_OFFSET := -0.2

var current_throw_force: float =0
var THROW_FORCE := 12.0
var throw_scale := 20
const baseX :=0
const baseY :=-0.3
const baseZ :=-0.2
var baseVector = Vector3(baseX,baseY,baseZ)
const gravity = 1
var mouse
var rainbow_hue := 0.0
var preview_dir: Vector3 = Vector3.ZERO

signal mouse_aimed

func get_mouse_point_on_plane(camera: Camera3D, plane_transform: Transform3D) -> Vector3:
	var mouse = get_viewport().get_mouse_position()

	var ray_origin = camera.project_ray_origin(mouse)
	var ray_dir = camera.project_ray_normal(mouse)

	var plane_origin = plane_transform.origin
	var plane_normal = -plane_transform.basis.z  # forward

	var denom = plane_normal.dot(ray_dir)
	if abs(denom) < 0.0001:
		return plane_origin  # ray parallel, fallback

	var t = plane_normal.dot(plane_origin - ray_origin) / denom
	return ray_origin + ray_dir * t
func aim_dart_at_mouse(dart: Node3D, camera: Camera3D, aim_plane: Node3D):
	var target = get_mouse_point_on_plane(camera, aim_plane.global_transform)
	var dir = (target - dart.global_transform.origin).normalized()

	# Stable frame on the board
	var right = Vector3.UP.cross(dir).normalized()
	var up = dir.cross(right).normalized()

	# Convert authored -Y forward → engine -Z forward
	var basis = Basis(right, up, -dir)

	# Rotate from -Z to -Y once
	basis = basis * Basis(Vector3.RIGHT, deg_to_rad(90))

	dart.global_transform.basis = basis
	crosshair.position = Vector3(target.x,target.y,target.z)
	crosshair.show()
	
func lineup_darts():
	var center := (darts.size() - 1) * 0.5
	for i in range(darts.size()):
		var dart = darts[i]
		var outline = dart.get_node_or_null("outline")
		if outline:
			outline.visible = (i == hovered_index) or (i == selected_index)

		var offset := i - center
		DART_ROTAION_Z_SPACING = DART_ROTAION_Z_SPACING_BASE / max(1, darts.size() - 1)
		dart.rotation_degrees.z = offset * DART_ROTAION_Z_SPACING
		dart.position = Vector3(baseX, baseY, baseZ)
		dart.position.x += sin(dart.rotation.z) * DART_X_SPACING_BASE
		dart.position.y += -cos(dart.rotation.z) * DART_X_SPACING_BASE
		dart.rotation_degrees.x = 0

		if i == selected_index:
			dart.position.x += sin(dart.rotation.z) * ACTIVE_OFFSET
			dart.position.y += -cos(dart.rotation.z)* ACTIVE_OFFSET
			dart.position.z += ACTIVE_Z_OFFSET
			aim_dart_at_mouse(dart, main_camera, aim_plane)
		
func add_dart():
	if DartScene == null:
		return
	var dart = DartScene.instantiate()
	dart.freeze = true
	dart.gravity_scale = 0.0
	dart_rig.add_child(dart)
	darts.append(dart)
	lineup_darts()


func charge_selected_dart(delta):
	if Input.is_action_pressed("mouseLeft"):
		current_throw_force+=throw_scale*delta
	if Input.is_action_just_released("mouseLeft"):
		THROW_FORCE=current_throw_force
		release_selected_dart()
		current_throw_force=0
		main_node.game_state=main_node.GameState.DART_SELECT
func release_selected_dart():
	crosshair.hide()
	if darts.is_empty():
		return

	var dart = darts[selected_index]
	dart.get_node_or_null("outline").visible=false
	dart.freeze = false
	dart.gravity_scale = gravity
	dart.global_transform = dart.global_transform
	dart.reparent(get_tree().current_scene)
	var forward: Vector3 = -dart.global_transform.basis.y
	dart.apply_impulse(forward * THROW_FORCE, Vector3.ZERO)
	main_node.game_state=main_node.GameState.DART_SELECT
	darts.erase(dart)  # remove by reference
	selected_index=-1
	hovered_index=-1
	lineup_darts()
	
func select_next():
	if(darts.size()>0):
		selected_index = (selected_index + 1) % darts.size()
		lineup_darts()

func select_previous():
	if(darts.size()>0):
		selected_index = (selected_index - 1 + darts.size()) % darts.size()
		lineup_darts()

func _input(event):
	if event.is_action_pressed("x"):
		add_dart()
	
	elif event.is_action_pressed("mouseLeft")and main_node.game_state==main_node.GameState.DART_THROW:
		main_node.game_state=main_node.GameState.DART_CHARGE
		current_throw_force = 0
		if selected_index != -1:
			pass#spawn_preview_balls(darts[selected_index])
	if event is InputEventMouseMotion:
		mouse = event.position
		
		lineup_darts()
		

func _ready() -> void:
	selected_index=-1
	lineup_darts()
	
func _process(delta: float) -> void:
	dart_material.emission_enabled = true
	dart_material.emission = Color.from_hsv(rainbow_hue, 1.0, 1.0)
	dart_material.emission_energy = 1.5
	rainbow_hue = fmod(rainbow_hue + rainbow_speed * delta, 1.0)
	dart_material.albedo_color = Color.from_hsv(rainbow_hue, 1.0, 1.0)
	mouse = get_viewport().get_mouse_position()
	lineup_darts()
	if main_node.game_state==main_node.GameState.DART_CHARGE:
		charge_selected_dart(delta)
		
	
