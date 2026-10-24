extends Node

signal points_changed(points: int)
signal skill_unlocked(skill: SkillData)
signal element_changed(element: StringName)

const SKILLS_DIR := "res://data/skills/"

var skill_points := 0
var unlocked: Array[StringName] = []         # id các skill đã mở
var abilities: Dictionary = {}               # {&"double_jump": true}
var owned_elements: Array[StringName] = []   # &"fire", &"wind", &"ice"
var equipped_element: StringName = &""       # rỗng = chưa có nguyên tố, không có FX
var all_skills: Array[SkillData] = []

func _ready() -> void:
	_load_all_skills()

func _load_all_skills() -> void:
	for file in DirAccess.get_files_at(SKILLS_DIR):
		var f := file.trim_suffix(".remap")   # cần khi export game
		if f.ends_with(".tres"):
			var s := load(SKILLS_DIR + f) as SkillData
			if s:
				all_skills.append(s)

# ---- Điểm ----
func add_points(n: int) -> void:
	skill_points += n
	points_changed.emit(skill_points)

# ---- Skill ----
func has_skill(s: SkillData) -> bool:
	return s.id in unlocked

func can_unlock(s: SkillData) -> bool:
	if has_skill(s) or skill_points < s.cost:
		return false
	for req in s.requires:
		if not has_skill(req):
			return false
	return true

func unlock(s: SkillData) -> bool:
	if not can_unlock(s):
		return false
	skill_points -= s.cost
	unlocked.append(s.id)
	for g in s.grants:
		abilities[g] = true
		if String(g).begins_with("element_"):
			var el := StringName(String(g).trim_prefix("element_"))
			if el not in owned_elements:
				owned_elements.append(el)
			if equipped_element == &"":
				equip_element(el)
	points_changed.emit(skill_points)
	skill_unlocked.emit(s)
	return true

# ---- Truy vấn cho gameplay ----
func has_ability(key: StringName) -> bool:
	return abilities.get(key, false)

func get_stat(key: String, base := 0.0) -> float:
	var total := base
	for s in all_skills:
		if has_skill(s) and s.stat_bonus.has(key):
			total += s.stat_bonus[key]
	return total

func equip_element(el: StringName) -> void:
	if el in owned_elements:
		equipped_element = el
		element_changed.emit(el)
