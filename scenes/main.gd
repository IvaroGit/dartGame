extends Node3D
class_name main
enum Runstate {THROWING,SCORING,POST_QUOTA,SHOP,ENTER_SHOP,EXIT_SHOP}
enum GameState { DART_SELECT,DART_THROW,DART_CHARGE}
@export var game_state := GameState.DART_THROW
var run_state := Runstate.THROWING
@export var cameras: Array[Camera3D]=[]

@onready var power_label: Label = $UI/HUD/powerLabel
var charm_queue: Array = []
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
@onready var dart_zones: Node3D = $world/dartArea/board/board/CollisionShape3D/DartZones
@onready var hud: Control = $UI/HUD
@onready var player: Node3D = $world/Player
@onready var dart: Node3D = $world/Player/DartRig
@onready var throw_button: Control = $UI/HUD/button_container/Control
@onready var zone_label: Label = $UI/HUD/zoneLabel
@export var bag_distance := 0.25
@export var bag_height_offset := 0
@onready var board1: Node3D = $world/dartArea/board
@onready var scoreboard: Node3D = $world/dartArea/scoreboard
var active_charms: Array = []

var coins = 0
var quota = 0
var run_score := 0
var throw_score := 0
var final_score :=0
var darts_left = 0
func _ready() -> void:
	update_camera()
	dart_zones.zone_hit.connect(update_zone_label)
	dart_zones.zone_scored.connect(handle_scoring)
	board1.board_scored.connect(handle_scoring)
	
	active_charms.append(GreenApple.new())
	active_charms.append(Frog.new())
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
	
func handle_scoring(payload: Dictionary) -> void:
	final_score = 0  

	_apply_charms(payload)
	_execute_effects(payload)

	run_score += final_score

	print("=== PAYLOAD DEBUG ===")
	print("META:")
	for key in payload.meta.keys():
		print(" ", key, ": ", payload.meta[key])
	print("EFFECTS:")
	for effect in payload.effects:
		print(" ", _debug_effect(effect))

	print("Final dart score: ", final_score)
	print("Run score: ", run_score)

	scoreboard.update_scoring_label(final_score)
func _execute_effects(payload):
	for effect in payload.effects:
		match effect.type:
			Effects.EffectType.ADD_POINTS:
				final_score += effect.amount
			Effects.EffectType.ADD_COINS:
				coins += effect.amount
			Effects.EffectType.MULTIPLY_POINTS:
				final_score *= effect.amount
			Effects.EffectType.ADD_DART:
				pass
func _debug_effect(effect: Dictionary) -> String:
	var source = effect.get("source", "Board")
	var amount = effect.get("amount", 0)

	match effect.type:
		Effects.EffectType.ADD_POINTS:
			return "%s: +%d points" % [source, amount]

		Effects.EffectType.ADD_COINS:
			return "%s: +%d coins" % [source, amount]

		Effects.EffectType.ADD_DART:
			return "%s: +%d darts" % [source, amount]
		Effects.EffectType.MULTIPLY_POINTS:
			return "%s: *%d points" % [source, amount]
		
		_:
			return "%s: unknown effect" % source
func _apply_charms(payload: Dictionary) -> void:
	build_charm_queue(payload)  # rebuild & sort queue for this dart

	for charm in charm_queue:
#		print("Activating charm: %s, priority: %d" % [charm.name, charm.priority])
		charm.modify_payload(payload)  # executes the charm in sorted order
# Compare function for sorting charms by priority
func _compare_charms(a, b) -> int:
	if a.priority < b.priority:
		return -1
	elif a.priority > b.priority:
		return 1
	else:
		return 0

# Build the queue of charms to activate for this dart/payload
func build_charm_queue(payload: Dictionary) -> void:
	charm_queue.clear()
	for charm in active_charms:
		charm_queue.append(charm)
	charm_queue.sort_custom(Callable(self, "_sort_charm_by_priority"))

func _sort_charm_by_priority(charm) -> int:
	return charm.priority
