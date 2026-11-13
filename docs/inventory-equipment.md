# Túi đồ và trang bị

Mở từ ESC → Túi đồ / Trang bị hoặc B. Q dùng vật phẩm đã gán khi đang chơi.
Cả hai phím có thể đổi trong Cài đặt → Điều khiển; HUD hiển thị phím hiện tại.
Nếu B/Q đã được dùng trong cấu hình cũ, giữ cấu hình cũ và gán lại phím mới qua ESC.

Ba ô trang bị: vũ khí, giáp, bùa. Chọn vật phẩm → xem mô tả và chỉ số trước/sau → Trang bị.
Tháo ở thẻ tương ứng. Không có tải trọng, độ bền, cấp hiếm hay kho phụ.
Vũ khí chỉ thêm chỉ số, không thay đổi nguyên tố, animation hoặc sprite vũ khí hiện tại.
Chọn tiêu hao → Gán dùng nhanh; trở lại gameplay và nhấn Q. Tạm dừng, hội thoại, chết,
đang thi triển hoặc hồi dùng nhanh 1 giây sẽ chặn tiêu hao. Máu đầy không mất dược hồi phục.

## Vật phẩm mẫu hiện tại

Chỉ số dưới đây là cấu hình mẫu để thử, chưa phải cân bằng cuối:

| ID | Loại | Hiệu ứng | Số lượng ban đầu |
|---|---|---|---|
| iron_sword | Vũ khí | +1 sát thương | 1 |
| parry_dagger | Vũ khí | +0,03 giây cửa sổ parry | 1 |
| battle_axe | Vũ khí | +2 sát thương | 1 |
| leather_tunic | Giáp | +2 máu tối đa; không hồi máu khi mặc | 1 |
| iron_chestplate | Giáp | +4 máu tối đa; không hồi máu khi mặc | 1 |
| traveler_boots | Bùa | +0,5 tốc độ | 1 |
| amethyst_charm | Bùa | +0,02 giây cửa sổ parry | 1 |
| minor_health_potion | Tiêu hao | Hồi 2 máu | 4 |
| hearty_bread | Tiêu hao | Hồi 1 máu | 3 |
| red_apple | Tiêu hao | Hồi 1 máu | 2 |
| ember_tonic | Tiêu hao | +1 sát thương trong 20 giây | 2 |
| swift_tonic | Tiêu hao | +0,8 tốc độ trong 20 giây | 2 |

Không tự mặc trang bị. Bình hồi phục nhỏ được gán dùng nhanh ban đầu.
Trang bị là vật phẩm duy nhất; tiêu hao cộng dồn tối đa 99. Dùng lại cùng dược tăng chỉ số
chỉ làm mới thời gian, không cộng thêm hiệu ứng của chính dược đó.

## Tích hợp

`scripts/items/item_catalog.gd` là nguồn ID, tên, loại, ô, mô tả, icon và effects.
Không lưu tên hiển thị hay chỉ số tùy ý từ save; chỉ lưu ID đã biết.
Icon, khung gỗ, tab và ô túi đồ dùng Hearthmark RPG UI + Icon Pack v1.1 trong
`assets/items/rpg-ui-pack-v1.1/rpg-ui-pack-v1.1` (CC0; giữ `LICENSE.txt` và `README.txt`).
Giao diện dùng bộ lọc loại, lưới icon có số lượng, thẻ trang bị và bảng chi tiết.

```gdscript
# Ví dụ cho hệ thống nhặt đồ tương lai; caller quyết định một lần nhặt hợp lệ.
var accepted := GameManager.inventory.grant("minor_health_potion", 1)
# Chỉ đánh dấu nguồn nhặt đã nhận nếu accepted == true.
GameManager.inventory.equip("iron_sword")
GameManager.inventory.unequip("weapon")
GameManager.inventory.select_quick("minor_health_potion")
GameManager.inventory.use_quick(player)
```

`changed` cập nhật UI và tính lại chỉ số Player theo nguồn gốc, không cộng dồn mỗi lần trang bị.
Để thêm dạng chỉ số mới, mở rộng danh sách effects và phép tính trong Player; không đổi hệ thống save.
Phần nhặt đồ/chế tạo/drop chưa nối vào map. Việc gọi grant phải do owner của hệ thống đó tích hợp;
API không tự tạo nguồn loot hoặc đánh dấu rương đã mở.

## Lưu game

Inventory là trường tùy chọn trong payload GameManager version 1; giữ nguyên trường chưa biết.
Save cũ không có trường inventory và new game nhận bộ mẫu. Save inventory đời đầu (version 1)
được chuyển ID cũ sang vật phẩm tương ứng; số lượng 0, trang bị và ô tiêu hao đã chọn vẫn được giữ.
ID mới tiếp tục được kiểm tra cùng số lượng và ô trang bị; dữ liệu lỗi bị loại bỏ, không cấp lại
bộ mẫu. Stack hết vẫn giữ 0.
Lưu cùng tiến trình hiện tại ở checkpoint. Buff tiêu hao đang chạy và máu hiện tại không lưu;
trang bị, số lượng, vật phẩm gán dùng nhanh có lưu. Không thay đổi hợp đồng respawn hồi máu.

## Kiểm chứng

`tests/inventory_combat_test.gd` dùng save/settings riêng trong docs/validation/inventory-combat,
không ghi vào save người chơi. Hai kích thước cửa sổ, save roundtrip/fresh restart, chỉ số trang bị,
chống hồi máu qua mặc/tháo, buff/stack, dữ liệu lỗi, UI và ESC đã được kiểm tra bằng Godot render.
Gameplay trong toàn map, cân bằng, nhận đồ từ rương/quái và reviewer acceptance còn chờ.
