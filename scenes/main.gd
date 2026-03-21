extends Node3D
class_name main
enum Runstate {THROWING,SCORING,POST_QUOTA,SHOP,ENTER_SHOP,EXIT_SHOP}
enum GameState { DART_SELECT,DART_THROW,DART_CHARGE}
@export var game_state := GameState.DART_THROW
var run_state := Runstate.THROWING
@export var cameras: Array[Camera3D]=[]
@onready var power_label: Label = $UI/HUD/powerLabel
var charm_queue: Array[CharmBase] = []
@export var available_charm_scenes: Array[PackedScene] = []
var active_charms: Array[CharmBase] = []
var charm_spacing  = 0.3
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

@onready var dart_zones: Node3D = $world/dartArea/board/board/CollisionShape3D/DartZones
@onready var hud: Control = $UI/HUD
@onready var charm_button: Button = $UI/HUD/Button2
@onready var player: Node3D = $world/Player
@onready var dart: Node3D = $world/Player/DartRig
@onready var throw_button: Control = $UI/HUD/button_container/Control
@onready var zone_label: Label = $UI/HUD/zoneLabel
@export var bag_distance := 0.25
@export var bag_height_offset := 0
@onready var board1: Node3D = $world/dartArea/board
@onready var scoreboard: Node3D = $world/dartArea/scoreboard
@onready var monitor: Node3D = $world/room/monitor
@onready var boss_monitor: Node3D = $world/dartArea/monitor/boss_monitor
@onready var dart_area: Node3D = $world/dartArea
@onready var board_light: SpotLight3D = $world/dartArea/board/board/SpotLight3D
@onready var lectern_light: SpotLight3D = $world/dartArea/lectern/SpotLight3D
@onready var monitor_sprite: Sprite3D = $world/dartArea/monitor/Sketchfab_Scene/Sprite3D
@onready var shop: Node3D = $shop
@onready var reroll_button: Node3D = $shop/reroll_button
@onready var reroll_anim: AnimationPlayer = $shop/reroll_button/AnimationPlayer
@onready var reroll_label: Label = $UI/HUD/button_container/Control2/Label
@onready var charm_label: Label = $UI/HUD/button_container/Control2/charm_label
@onready var runstate_label: Label = $UI/HUD/runstate_label
@onready var exit_shop_button: Button = $UI/HUD/exit_shop
@onready var monitor_ui: Control = $world/dartArea/monitor/Sketchfab_Scene/Sprite3D/SubViewport/Control
@onready var glitch_transition: Control = $UI/glitch_transition
@onready var post_quota: Control = $UI/post_quota

#round managing
var round=0
var set=0
var coins=0
var quota = 1

var base_dart_amount = 5
var throws_left = base_dart_amount

signal show_post_quota_text

var charmDelay = 0.5

var currentScore
class ThrowContext:
	var zone_id: String
	var base_score: int
	var score: float
	var coins: int = 0
	var board

	func _init(_zone_id, _base_score, _board):
		zone_id = _zone_id
		base_score = _base_score
		score = _base_score
		board = _board


func _ready() -> void:
	start_set()
	update_camera()
	dart_zones.zone_hit.connect(update_zone_label)
	dart_zones.zone_scored.connect(_on_zone_scored)
	charm_button.charm_button.connect(add_random_charm)
	monitor_ui.round_won.connect(on_round_won)
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
		player.hovered_index = -1
		return

	var hit_node: Node = result.collider


	var check_node := hit_node
	var charm_found := false

	while check_node:
		if check_node == reroll_button:
			var pos = Vector3(hit_node.get_child(0).global_position)
			var screen_pos = camera.unproject_position(pos)
			var offset = Vector2(-30,-80)
			reroll_label.position = screen_pos+offset
			reroll_label.show()
			if Input.is_action_just_pressed("mouseLeft"):
				if not reroll_anim.is_playing():
					reroll_anim.play("Animation")
					reroll_anim.seek(0.8, true)
					await get_tree().create_timer(0.25).timeout
					shop.roll_shop()
			return

		if check_node is CharmBase:
			charm_found = true
			charm_label.text = check_node.charm_name
			var pos = Vector3(hit_node.get_child(0).global_position)
			var screen_pos = camera.unproject_position(pos)
			var offset = Vector2(-30,-80)
			charm_label.position = screen_pos+offset
			charm_label.show()

		check_node = check_node.get_parent()

	if not charm_found:
		charm_label.hide()
		reroll_label.hide()		
	if hit_node == null:
		player.hovered_index = -1
		return

	player.hovered_index = player.darts.find(hit_node)

	if Input.is_action_just_released("mouseLeft") and player.darts.has(hit_node):
		selected_dart_index = player.darts.find(hit_node)

		var pos = Vector3(hit_node.get_child(4).global_position)
		var screen_pos = camera.unproject_position(pos)

		var offset = Vector2(-72,-90)
		throw_button.position = screen_pos + offset
		throw_button.show()
		throw_button_visible = true
	player.lineup_darts()
func _on_button_pressed() -> void:
	start_boss()

func _process(delta: float) -> void:
	if(game_state==GameState.DART_CHARGE):
		power_label.show()
		var text = str("Throw power: ",round(player.current_throw_force))
		power_label.set_text(text)
	else:
		power_label.hide()
	runstate_label.text = str(run_state)
	if run_state==Runstate.SHOP:
		exit_shop_button.show()
	else:
		exit_shop_button.hide()
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

func _on_zone_scored(points: int, zone_name: String, times_hit: int) -> void:
	scoreboard.update_scoring_label(int(points))

	var ctx = ThrowContext.new(zone_name, points, board1)


	board1.call("process_score", int(points), zone_name,times_hit)

	for charm in active_charms:
		await get_tree().create_timer(charmDelay).timeout
		charm.apply(ctx)
		if charm.triggered:
			scoreboard.update_scoring_label(int(charm.bonus_score))
	scoreboard.finnished_scoring()

	print("Hit zone: ", zone_name, " Base: ", points, " Final score: ", ctx.score)
	
func add_charm(scene: PackedScene):
	var charm := scene.instantiate() as CharmBase
	if charm == null:
		push_error("Instantiated charm is not CharmBase")
		return

	active_charms.append(charm)
	add_child(charm) 
	for i in active_charms.size():
		charm.global_position = Vector3(0.6+i*charm_spacing,0,-1)
	print("Charm added:", charm.charm_name)

func add_random_charm():
	if available_charm_scenes.is_empty():
		print("No charms available")
		return
	var candidates: Array[PackedScene] = []
	for scene in available_charm_scenes:
		var already_active := false
		for charm in active_charms:
			if charm.scene_file_path == scene.resource_path:
				already_active = true
				break
		if not already_active:
			candidates.append(scene)
	if candidates.is_empty():
		print("All charms already active")
		return
	var chosen_scene = candidates.pick_random()
	add_charm(chosen_scene)
func start_boss():
	print("start boss")
	var tween = create_tween()
	tween = create_tween()
	tween.tween_property(boss_monitor, "position", Vector3(-0.3, 0.7, 0), 1)
	tween.tween_property(boss_monitor, "rotation_degrees", Vector3(7, 0, 4), 0.5)

func enter_shop():
	move_dart_area(-5,1,1)
	move_shop(0,1,0)
	run_state=Runstate.SHOP

func enter_shop_instant():
	move_dart_area(30,0,0)
	move_shop(0,0,0)
	run_state=Runstate.SHOP
	var all_darts = get_tree().get_nodes_in_group("darts")
	for dart in all_darts:
		if is_instance_valid(dart):
			dart.queue_free()
func exit_shop_instant():
	glitch_transition.show()
	await get_tree().create_timer(0.1).timeout
	move_dart_area(0,0,0)
	move_shop(30,0,0)
	run_state=Runstate.THROWING
	var all_darts = get_tree().get_nodes_in_group("darts")
	for dart in all_darts:
		if is_instance_valid(dart):
			dart.queue_free()
	await get_tree().create_timer(0.1).timeout
	glitch_transition.hide()
	if round<3:
		start_round()
	else:
		start_set()
func exit_shop():
	if run_state==Runstate.SHOP:
		move_shop(-5,1,1)
		move_dart_area(0,1,0)
		run_state=Runstate.THROWING
func move_shop(target,time,option):
	var tween = create_tween()
	# If a tween already exists, kill it first
	if tween:
		tween.kill()
	# Create a new tween
	tween = create_tween()
	# Move $Monitor to a new position in 1 second
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(shop, "global_position", Vector3(target,-0.366, -1.163), time)
	if option==1:
		tween.tween_property(shop, "global_position", Vector3(5,-0.366, -1.163), 0)
func move_dart_area(target,time,option):
	var tween = create_tween()
	# If a tween already exists, kill it first
	if tween:
		tween.kill()
	# Create a new tween
	tween = create_tween()
	# Move $Monitor to a new position in 1 second
	tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(dart_area, "global_position", Vector3(target,0,0), time)
	if option==1:
		tween.tween_property(dart_area, "global_position", Vector3(5,0,0), 0)

func _on_next_pressed() -> void:
	if(run_state==Runstate.THROWING):
		enter_shop()
	elif(run_state==Runstate.SHOP):
		exit_shop()

func on_round_won():
	glitch_transition.show()
	await get_tree().create_timer(0.1).timeout
	hud.hide()
	post_quota.show()
	emit_signal("show_post_quota_text")
	await get_tree().create_timer(0.1).timeout
	glitch_transition.hide()

func _on_exit_shop_pressed() -> void:
	exit_shop_instant()


func _on_enter_shop_pressed() -> void:
	glitch_transition.show()
	await get_tree().create_timer(0.1).timeout
	enter_shop_instant()
	hud.show()
	post_quota.hide()
	await get_tree().create_timer(0.1).timeout
	glitch_transition.hide()
	
func start_round():
	round+=1
	player.selected_index=-1
	for i in range(base_dart_amount+1):
		player.add_dart()
	if round==3:
		start_boss()
func start_set():
	set+=1
	round=0
	start_round()
