extends RefCounted

const EXP_PER_POINT := 20
const SKILL_POINTS_PER_LEVEL := 3
const FORMS := ["wind", "fire", "ice", "lightning"]
# id: [maximum rank, earned-SP gate, base cost]
const CHARACTER := {
	"char_attack": [3, 0, 1], "char_crit": [3, 1, 2], "char_element": [3, 2, 2],
	"char_health": [3, 0, 1], "char_heal": [3, 1, 2], "char_parry": [2, 2, 2],
	"char_dash": [3, 0, 1], "char_speed": [3, 1, 2], "char_double_jump": [1, 2, 3],
}
# id: [earned-SP gate, cost, prerequisite]
const EVOLUTIONS := {
	"evo_wind_return": [3, 2, "active_wind_1"],
	"evo_wind_gale": [7, 3, "active_wind_3"],
	"evo_wind_tornado": [10, 4, "active_wind_4"],
	"evo_fire_ember": [3, 2, "active_fire_1"],
	"evo_fire_inferno": [7, 3, "active_fire_2"],
	"evo_fire_meteor": [10, 4, "active_fire_4"],
	"evo_ice_frostbite": [3, 2, "active_ice_1"],
	"evo_ice_shatter": [6, 3, "active_ice_2"],
	"evo_ice_storm": [10, 4, "active_ice_4"],
	"evo_lightning_chain": [4, 2, "active_lightning_2"],
	"evo_lightning_storm": [8, 3, "active_lightning_3"],
}

static func exp_to_next_level(level: int) -> int:
	return 100 + maxi(0, level - 1) * 50

static func definition(node_id: String) -> Dictionary:
	if node_id.begins_with("offhand_") and node_id.trim_prefix("offhand_") in FORMS:
		var element := node_id.trim_prefix("offhand_")
		return {"max": 1, "gate": 1, "cost": 2, "requires": "active_%s_1" % element, "form": element}
	if CHARACTER.has(node_id):
		var data: Array = CHARACTER[node_id]
		return {"max": data[0], "gate": data[1], "cost": data[2], "scaling": true}
	if EVOLUTIONS.has(node_id):
		var data: Array = EVOLUTIONS[node_id]
		return {"max": 1, "gate": data[0], "cost": data[1], "requires": data[2], "form": node_id.get_slice("_", 1)}
	var parts := node_id.split("_")
	if parts.size() == 2 and parts[0] == "form" and parts[1] in FORMS:
		return {"max": 1, "gate": 0, "cost": 1, "choose_form": parts[1]}
	if parts.size() == 3 and parts[1] in FORMS:
		var slot := int(parts[2])
		if str(slot) != parts[2]:
			return {}
		if parts[0] == "active" and slot >= 1 and slot <= 4:
			return {"max": 1, "gate": [1, 4, 6, 9][slot - 1], "cost": slot, "form": parts[1]}
		if parts[0] == "ultimate" and slot >= 1 and slot <= 2:
			return {"max": 1, "gate": (10 if parts[1] == "wind" else 8) if slot == 2 else 5, "cost": slot + 3, "form": parts[1]}
	return {}
