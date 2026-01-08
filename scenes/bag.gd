extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var bagLight = get_node("bagLight")
var opening=false
var closing=false
var fullyOpened=false
var fullyClosed=false
# Called when the node enters the scene tree for the first time.

func _ready() -> void:
	 # Replace with function body.
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var bagFrame = $AnimationPlayer.get_current_animation_position()
	
	if(bagFrame<=0):
		fullyClosed=true
	else:
		fullyClosed=false
	if(bagFrame>=8.33333301544):
		fullyOpened=true
	else:
		fullyOpened=false
		
	if Input.is_action_just_pressed("d"):
		if(fullyClosed):
			animation_player.play("open")
		if(fullyOpened):
			animation_player.play_backwards("open")
	if(bagFrame<=3.8):
		bagLight.light_energy=0
	else:
		bagLight.light_energy=0.4
