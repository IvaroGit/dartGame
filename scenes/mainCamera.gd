extends Camera3D
@onready var raycast: RayCast3D = $RayCast3D
signal click

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if raycast.is_colliding():
		if raycast.get_collider() == $Computer/ScreenQuad:
			if Input.is_action_just_pressed("click"):
				click_screen()
func click_screen():
	var collision = raycast.get_collision_point()
	var local = $Computer/ScreenQuad.to_local(collision)

	var quad_size = Vector2(2, 2) # adjust to your QuadMesh size

	var uv = Vector2(
		(local.x / quad_size.x) + 0.5,
		(-local.y / quad_size.y) + 0.5)

	var vp_size = $Computer/SubViewport.size

	var pos = Vector2(
		uv.x * vp_size.x,
		uv.y * vp_size.y)

	var event = InputEventMouseButton.new()
	event.position = pos
	event.pressed = true
	event.button_index = MOUSE_BUTTON_LEFT
	emit_signal("click",event)
