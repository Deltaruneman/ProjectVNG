# Quái mới — hướng dẫn test thủ công

Chưa mở/chạy Godot theo yêu cầu của bạn. Đây là checklist cần bạn kiểm chứng, không phải kết quả gameplay đã pass.

Mở `tests/arcane_enemies_test.tscn`, bấm F6. Player có vũ khí, bắt đầu gần Wizard 1; đi sang phải lần lượt gặp Wizard 2 (x=-6), Necromancer (x=8), Executioner (x=23). Scene dùng Player/camera/autoload hiện tại; không thay main scene hoặc đặt quái vào basement. SP nhặt được vẫn đi qua hệ thống tiến trình hiện có.

| Scene trong scenes/enemies/arcane | HP | Sát thương | Hành vi |
|---|---:|---:|---|
| evil_wizard_1.tscn | 8 | 1 | Đuổi tới tầm 6m, bắn đạn phép vào vị trí đã ngắm |
| evil_wizard_2.tscn | 12 | 2 | Đuổi tới 2.1m, luân phiên hai đòn cận chiến |
| necromancer.tscn | 14 | 1 | Bắn phép, triệu hồi tối đa 2 Skeleton; hồi triệu hồi 8s |
| undead_executioner.tscn | 90 | 3/4 | Combo hai nhát, mỗi đòn thứ ba dùng chiêu vòng tròn, triệu hồi tối đa 2 lính; dưới nửa HP hồi đòn còn 65% |
| executioner_summon.tscn | 3 | 1 | Xuất hiện, đuổi/đánh, tự hết hạn sau 18s; không rơi SP |

Chỉ số cân bằng tạm, chỉnh ở Inspector. Wizard 1/2 và Necromancer có hurt riêng. Executioner và lính của nó giữ nguyên pose, đứng im và đỏ 0.2s rồi trở lại; không thêm vùng nhận sát thương cho Pelican/Mushroom. Các quái cũ có hurt giữ nguyên.

Cần test:
- Nhận đòn lúc đứng, đi, chuẩn bị đánh: HP giảm, hurt đúng, trở lại AI; hit lặp trong hurt không trừ liên tục.
- Đòn chí tử trong mọi trạng thái: không phát thêm đòn, chạy death, biến mất và chỉ rơi SP một lần (2/3/3/10 cho bốn quái).
- Wizard 2/boss: né ra sau hoặc khỏi tầm trước impact để tránh đòn; skill boss đánh quanh thân trong 3.8m.
- Tường che phải ngăn đòn; khác tầng >1.5m không bị đánh; kiểm tra thực tế va chạm và đường đi trên map trước khi tích hợp. AI dùng đuổi thẳng có va chạm, chưa tìm đường vòng qua mê cung.
- Parry, đóng băng, slow, burn: không kẹt đỏ hoặc đứng im; đóng băng dừng đòn và animation.
- Triệu hồi cần nền và khoảng trống; không quá giới hạn; quái triệu hồi không rơi SP; chủ chết/rời scene phải dọn lính.
- Boss xuống <=45 HP rút ngắn hồi đòn; animation, hitbox, vị trí chân và thanh máu cần nhìn trực tiếp để chốt.

Kiểm tra tĩnh đã chạy: 11 tài nguyên scene/library, 48 đường dẫn, 214 frame, 10 event impact hợp lệ về đường dẫn/chia sheet/thời gian key; kiểm tra alpha loại frame trống trong idle boss và death lính. `git diff --check` pass. Chưa parse bằng Godot, chưa kiểm chứng gameplay/render/collision, chưa có reviewer sign-off. Không sửa map, Player, save, không commit/push.
