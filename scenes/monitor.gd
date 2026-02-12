extends Node3D
@onready var screen_quad: MeshInstance3D = $Sketchfab_Scene/ScreenQuad
@onready var sub_viewport: SubViewport = $SubViewport

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_monitor_ui_button_pressed() -> void:
	print("pressed")
