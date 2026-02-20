extends Node3D
@onready var label_3d: Label3D = $Label3D
var score=0
@onready var dart_zones: Node3D = $"../board/board/CollisionShape3D/DartZones"
signal send_score(score,points)
var scoreboard_delay = 1
var countdown_speed = 200
var counting_down= false
func _ready() -> void:
	pass
func update_scoring_label(points):
	score+=points
	var text = str(score)
	label_3d.set_text(text)

func finnished_scoring():
	await get_tree().create_timer(scoreboard_delay).timeout
	send_score.emit(score)
	counting_down=true
func _process(delta: float) -> void:
	if(counting_down):
		score-=int(countdown_speed*delta)
		var text = str(score)
		label_3d.set_text(text)
	if score<=0:
		score=0
		var text = str(score)
		label_3d.set_text(text)
		counting_down=false
