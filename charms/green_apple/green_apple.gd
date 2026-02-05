extends Charm
class_name GreenApple

var green_zones = [
	"zone_tripple_1","zone_tripple_4","zone_tripple_6","zone_tripple_15",
	"zone_tripple_17","zone_tripple_19","zone_tripple_16","zone_tripple_11",
	"zone_tripple_9","zone_tripple_5",
	"zone_dubble_1","zone_dubble_4","zone_dubble_6","zone_dubble_15",
	"zone_dubble_17","zone_dubble_19","zone_dubble_16","zone_dubble_11",
	"zone_dubble_9","zone_dubble_5",
	"zone_outer_bull"
]

var bonus_score = 15

func modify_payload(payload: Dictionary) -> void:
	# Check if payload.meta has zone_id
	if not payload.meta.has("zone_id"):
		return

	var zone_id = payload.meta.zone_id

	if zone_id in green_zones:
		# Add effect to the payload
		payload.effects.append({
			"type": Effects.EffectType.ADD_POINTS,
			"amount": bonus_score
		})
