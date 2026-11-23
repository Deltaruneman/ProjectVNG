extends RefCounted
## Item definitions and tuning live here; no world-drop or crafting integration.
const ROOT := "res://assets/sprites/item/"
const RAVEN := ROOT + "RavenmoreIconPack2023/RavenmoreIconPack2023/128/"
const SHEET := ROOT + "weapons/fantasy_weapons_pack1_noglow.png"
const GLOW_SHEET := ROOT + "weapons/fantasy_epicweapons_pack1_nobg.png"
const ENCHANTS := {
	"sharpness": {"name": "Sắc bén", "text": "+1 sát thương mỗi cấp", "max": 3},
	"critical": {"name": "Chí mạng", "text": "+10% tỉ lệ chí mạng mỗi cấp", "max": 3},
	"vampirism": {"name": "Hút máu", "text": "20% mỗi cấp hồi 1 HP khi trúng địch", "max": 3},
	"haste": {"name": "Nhanh nhẹn", "text": "Giảm 1 giây hồi chiêu skill mỗi cấp", "max": 3},
	"reach": {"name": "Vươn xa", "text": "+10% tầm đánh/bắn mỗi cấp", "max": 3},
	"impact": {"name": "Chấn động", "text": "Đòn vũ khí làm khựng 0.1 giây mỗi cấp", "max": 3},
	"resonance": {"name": "Cường hóa cộng hưởng", "text": "+1 sát thương skill cùng hệ mỗi cấp", "max": 3, "elemental": true},
	"affliction": {"name": "Dư âm nguyên tố", "text": "+1 giây hiệu ứng nguyên tố mỗi cấp", "max": 3, "elemental": true},
}
const SLOTS := {"main": "Vũ khí", "consumable": "Tiêu hao · Q", "armor": "Giáp", "charm": "Bùa"}
const WEAPON_ELEMENTS := {"sword": "lightning", "axe": "ice", "spear": "fire", "dagger": "wind"}
const ELEMENTS := {"wind": "Phong", "fire": "Hỏa", "ice": "Băng", "lightning": "Lôi"}

static var _definitions: Dictionary = {}

static func definitions() -> Dictionary:
	if not _definitions.is_empty():
		return _definitions
	var items := {
		"starter_blade": {"name": "Blade cũ", "slot": "main", "legacy": true, "unlimited_enchants": true, "texture_path": "res://assets/models/objects/item4.png", "description": "Blade khởi đầu với hình gốc. Không có hệ riêng. Không giới hạn số dòng hay cấp enchant; vẫn tiêu SP theo cấp."},
		"bow": {"name": "Cung săn", "slot": "offhand", "icon": "BowT1", "projectile_icon": "SpearT1", "description": "Bắn một mũi tên theo tâm ngắm. Không có hệ riêng; nâng cấp skill 1 truyền nguyên tố đang dùng."},
		"throwing_knife": {"name": "Dao ném", "slot": "offhand", "icon": "DaggerT1", "projectile_icon": "DaggerT1", "description": "Ném dao theo tâm ngắm. Không có hệ riêng; nâng cấp skill 1 truyền nguyên tố đang dùng."},
		"armor": {"name": "Giáp hộ vệ", "slot": "armor", "icon": "ArmorT1", "description": "Ô giáp thử nghiệm. Chỉ số chờ thiết kế."},
		"charm": {"name": "Bùa ma pháp", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/arcane_rune.png", "description": "+1 sát thương kỹ năng nguyên tố.", "skill_damage_bonus": 1},
		"amber_rune": {"name": "Bùa hỏa ngục", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/amber_rune.png", "description": "+1 sát thương thiêu đốt mỗi giây.", "burn_damage_bonus": 1},
		"binding_rune": {"name": "Bùa trói buộc", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/binding_rune.png", "description": "+1 giây làm chậm, đóng băng và choáng.", "control_duration_bonus": 1.0},
		"blood_rune": {"name": "Bùa xích huyết", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/blood_rune.png", "description": "Mỗi đòn có 10% cơ hội hồi 1 HP.", "heal_on_hit_chance": 0.1},
		"brimstone_rune": {"name": "Bùa Brimstone", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/brimstone_rune.png", "description": "Khi chết, hồi sinh với 2 HP. Bùa bị phá hủy sau khi dùng.", "respawn_health": 2, "consume_on_death": true},
		"sky_rune": {"name": "Bùa trời cao", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/sky_rune.png", "description": "+0,5 m/s tốc độ di chuyển.", "movement_speed_bonus": 0.5},
		"time_rune": {"name": "Bùa thời gian", "slot": "charm", "texture_path": "res://assets/vendor/32x32_rpg_animated_free_pack_v2/static/runes/time_rune.png", "description": "Giảm 1 giây hồi chiêu skill.", "cooldown_reduction": 1.0},
		"healing_potion": {"name": "Bình hồi phục", "slot": "consumable", "icon": "PotionRed", "description": "Hồi đầy HP. Vật phẩm test, chưa nối crafting/drop."},
	}
	# Prototype catalog only: no drop rates or final balance implied.
	var archetypes := {
		"sword": {"name": "Kiếm", "cell": Vector2i(0, 3), "bonus": 0, "tempo": 1.0, "reach": 1.0, "width": 1.0, "crit": 0.15, "effect": "Cân bằng; 15% chí mạng."},
		"axe": {"name": "Rìu", "cell": Vector2i(1, 1), "bonus": 2, "tempo": 0.7, "reach": 1.2, "width": 1.5, "crit": 0.0, "effect": "+2 sát thương; vung chậm, vùng đánh rộng, đẩy lùi mạnh."},
		"spear": {"name": "Thương", "cell": Vector2i(5, 0), "bonus": 1, "tempo": 0.9, "reach": 1.9, "width": 0.7, "crit": 0.0, "effect": "+1 sát thương; đâm xa, vùng đánh hẹp."},
		"dagger": {"name": "Dao găm", "cell": Vector2i(3, 2), "bonus": 0, "tempo": 1.6, "reach": 0.8, "width": 0.8, "crit": 0.25, "effect": "Đánh nhanh; 25% chí mạng, tầm ngắn."},
	}
	for kind: String in archetypes:
		var data: Dictionary = archetypes[kind].duplicate()
		var element := str(WEAPON_ELEMENTS[kind])
		data.slot = "main"
		data.kind = kind
		data.resonance = element
		data.name += " · " + str(ELEMENTS[element])
		data.description = str(data.effect) + " Cộng hưởng cố định: " + str(ELEMENTS[element]) + ". +25% sát thương skill cùng nguyên tố. Chỉ số mẫu để test."
		items[kind] = data
	items.armor.description = "Giáp thử nghiệm: +2 HP tối đa."
	items.armor.health = 2
	_definitions = items
	return _definitions

static func canonical_id(id: String) -> String:
	if definitions().has(id):
		return id
	# Exact former prototype IDs only; do not accept arbitrary suffixes.
	for kind: String in ["sword", "axe", "spear", "dagger", "bow", "throwing_knife"]:
		for element: String in ELEMENTS:
			if id == kind + "_" + element:
				return kind
	return ""

static func item(id: String) -> Dictionary:
	return definitions().get(canonical_id(id), {})

static func texture(id: String, glow: bool = false) -> Texture2D:
	var data := item(id)
	if data.is_empty():
		return null
	if data.has("texture_path"):
		return load(str(data.texture_path)) as Texture2D
	if data.has("cell"):
		var atlas := AtlasTexture.new()
		atlas.atlas = load(GLOW_SHEET if glow or str(data.get("resonance", "")) != "" else SHEET)
		atlas.region = Rect2(Vector2(data.cell) * 32.0, Vector2(32, 32))
		return atlas
	return load(RAVEN + str(data.icon) + ".png") as Texture2D
