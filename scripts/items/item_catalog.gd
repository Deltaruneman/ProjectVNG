extends RefCounted
## Items use the IDs/names below and the matching CC0 Hearthmark icon family.
const ITEMS := {
	"iron_sword": {"name": "Kiếm sắt", "kind": "equipment", "slot": "weapon", "icon": "weapons/sword", "description": "Thanh kiếm cân bằng, đáng tin cậy.", "effects": {"attack": 1}},
	"parry_dagger": {"name": "Dao hộ thủ", "kind": "equipment", "slot": "weapon", "icon": "weapons/dagger", "description": "Lưỡi dao nhẹ giúp bắt nhịp đỡ đòn.", "effects": {"parry": 0.03}},
	"battle_axe": {"name": "Rìu chiến", "kind": "equipment", "slot": "weapon", "icon": "weapons/battle_axe", "description": "Rìu nặng, tăng sát thương đòn đánh.", "effects": {"attack": 2}},
	"leather_tunic": {"name": "Áo da lữ hành", "kind": "equipment", "slot": "armor", "icon": "armour/leather_tunic", "description": "Áo da bền bỉ, tăng 2 máu tối đa.", "effects": {"health": 2}},
	"iron_chestplate": {"name": "Giáp ngực sắt", "kind": "equipment", "slot": "armor", "icon": "armour/chestplate", "description": "Giáp nặng, tăng 4 máu tối đa.", "effects": {"health": 4}},
	"traveler_boots": {"name": "Ủng lữ hành", "kind": "equipment", "slot": "talisman", "icon": "armour/boots", "description": "Đôi ủng nhẹ giúp bước chân nhanh hơn.", "effects": {"speed": 0.5}},
	"amethyst_charm": {"name": "Bùa thạch anh tím", "kind": "equipment", "slot": "talisman", "icon": "gems/amethyst", "description": "Viên đá tím gia cố nhịp đỡ đòn.", "effects": {"parry": 0.02}},
	"minor_health_potion": {"name": "Bình hồi phục nhỏ", "kind": "consumable", "icon": "potions/minor_health", "description": "Hồi 2 máu. Không tiêu hao khi máu đầy.", "effects": {"heal": 2}},
	"hearty_bread": {"name": "Bánh mì", "kind": "consumable", "icon": "food/bread", "description": "Bữa ăn gọn nhẹ, hồi 1 máu.", "effects": {"heal": 1}},
	"red_apple": {"name": "Táo đỏ", "kind": "consumable", "icon": "food/apple", "description": "Trái cây ngọt, hồi 1 máu.", "effects": {"heal": 1}},
	"ember_tonic": {"name": "Thuốc lửa", "kind": "consumable", "icon": "potions/luck_tonic", "description": "+1 sát thương trong 20 giây. Dùng lại làm mới thời gian.", "effects": {"attack": 1}, "duration": 20.0},
	"swift_tonic": {"name": "Thuốc nhanh nhẹn", "kind": "consumable", "icon": "potions/stamina_vial", "description": "+0,8 tốc độ trong 20 giây. Dùng lại làm mới thời gian.", "effects": {"speed": 0.8}, "duration": 20.0},
}
const SAMPLES := {"iron_sword": 1, "parry_dagger": 1, "battle_axe": 1, "leather_tunic": 1, "iron_chestplate": 1, "traveler_boots": 1, "amethyst_charm": 1, "minor_health_potion": 4, "hearty_bread": 3, "red_apple": 2, "ember_tonic": 2, "swift_tonic": 2}

static func item(id: String) -> Dictionary:
	return ITEMS.get(id, {}).duplicate(true)
