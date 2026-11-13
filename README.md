# ProjectVNG

Game 3D dùng sprite billboard và camera orbit được xây dựng bằng **Godot 4.7.2**. Người chơi điều khiển
Foxy khám phá màn chơi, chiến đấu với kẻ địch, nhảy qua địa hình, nhặt và ném
đối tượng trong các màn chơi, hiện khởi động ở basement liên tục B1/B2.

> Đây là project thực hành đang được phát triển. Scene khởi động hiện tại là
> `levels/level_1/basement_full.tscn`.

## Hiện trạng và kiểm chứng

Snapshot audit ngày 2026-11-13: [hệ thống hiện tại](docs/project-current-state.md), [bug có bằng chứng](docs/implementation-bugs.md), [test và manual checklist](docs/project-audit-validation.md). Có lỗi map/visibility, navigation, Pelican damage và duplicate HUD còn mở; danh sách tính năng bên dưới không phải nghiệm thu. Test cần chạy trong bản sao có user data riêng, xác minh trước autoload; không dùng save thật. F5 continuation và F6 explicit-scene có semantics khác nhau được mô tả trong audit.

## Tính năng

- Điều khiển nhân vật theo bốn hướng với hệ thống state machine.
- Di chuyển, nhảy, tấn công và sử dụng kỹ năng.
- Nhặt và ném các đối tượng có thể tương tác.
- Hệ thống máu, sát thương, vùng gây sát thương và vùng nhận sát thương.
- Nhiều loại kẻ địch: Crab, Barrel, Mushroom, Starfish và Pelican.
- Màn chơi 3D dạng GridMap với cây cối, bẫy, nước và các vật thể môi trường.
- Animation dùng `AnimationPlayer` và sprite sheet.

## Yêu cầu

- [Godot Engine 4.7](https://godotengine.org/download/archive/4.7-stable/)
- Renderer tương thích OpenGL 3.3 hoặc thiết bị hỗ trợ Godot Compatibility

Project sử dụng renderer `gl_compatibility`, vì vậy không bắt buộc GPU hiện đại.

## Chạy project

1. Clone repository:

   ```bash
   git clone https://github.com/Deltaruneman/ProjectVNG.git
   cd ProjectVNG
   ```

2. Mở Godot Project Manager và chọn **Import**.
3. Chọn file `project.godot` trong thư mục project.
4. Mở project bằng Godot 4.7.
5. Nhấn **F6** để chạy scene hiện tại hoặc **F5** để chạy project từ scene chính.

Scene chính được cấu hình tại:

```text
levels/level_1/basement_full.tscn
```

## Điều khiển

Đây là defaults trong `project.godot`; GameSettings có thể nạp phím tùy chỉnh từ settings riêng.

| Hành động | Phím |
|---|---|
| Di chuyển | `W` `A` `S` `D` hoặc phím mũi tên |
| Nhảy | `Space` |
| Tấn công | `J` hoặc chuột trái |
| Nhặt / giữ đối tượng | `X` hoặc `K` |
| Chọn ô kỹ năng thường | `1` `2` `3` `4` |
| Thi triển kỹ năng thường | `U` hoặc `E`; tap cast khi thả, giữ 0.3 s để hiện aim |
| Thi triển tuyệt kỹ đã chọn khi Nộ đầy | `R` hoặc `I` |
| Mở cây kỹ năng | `T` |
| Dash / parry | `Shift` / `L` hoặc chuột phải |
| Tương tác | `F` |
| Camera / thả con trỏ | Chuột + wheel / giữ `Alt` |
| Pause và settings | `Esc` |

## Cấu trúc thư mục

```text
.
├── assets/                 # Sprite, model, mesh, shader và dữ liệu animation
├── levels/                 # Các màn chơi
├── scenes/
│   ├── player/             # Scene, animation và state của Foxy
│   ├── enemies/            # Scene và logic của kẻ địch
│   ├── objects/            # Vật thể tương tác và môi trường
│   └── camera/             # Camera của màn chơi
├── scripts/
│   ├── fsm/                # Finite State Machine dùng chung
│   └── *.gd                # Character, collision area và tiện ích
├── tools/                  # Script hỗ trợ tạo dữ liệu trong editor
├── project.godot          # Cấu hình project và input
└── run.res                # Tài nguyên chạy thử
```

## Kiến trúc gameplay

Nhân vật và kẻ địch kế thừa từ các lớp dùng chung trong `scripts/`:

- `BaseCharacter`: chuyển hướng, di chuyển, trọng lực, animation và tương tác
  cơ bản.
- `EnemyCharacter`: hành vi chung của kẻ địch.
- `FSM` / `State`: quản lý các trạng thái như idle, run, jump, attack, hurt và
  dead.
- `HitArea3D` / `HurtArea3D`: tách vùng tấn công và vùng nhận sát thương.

Khi thêm một trạng thái mới, nên đặt script trong thư mục `states/` tương ứng
và đăng ký node state trong scene nhân vật.

## Tài liệu asset

- [Hướng dẫn animation chung](assets/sprites/ANIMATION_GUIDE.md)
- [Animation của Pelican](assets/monsters/pelican/ANIMATION.md)
- [Animation của King Crab](assets/sprites/boss/kingcrab/ANIMATION.md)
- [Animation của Foxy](assets/foxy/fox_hat/README.md)

## Đóng góp

1. Tạo một branch mới cho thay đổi của bạn.
2. Giữ đúng quy ước thư mục và naming hiện có.
3. Mở project bằng Godot và chạy scene chính để kiểm tra.
4. Gửi pull request kèm mô tả thay đổi và cách kiểm thử.

## Giấy phép

Project chưa khai báo giấy phép phân phối. Không sử dụng lại code hoặc asset
cho mục đích khác nếu chưa được chủ project cho phép.
 
