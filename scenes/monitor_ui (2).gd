extends Control
@onready var main_node: main = get_tree().get_root().get_child(0) as main
@onready var score_label: Label = $score
@onready var throws_label: Label = $throws
@onready var quota_label: Label = $quota
@onready var scoreboard: Node3D = $"../../../../../../dartArea/scoreboard"
var score=0
var target_score=0
var score_counting = false
var countspeed = 200
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scoreboard.send_score.connect(start_counting)
func start_counting(points):
	target_score=score+points
	score_counting=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if score_counting and score != target_score:
		score+=int(countspeed*delta)
	if score >= target_score:
		score = target_score
	
	score_label.set_text(str(score))
	throws_label.set_text(str(main_node.throws_left))
	quota_label.set_text(str(main_node.quota))
