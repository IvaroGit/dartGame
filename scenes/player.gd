extends Node3D

@export var DartScene: PackedScene
#@onready var dart_rig := $DartRig
@onready var dart_rig := $DartRig
@onready var bag: Node3D = $"../dartBag/Sketchfab_Scene"
@export var dart_material: StandardMaterial3D
var darts := []
var selected_index := 0
var hovered_index :=0
var selected_rotation := 80
var DART_X_SPACING := 0.2
const DART_X_SPACING_BASE := -0.1
const DART_ROTAION_Z_SPACING_BASE := 90
var DART_ROTAION_Z_SPACING := 0
const total_angle = 110
const DART_Z_SPACING := 0.01
const ACTIVE_Z_OFFSET := -0.05
const ACTIVE_OFFSET := -0.1

const THROW_FORCE := 12.0
const baseX :=0
const baseY :=-0.3
const baseZ :=-0.2
const gravity = 1

var rainbow_hue := 0.0
@export var rainbow_speed := 0.5 # cycles per second

func lineup_darts():
	var center := (darts.size() - 1) * 0.5
	
	for i in range(darts.size()):
		var dart = darts[i]
		var dart_hovered = darts[hovered_index]
		dart_hovered.get_node_or_null("outline").visible=true
		var offset := i - center
		dart.get_node_or_null("outline").visible=false
		DART_ROTAION_Z_SPACING = DART_ROTAION_Z_SPACING_BASE / max(1, darts.size() - 1)
		dart.rotation_degrees.z = offset * DART_ROTAION_Z_SPACING
		dart.position = Vector3(baseX, baseY, baseZ)
		dart.position.x += sin(dart.rotation.z) * DART_X_SPACING_BASE
		dart.position.y += -cos(dart.rotation.z)* DART_X_SPACING_BASE
		dart.rotation_degrees.x = 0
		if i == selected_index:
			dart.get_node_or_null("outline").visible=true
			dart.position.x += sin(dart.rotation.z) * ACTIVE_OFFSET
			dart.position.y += -cos(dart.rotation.z)* ACTIVE_OFFSET
			dart.position.z += ACTIVE_Z_OFFSET
			dart.rotation_degrees.x += selected_rotation
func add_dart():
	if DartScene == null:
		return
	var dart = DartScene.instantiate()
	dart.freeze = true
	dart.gravity_scale = 0.0
	dart_rig.add_child(dart)
	darts.append(dart)
	lineup_darts()

func throw_selected_dart():
	if darts.is_empty():
		return
	var dart = darts[selected_index]
	dart.get_node_or_null("outline").visible=false
	dart.freeze = false
	dart.gravity_scale = gravity
	dart.global_transform = dart.global_transform
	dart.reparent(get_tree().current_scene)
	var forward: Vector3 = -$cameraPivot/MainCamera.global_transform.basis.z
	dart.apply_impulse(forward * THROW_FORCE, Vector3.ZERO)
	darts.erase(dart)  # remove by reference
	selected_index = clamp(selected_index, 0, darts.size() - 1)
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
	if event.is_action_pressed("key_left"):
		select_previous()
	elif event.is_action_pressed("key_right"):
		select_next()
	elif event.is_action_pressed("accept"):
		throw_selected_dart()

func _ready() -> void:
	lineup_darts()
func _process(delta: float) -> void:
	dart_material.emission_enabled = true
	dart_material.emission = Color.from_hsv(rainbow_hue, 1.0, 1.0)
	dart_material.emission_energy = 1.5
	rainbow_hue = fmod(rainbow_hue + rainbow_speed * delta, 1.0)
	dart_material.albedo_color = Color.from_hsv(rainbow_hue, 1.0, 1.0)
