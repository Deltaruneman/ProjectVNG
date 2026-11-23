# Dark Fairy boss

Asset gốc: `darkfairy_full_version.zip`, đã giải nén vào `darkfairy_full_version/`.
Giữ nguyên tên file gốc, bao gồm thư mục `closeatack_` viết thiếu chữ `t`.
Animation sử dụng spritesheet 64 × 64 px, đọc từ trái sang phải, từ trên xuống dưới;
chỉ dùng số frame thực tế, bỏ các ô trống cuối sheet.

## Chạy thử

Mở `tests/darkfairy_arena.tscn`, nhấn **F6**. Foxy xuất hiện gần boss ở B3,
có sẵn vũ khí; khi chết, scene test tự tải lại, không thay checkpoint đã lưu.
Scene chính `levels/level_1/basement_full.tscn` cũng đã có boss tại
`B3/MiniBossSpot_B3/DarkFairy`.

Điều khiển: WASD/mũi tên di chuyển, Space nhảy, C/J đánh, U dùng kỹ năng,
Shift lướt, L parry.

## Hành vi và animation

| Phase | Asset / chiêu | Hành vi |
| --- | --- | --- |
| 1 | `idle` | Chờ Foxy trong bán kính 11 m, cùng tầng |
| 1 | `closeattack` | Đánh vùng phía trước, gây sát thương ở frame 7 |
| 1 | `castspell`, `spell` | Khóa vị trí Foxy khi bắt đầu niệm, báo vùng 0,6 giây rồi đánh xuống |
| 1 | `createshield`, `shieldhit` | Khiên chặn 3 đòn hoặc hết sau 5 giây; phản ứng khi trúng đòn |
| 1 | `teleportation` | Biến mất rồi phát ngược animation để xuất hiện tại điểm an toàn gần vị trí ban đầu |
| Chuyển phase | `transformation_into_phase2` | Biến hình khi máu còn ≤ 50%; miễn sát thương trong lúc biến hình |
| 2 | `castspell`, `spell` | Ba vùng phép; báo trước 0,72 giây |
| 2 | `summonspirits` | Gọi tối đa 3 linh hồn/lần, tối đa 6 con đang tồn tại |
| 2 | `explosion` | Nổ bán kính 3,8 m quanh boss, có vùng báo trước |
| 1/2 | `hurt` | Ngắt chiêu khi bị đánh; parry cũng ngắt chiêu và phá khiên, không trừ máu boss |
| 2 | `death` | Xóa phép và linh hồn, phát animation chết, phát signal `defeated`, xóa boss |
| Linh hồn | `summoned`, `idle`, `hurt`, `death` | Bay đuổi Foxy, gây sát thương khi chạm; có 2 HP, sống tối đa 12 giây, có thể đánh/parry |

Boss có 40 HP. Chiêu gây 1 sát thương và dùng hệ thống HurtArea3D của project,
nên lướt bất tử và parry của Foxy vẫn được áp dụng. Sprite billboard lật trái/phải;
bộ asset không có đủ bốn hướng. Không thêm cơ chế lưu trạng thái boss đã chết.

Thông số HP, sát thương và khoảng cách có thể chỉnh trong Inspector của boss.
Animation và callback ở `scenes/enemies/darkfairy/darkfairy_anims.tres`.

## Các điểm cần test trong Godot

1. Đứng xa hoặc ở tầng dưới: boss không tấn công, thanh HP boss ẩn.
2. Lại gần: boss luân phiên phép, khiên, dịch chuyển; đứng sát để thử đánh gần.
3. Rời vùng báo trước trước khi phép nổ: không mất máu; đứng lại: mất 1 HP.
4. Đánh khiên ba lần hoặc chờ 5 giây: khiên mất; parry đòn boss: boss bị ngắt chiêu.
5. Đưa boss xuống 20 HP: biến hình một lần, chuyển sang bộ chiêu phase 2.
6. Đánh/parry linh hồn; kiểm tra giới hạn 6 con và các vùng phép/nổ có thể né.
7. Hạ boss: animation chết chạy hết, phép/linh hồn và thanh HP được dọn.
8. Foxy chết trong scene test: quay lại scene test. Chạy scene chính để kiểm tra
   boss ở đúng B3, phép và linh hồn ẩn theo tầng.

Chưa xác minh runtime trong Godot theo yêu cầu để người dùng tự test.
