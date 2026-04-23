extends Control

var already_revealed := false
@onready var main_node: main = get_tree().get_root().get_child(0) as main
@onready var coins_label: Label = $Polygon2D/coins_label
@onready var remaining_throws: Label = $"../post_quota/remaining_throws_value"
@onready var money: Label = $"../post_quota/money"
@onready var final_score: Label = $"../post_quota/final_score_value"

@onready var rows := [
	{
		"label": $"../post_quota/final_score_label",
		"value": $"../post_quota/final_score_value"
	},
	{
		"label": $"../post_quota/remaining_throws_label",
		"value": $"../post_quota/remaining_throws_value"
	},
	{
		"label": $"../post_quota/reward_label",
		"value": $"../post_quota/money",
	}
]
func _ready():
	for row in rows:
		row["label"].visible_ratio = 0.0
		row["value"].visible_ratio = 0.0
		
func _on_run_manager_show_post_quota_text() -> void:
	if already_revealed:
		return
	
	already_revealed = true
	reveal_sequence()


func reveal_sequence():
	remaining_throws.set_text(str(main_node.throws_left))
	final_score.set_text(str(int(main_node.final_score)))
	money.text = "$".repeat(main_node.current_quota_prize)
	main_node.coins+=main_node.current_quota_prize
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)

	for row in rows:
		tween.tween_property(row["label"], "visible_ratio", 1.0, 0.1)
		tween.tween_interval(0.05)

	tween.tween_interval(0.3)

	for row in rows:
		tween.tween_property(row["value"], "visible_ratio", 1.0, 0.1)
		tween.tween_interval(0.2)
func reset_ui():
	for row in rows:
		row["label"].visible_ratio = 0.0
		row["value"].visible_ratio = 0.0
		

func _on_run_manager_reset_post_quota_ui() -> void:
	reset_ui()
	already_revealed=false

func _process(delta: float) -> void:
	coins_label.set_text(str(main_node.coins))
