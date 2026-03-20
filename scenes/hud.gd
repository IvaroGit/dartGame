extends Control

var already_revealed := false

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
	reset_ui()

func reveal_sequence():
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
