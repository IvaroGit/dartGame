extends Charm
class_name Frog

var three_zones = [
	"zone_tripple_nr17",
	"zone_dubble_17",
	"zone_outer_slice_17",
	"zone_inner_slice_17"
]

var bonus_score = 30
var multiplier = 100
func modify_payload(payload: Dictionary) -> void:
	# Check if payload.meta has zone_id
	if not payload.meta.has("zone_id"):
		return

	var zone_id = payload.meta.zone_id
	if zone_id in three_zones:
		payload.effects.append({
			"type": Effects.EffectType.MULTIPLY_POINTS,
			"amount": multiplier,
			"source": "Frog charm"  # used in debug log
		})
