extends Node3D

@export var yaw_speed := deg_to_rad(180.0)     # degrees per second
@export var pitch_speed := deg_to_rad(180.0)

@export var yaw_limit := deg_to_rad(35.0)
@export var pitch_limit := deg_to_rad(35.0)

@onready var camera: Camera3D = $Camera3D
var speed = 1
var yaw := 0.0
var pitch := 0.0
var panLeft = false
var panRight = false
var panUp = false
var panDown = false

var manualSpeed = 0.01

var buffered_yaw := 0    # 1 = left, -1 = right
var buffered_pitch := 0 # -1 = up, +1 = down

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	if Input.is_action_pressed("t"):
		pitch+=manualSpeed
	if Input.is_action_pressed("g"):
		pitch-=manualSpeed
	if Input.is_action_pressed("f"):
		yaw+=manualSpeed
	if Input.is_action_pressed("h"):
		yaw-=manualSpeed
	#if(Input.is_action_pressed("up")):
		#position.z-=speed*delta
	#if(Input.is_action_pressed("down")):
		#position.z+=speed*delta
	#if(position.z<=0.05):
		#position.z=0.05
	
	# Horizontal rotation (yaw)
	if Input.is_action_just_pressed("left") and yaw <= yaw_limit:
		if(panLeft):
			buffered_yaw=1
		panLeft = true
		panRight = false
	if Input.is_action_just_pressed("right") and yaw >= -yaw_limit:
		if(panRight):
			buffered_yaw=-1
		panRight = true
		panLeft = false

	if panLeft:
		var next_yaw = yaw + yaw_speed * delta
		# Stop if crossing zero
		if yaw < 0 and next_yaw > 0 and buffered_yaw!=1:
			next_yaw = 0
			panLeft = false
		elif yaw > 0:
			next_yaw = min(next_yaw, yaw_limit)
		yaw = next_yaw
		if yaw >= yaw_limit:
			yaw = yaw_limit
			buffered_yaw=0
			panLeft = false
		

	if panRight:
		var next_yaw = yaw - yaw_speed * delta
		# Stop if crossing zero
		if yaw > 0 and next_yaw < 0 and buffered_yaw!=-1:
			next_yaw = 0
			panRight = false
		elif yaw < 0:
			next_yaw = max(next_yaw, -yaw_limit)
		yaw = next_yaw
		if yaw <= -yaw_limit:
			yaw = -yaw_limit
			buffered_yaw=0
			panRight = false
		
	
	# Ensure we don’t exceed yaw limits
	yaw = clamp(yaw, -yaw_limit, yaw_limit)
	rotation.y = yaw
	
	if Input.is_action_just_pressed("down") and pitch <= pitch_limit:
		if(panUp):
			buffered_pitch=-1
		panUp = true
		panDown = false
	if Input.is_action_just_pressed("up") and pitch >= -pitch_limit:
		if(panDown):
			buffered_pitch=1
		panUp = false
		panDown = true

	if panUp:
		var next_pitch = pitch - pitch_speed * delta
		# Stop if crossing zero
		if pitch > 0 and next_pitch < 0 and buffered_pitch!=-1:
			next_pitch = 0
			panUp = false
		elif pitch > 0:
			next_pitch = min(next_pitch, pitch_limit)
		pitch = next_pitch
		if pitch <= -pitch_limit:
			pitch = -pitch_limit
			buffered_pitch=0
			panUp = false
		

	if panDown:
		var next_pitch = pitch + pitch_speed * delta
		# Stop if crossing zero
		if pitch < 0 and next_pitch > 0 and buffered_pitch!=1:
			next_pitch = 0
			panDown = false
		elif pitch < 0:
			next_pitch = max(next_pitch, -pitch_limit)
		pitch = next_pitch
		if pitch >= pitch_limit:
			pitch = pitch_limit
			buffered_pitch=0
			panDown = false
		

	# Ensure we don’t exceed yaw limits
	pitch = clamp(pitch, -pitch_limit, pitch_limit)
	rotation.x = pitch
