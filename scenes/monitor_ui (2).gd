extends Control
@onready var main_node: main = get_tree().get_root().get_child(0) as main
@onready var score_label: Label = $stat_screen/score
@onready var throws_label: Label = $stat_screen/throws
@onready var quota_label: Label = $stat_screen/quota
@onready var scoreboard: Node3D = $"../../../../../../dartArea/scoreboard"
@onready var stat_screen: Control = $stat_screen
@onready var win_screen: Control = $win_screen

var score=0
var target_score=0
var score_counting = false
var win_screen_timer = 0.5
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	scoreboard.send_score.connect(start_counting)
func start_counting(points):
	target_score=score+points
	score_counting=true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if score_counting and score != target_score:
		score+=target_score*0.1
	if score >= target_score:
		score = target_score
		score_counting=false
	score_label.set_text(str(int(score)))
	throws_label.set_text(str(main_node.throws_left))
	quota_label.set_text(str(main_node.quota))

	if score == target_score and score>=main_node.quota:
		await get_tree().create_timer(0.3).timeout
		show_win()
		await get_tree().create_timer(win_screen_timer).timeout
		main_node.quota = randi()%200+100
		score=0
		show_stat()
func show_stat():
	stat_screen.show()
	win_screen.hide()
func show_win():
	stat_screen.hide()
	win_screen.show()
