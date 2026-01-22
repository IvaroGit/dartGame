extends Control


@onready var button_container: Control = $button_container
@onready var crosshair: Control = $Crosshair
@onready var crosshair_pin_2: Sprite2D = $Crosshair/CrosshairPin2
@onready var crosshair_pin_3: Sprite2D = $Crosshair/CrosshairPin3
@onready var crosshair_pin_4: Sprite2D = $Crosshair/CrosshairPin4
@onready var crosshair_pin: Sprite2D = $Crosshair/CrosshairPin
@onready var power_label: Label = $powerLabel
@onready var crosshair_red: Sprite2D = $crosshairRed
var anchorPos = Vector2()
func _ready():
	pass

func _on_button_pressed() -> void:
	pass

func _process(delta: float) -> void:
	pass
