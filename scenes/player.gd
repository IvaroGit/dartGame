extends Node3D

@export var DartScene: PackedScene
#@onready var dart_rig := $DartRig
@onready var dart_rig := $DartRig
@onready var bag: Node3D = $"../dartBag/Sketchfab_Scene"

var darts := []
var selected_index := 0
var selected_rotaion := 80
var DART_X_SPACING := 0
const DART_X_SPACING_BASE := 0
const DART_ROTAION_Z_SPACING_BASE := 90
var DART_ROTAION_Z_SPACING := 0
const total_angle = 110
const DART_Z_SPACING := 0.01
const ACTIVE_Z_OFFSET := 0.05
const ACTIVE_OFFSET := -0.1

const THROW_FORCE := 12.0
const baseX :=0
const baseY :=-0.1
const baseZ :=-0.3
const gravity = 1

func lineup_darts():
	var center := (darts.size() - 1) * 0.5
	
	for i in range(darts.size()):
		var dart = darts[i]
		var offset := i - center

		DART_ROTAION_Z_SPACING = DART_ROTAION_Z_SPACING_BASE / max(1, darts.size() - 1)
		dart.rotation_degrees.z = offset * DART_ROTAION_Z_SPACING
		

		dart.position = Vector3(baseX, baseY, baseZ)
		if i == selected_index:
			dart.position.x += sin(dart.rotation.z) * ACTIVE_OFFSET
			dart.position.y += -cos(dart.rotation.z)* ACTIVE_OFFSET
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
	pass
