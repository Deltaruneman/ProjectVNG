#!/usr/bin/env python3
"""Sinh decor cho basement_1/2/3.tscn từ hình dạng thật của tầng (ô sàn, tường, phòng, rào đỏ).

Chạy từ thư mục gốc project:  python3 tools/basement_decor.py [basement_1 basement_2 basement_3]
Chạy lại được nhiều lần: phần decor cũ (node "Decor", "TorchModel", ext_resource id "dc_*") bị thay mới.
Đóng Godot trước khi chạy để editor không ghi đè file scene.

Quy tắc đặt:
  - Không đặt trong vùng quanh rào đỏ, lối ra, checkpoint, điểm xuất hiện, rương thưởng.
  - Hành lang giữ tối: chỉ vài thùng/đá vụn sát tường, thưa, không đuốc.
  - Sau khi đặt, kiểm tra BFS: mọi ô còn lại vẫn nối liền với điểm xuất hiện.
"""
import math
import random
import re
import sys
from collections import deque

CELL = 2.0
FLOOR_Y = 1.0
GLTF = "res://assets/vendor/KayKit_Dungeon/Assets/gltf/"

# Kích thước va chạm (x, y, z) và độ lệch (x, z) theo hệ trục của mô hình.
MODELS = {
    "pillar": ("pillar_decorated", (1.6, 4.0, 1.6), (0.0, 0.0)),
    "barrel": ("barrel_large", (1.7, 2.0, 1.7), (0.0, 0.0)),
    "barrels": ("barrel_small_stack", (1.8, 1.77, 1.0), (0.0, 0.0)),
    "crates": ("crates_stacked", (2.0, 2.1, 2.1), (0.0, 0.0)),
    "keg": ("keg_decorated", (3.4, 2.0, 1.9), (0.0, 0.0)),
    "rubble": ("rubble_half", (3.6, 2.2, 2.6), (2.0, 0.0)),
    "banner_a": ("banner_patternA_red", None, None),
    "banner_s": ("banner_shield_red", None, None),
    "banner_t": ("banner_thin_red", None, None),
    "sword": ("sword_shield", None, None),
    "torch": ("torch_mounted", None, None),
}
BANNER_SCALE = 0.85
BANNER_Y = 1.45
SWORD_Y = 3.1
# Cột thấp lại (đỉnh ~3,4 m, dưới đèn đuốc 3,6 m) để mặt trên nhận được ánh sáng, không đen kịt khi nhìn từ trên xuống.
MODEL_SCALE = {"pillar": (0.85, 0.6, 0.85)}
WALL_OFFSET = 0.12      # banner cách mặt tường
TORCH_DROP = -0.5       # mô hình đuốc thấp hơn đèn
GATE_CLEAR = 5.0
POINT_CLEAR = 4.5


# ---------------------------------------------------------------- đọc scene
def parse_scene(path):
    txt = open(path, encoding="utf-8").read()
    nl = "\r\n" if "\r\n" in txt else "\n"
    txt = txt.replace("\r\n", "\n")
    blocks = re.split(r"\n(?=\[)", txt)
    subs, nodes = {}, {}
    for b in blocks:
        h = b.split("\n", 1)[0]
        if h.startswith("[sub_resource"):
            m = re.search(r'type="(\w+)" id="([^"]+)"', h)
            sz = re.search(r"size = Vector3\(([^)]*)\)", b)
            subs[m.group(2)] = [float(x) for x in sz.group(1).split(",")] if sz else None
        elif h.startswith("[node"):
            name = re.search(r'name="([^"]+)"', h).group(1)
            par = re.search(r'parent="([^"]*)"', h)
            par = par.group(1) if par else None
            full = name if par is None else (name if par == "." else par + "/" + name)
            d = {"name": name, "parent": par, "path": full, "head": h, "text": b}
            t = re.search(r"transform = Transform3D\(([^)]*)\)", b)
            pm = re.search(r"\nposition = Vector3\(([^)]*)\)", b)
            rm = re.search(r"\nrotation = Vector3\(([^)]*)\)", b)
            if t:
                v = [float(x) for x in t.group(1).split(",")]
                d["pos"] = v[-3:]
                d["rot"] = math.atan2(v[2], v[0])
            else:
                d["pos"] = [float(x) for x in pm.group(1).split(",")] if pm else [0.0, 0.0, 0.0]
                d["rot"] = float(rm.group(1).split(",")[1]) if rm else 0.0
            sh = re.search(r'shape = SubResource\("([^"]+)"\)', b)
            d["shape"] = subs.get(sh.group(1)) if sh else None
            w = re.search(r"\nwidth = ([\d.]+)", b)
            d["width"] = float(w.group(1)) if w else 6.0
            nodes[full] = d
    return txt, nl, nodes


def grid_cells(txt, grid_path):
    for b in re.split(r"\n(?=\[)", txt):
        h = b.split("\n", 1)[0]
        if h.startswith("[node") and 'type="GridMap"' in h:
            name = re.search(r'name="([^"]+)"', h).group(1)
            par = re.search(r'parent="([^"]*)"', h).group(1)
            if par + "/" + name == grid_path:
                arr = [int(x) for x in re.search(r"PackedInt32Array\(([^)]*)\)", b).group(1).split(",")]
                out = set()
                for i in range(0, len(arr), 3):
                    x = arr[i] & 0xFFFF
                    y = arr[i] >> 16
                    z = arr[i + 1] & 0xFFFF
                    if x >= 32768:
                        x -= 65536
                    if z >= 32768:
                        z -= 65536
                    if y == 0:
                        out.add((x, z))
                return out
    raise SystemExit("không thấy GridMap " + grid_path)


def model_uids():
    uids = {}
    for key, (fname, _, _) in MODELS.items():
        imp = open(f"assets/vendor/KayKit_Dungeon/Assets/gltf/{fname}.gltf.import", encoding="utf-8").read()
        uids[key] = re.search(r'uid="(uid://[^"]+)"', imp).group(1)
    return uids


# ------------------------------------------------------------------ hình học
def cell_of(x, z):
    return (math.floor(x / CELL), math.floor(z / CELL))


def center_of(c):
    return (c[0] * CELL + CELL / 2, c[1] * CELL + CELL / 2)


def local_to_world(px, pz, yaw, lx, lz):
    return (px + math.cos(yaw) * lx + math.sin(yaw) * lz, pz - math.sin(yaw) * lx + math.cos(yaw) * lz)


class Level:
    def __init__(self, scene):
        self.scene = scene
        n = scene[-1]
        self.root = f"B{n}"
        self.path = f"levels/level_1/{scene}.tscn"
        self.txt, self.nl, self.nodes = parse_scene(self.path)
        self.floor = grid_cells(self.txt, f"{self.root}/World/Floor")
        self.wall = grid_cells(self.txt, f"{self.root}/World/Wall")
        self.free = self.floor - self.wall
        self.rooms = []      # (tên, x0, x1, z0, z1) vùng bên trong tường
        self.clear = []      # (x, z, bán kính)
        self.spawn = None
        for p, d in self.nodes.items():
            if re.fullmatch(rf"{self.root}/(Room\d|BossRoom)/Trigger", p):
                size = self.nodes[p + "/CollisionShape3D"]["shape"]
                x, _, z = d["pos"]
                self.rooms.append((p.split("/")[1], x - size[0] / 2, x + size[0] / 2, z - size[2] / 2, z + size[2] / 2))
            elif "/Gates/" in p and "instance=" in d["head"]:
                self.clear.append((d["pos"][0], d["pos"][2], GATE_CLEAR))
            elif re.search(r"/(ExitTo\w+|Checkpoint\w*|ClearReward|LadderSpot\w*)$", p):
                self.clear.append((d["pos"][0], d["pos"][2], POINT_CLEAR))
            elif p.endswith("MiniBossSpot_B3"):
                self.clear.append((d["pos"][0], d["pos"][2], 6.0))
            elif p == "Spawn":
                self.spawn = d["pos"]
                self.clear.append((d["pos"][0], d["pos"][2], POINT_CLEAR))
        self.used = set()
        self.items = []      # (room, tên, model, x, y, z, yaw, scale)
        self.extra_torches = []   # (tên, node cha, x, z, hướng vào trong theo x)
        self.rng = random.Random(scene)

    def in_room(self, x, z, margin=0.0):
        for name, x0, x1, z0, z1 in self.rooms:
            if x0 - margin <= x <= x1 + margin and z0 - margin <= z <= z1 + margin:
                return name
        return None

    def footprint(self, key, x, z, yaw):
        _, size, off = MODELS[key]
        sc = MODEL_SCALE.get(key, (1.0, 1.0, 1.0))
        size = (size[0] * sc[0], size[1] * sc[1], size[2] * sc[2])
        off = (off[0] * sc[0], off[1] * sc[2])
        cells, pts = set(), []
        sx, sz = size[0] - 0.2, size[2] - 0.2    # thụt vào 0,1 m để đồ sát tường không tính sang ô tường
        steps_x = max(2, int(sx / 0.5))
        steps_z = max(2, int(sz / 0.5))
        for i in range(steps_x + 1):
            for j in range(steps_z + 1):
                lx = off[0] - sx / 2 + sx * i / steps_x
                lz = off[1] - sz / 2 + sz * j / steps_z
                wx, wz = local_to_world(x, z, yaw, lx, lz)
                pts.append((wx, wz))
                cells.add(cell_of(wx, wz))
        return cells, pts

    def can_place(self, key, x, z, yaw):
        cells, pts = self.footprint(key, x, z, yaw)
        if not cells <= self.free or cells & self.used:
            return None
        for cx, cz, r in self.clear:
            if any(math.hypot(px - cx, pz - cz) < r for px, pz in pts):
                return None
        return cells

    def place(self, room, key, x, z, yaw=0.0):
        cells = self.can_place(key, x, z, yaw)
        if cells is None:
            return False
        self.used |= cells
        self.items.append((room, key, x, FLOOR_Y, z, yaw, MODEL_SCALE.get(key, 1.0)))
        return True

    def place_wall(self, room, key, x, z, yaw, y, scale):
        self.items.append((room, key, x, y, z, yaw, scale))


def snap_odd(v):
    return math.floor(v / CELL) * CELL + CELL / 2


def facing_yaw(nx, nz):
    return math.atan2(nx, nz)


# ----------------------------------------------------------------- bố cục
def decorate_room(lv, room):
    name, x0, x1, z0, z1 = room
    w, d = x1 - x0, z1 - z0
    rng = lv.rng
    boss = name == "BossRoom"

    # Cột: bốn cột (sáu ở phòng boss) tạo chỗ nấp và nhịp điệu cho phòng.
    fr = [(0.27, 0.27), (0.73, 0.27), (0.27, 0.73), (0.73, 0.73)]
    if boss:
        fr = [(0.18, 0.2), (0.82, 0.2), (0.18, 0.5), (0.82, 0.5), (0.18, 0.8), (0.82, 0.8)]
    for fx, fz in fr:
        px, pz = snap_odd(x0 + w * fx), snap_odd(z0 + d * fz)
        for dx, dz in [(0, 0), (2, 0), (-2, 0), (0, 2), (0, -2)]:
            if lv.place(name, "pillar", px + dx, pz + dz):
                break

    # Cụm đồ ở bốn góc, xoay quanh bức tường ngang (bắc/nam).
    patterns = ["rubble", "crates", "keg", "crates"]
    rng.shuffle(patterns)
    for k, (sx, sz) in enumerate([(1, 1), (-1, 1), (1, -1), (-1, -1)]):
        cx = x0 + 1 if sx > 0 else x1 - 1
        cz = z0 + 1 if sz > 0 else z1 - 1
        nx, nz = 0, (1 if sz > 0 else -1)      # hướng vào trong từ tường bắc/nam
        tx = sx                                  # hướng dọc tường, đi ra xa góc
        pat = patterns[k]
        yaw = facing_yaw(nx, nz)
        if pat == "rubble":
            ex = x0 + 0.2 if sx > 0 else x1 - 0.2
            ez = z0 + 1.55 if sz > 0 else z1 - 1.55
            ryaw = 0.0 if sx > 0 else math.pi
            lv.place(name, "rubble", ex, ez, ryaw)
        elif pat == "crates":
            lv.place(name, "crates", cx, cz, yaw + rng.uniform(-0.2, 0.2))
            lv.place(name, "barrel", cx + tx * 2.4, cz + nz * 0.05, 0.0)
            lv.place(name, "barrels", cx + nx * 0, cz + nz * 2.3, facing_yaw(tx, 0))
        else:
            lv.place(name, "keg", cx + tx * 1.4, cz, yaw)
            lv.place(name, "barrel", cx, cz + nz * 2.3, 0.0)

    # Đồ rải dọc tường bắc/nam, giữa các cụm góc: thùng lẻ.
    for sz in (1, -1):
        wz = z0 + 1 if sz > 0 else z1 - 1
        for fx in (0.5,):
            px = snap_odd(x0 + w * fx)
            if rng.random() < 0.6:
                lv.place(name, rng.choice(["barrels", "barrel", "crates"]), px, wz, facing_yaw(0, sz))

    # Tường bắc (nhìn rõ nhất từ camera): cờ xen kẽ đuốc, một tấm khiên kiếm.
    torch_x = sorted(d_["pos"][0] for p, d_ in lv.nodes.items()
                     if re.fullmatch(rf"{lv.root}/{name}/Torches/Torch\d", p) and abs(d_["pos"][2] - z0) < 1.0)
    cuts = [x0] + torch_x + [x1]
    spots = []
    for a, b in zip(cuts, cuts[1:]):
        spots.append((a + b) / 2)
    models = ["banner_t", "banner_s", "banner_t"] if len(spots) == 3 else ["banner_a"] * len(spots)
    for sx_, key in zip(spots, models):
        if wall_clear(lv, sx_, z0, 0, 1):
            lv.place_wall(name, key, sx_, z0 + WALL_OFFSET, 0.0, BANNER_Y, BANNER_SCALE)
    # Cờ ở tường tây/đông, giữa chiều dài.
    for sx_, ex_, yaw in [(x0, 1, math.pi / 2), (x1, -1, -math.pi / 2)]:
        zc = z0 + d / 2
        if wall_clear(lv, sx_, zc, ex_, 0):
            lv.place_wall(name, "banner_a", sx_ + ex_ * WALL_OFFSET, zc, yaw, BANNER_Y, BANNER_SCALE)
    # Khiên kiếm trên tường nam của phòng boss, giữa hai đuốc.
    if boss and wall_clear(lv, x0 + w / 2, z1, 0, -1):
        lv.place_wall(name, "sword", x0 + w / 2, z1 - WALL_OFFSET, math.pi, SWORD_Y, 1.0)

    # Phòng boss rộng 44 m chỉ có 4 đuốc ở tường bắc/nam: thêm hai đuốc (kèm đèn) ở tường tây và đông.
    if boss:
        for sx_, nx_ in [(x0, 1), (x1, -1)]:
            for dz in (0.0, 8.0, -8.0):
                zc = z0 + d / 2 + dz
                if wall_clear(lv, sx_, zc, nx_, 0):
                    lv.extra_torches.append((f"DecorTorch{'W' if nx_ > 0 else 'E'}", f"{lv.root}/{name}/Torches",
                                             sx_ + nx_ * 0.1, zc, nx_))
                    break

    # Mô hình đuốc đặt lên các đèn có sẵn (giữ nguyên ánh sáng và quầng lửa).
    for p, d_ in lv.nodes.items():
        if re.fullmatch(rf"{lv.root}/{name}/Torches/Torch\d", p):
            tx_, _, tz_ = d_["pos"]
            if abs(tz_ - z0) < 1.0:
                nx_, nz_ = 0, 1
            elif abs(tz_ - z1) < 1.0:
                nx_, nz_ = 0, -1
            elif abs(tx_ - x0) < 1.0:
                nx_, nz_ = 1, 0
            elif abs(tx_ - x1) < 1.0:
                nx_, nz_ = -1, 0
            else:
                continue
            lv.items.append((p, "torch", -nx_ * 0.1, TORCH_DROP, -nz_ * 0.1, facing_yaw(nx_, nz_), 1.0))


def wall_clear(lv, x, z, nx, nz):
    """Có tường đặc phía sau điểm (x, z) và không có cổng/lối ra gần đó."""
    behind = cell_of(x - nx * 1.0, z - nz * 1.0)
    if behind not in lv.wall:
        return False
    return all(math.hypot(x - cx, z - cz) >= r for cx, cz, r in lv.clear)


def decorate_corridors(lv):
    corridor = {c for c in lv.free if lv.in_room(*center_of(c), margin=2.1) is None}
    placed = []
    cycle = ["barrels", "crates", "barrel", "barrels", "rubble", "crates"]
    idx = 0
    far = 11.0
    for c in sorted(corridor, key=lambda c: (c[1], c[0])):
        x, z = center_of(c)
        if any(math.hypot(x - px, z - pz) < far for px, pz in placed):
            continue
        for nx, nz in [(0, 1), (0, -1), (1, 0), (-1, 0)]:
            back = (c[0] - nx, c[1] - nz)
            if back not in lv.wall:
                continue
            # Chỉ đặt khi lối đi rộng ≥ 3 ô tính từ tường (4 ô cho đá vụn) và không phải khúc cua. Hành lang hiện tại hẹp 1-2 ô nên không có gì được đặt: giữ hành lang tối và trống.
            key = cycle[idx % len(cycle)]
            need = 4 if key == "rubble" else 3
            if not all((c[0] + nx * k, c[1] + nz * k) in corridor for k in range(need)):
                continue
            side = (nz, nx)
            if not all((c[0] + side[0] * s, c[1] + side[1] * s) in corridor for s in (-1, 1)):
                continue
            if key == "rubble":
                # Đá vụn dài 4 m chạy dọc tường. Trục +x của mô hình trùng hướng `side`, gốc ở một đầu.
                yaw = math.atan2(-side[1], side[0])
                ox = x - side[0] * 2.0 + nx * 0.55
                oz = z - side[1] * 2.0 + nz * 0.55
                ok = lv.place("Corridor", "rubble", ox, oz, yaw)
            else:
                ok = lv.place("Corridor", key, x - nx * 0.05, z - nz * 0.05, facing_yaw(nx, nz) + lv.rng.uniform(-0.25, 0.25))
            if ok:
                placed.append((x, z))
                idx += 1
                break


# ------------------------------------------------------------- kiểm tra BFS
def reachable(lv, blocked):
    start = cell_of(lv.spawn[0], lv.spawn[2])
    seen = {start}
    q = deque([start])
    while q:
        c = q.popleft()
        for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (c[0] + dx, c[1] + dz)
            if n in lv.free and n not in blocked and n not in seen:
                seen.add(n)
                q.append(n)
    return seen


def verify(lv):
    """Mọi ô còn lại phải nối với điểm xuất hiện. Ô lẻ bị đồ vật bao kín (kẽ giữa các thùng) thì lấp luôn."""
    before = reachable(lv, set())
    for _ in range(5):
        after = reachable(lv, lv.used)
        lost = (before - lv.used) - after
        if not lost:
            return len(before), len(lv.used)
        # Tách thành các cụm liền kề; chỉ chấp nhận lấp cụm nhỏ (kẽ hẹp), cụm lớn nghĩa là chặn mất đường.
        rest = set(lost)
        while rest:
            comp, q = set(), deque([next(iter(rest))])
            while q:
                c = q.popleft()
                if c in comp:
                    continue
                comp.add(c)
                for dx, dz in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                    n = (c[0] + dx, c[1] + dz)
                    if n in rest and n not in comp:
                        q.append(n)
            rest -= comp
            if len(comp) > 4:
                raise SystemExit(f"{lv.scene}: decor chặn mất {len(comp)} ô liền nhau quanh {sorted(comp)[0]}")
            lv.used |= comp
    raise SystemExit(f"{lv.scene}: không ổn định sau khi lấp kẽ")


# ---------------------------------------------------------------- ghi file
def fmt(v):
    return ("%.3f" % v).rstrip("0").rstrip(".") if abs(v) > 1e-6 else "0"


def strip_old(txt):
    blocks = re.split(r"\n(?=\[)", txt)
    keep = []
    for b in blocks:
        h = b.split("\n", 1)[0]
        if h.startswith("[ext_resource") and re.search(r'id="dc_', h):
            continue
        if h.startswith("[node"):
            name = re.search(r'name="([^"]+)"', h).group(1)
            par = re.search(r'parent="([^"]*)"', h)
            par = par.group(1) if par else ""
            if name == "TorchModel" or name.startswith("DecorTorch") or "/DecorTorch" in par \
                    or name == "Decor" and par.startswith("B") or re.match(r"B\d/Decor", par):
                continue
        keep.append(b)
    return "\n".join(keep).rstrip("\n") + "\n"


def write_scene(lv, uids):
    txt = strip_old(lv.txt)
    lines = txt.split("\n")
    last = max(i for i, l in enumerate(lines) if l.startswith("[ext_resource"))
    ext = ['[ext_resource type="Script" path="res://levels/objects/decor/decor_prop.gd" id="dc_prop"]']
    used_keys = sorted({it[1] for it in lv.items} | ({"torch"} if lv.extra_torches else set()))
    for k in used_keys:
        ext.append(f'[ext_resource type="PackedScene" uid="{uids[k]}" path="{GLTF}{MODELS[k][0]}.gltf" id="dc_{k}"]')
    lines[last + 1:last + 1] = ext
    out = "\n".join(lines).rstrip("\n") + "\n"
    out += f'\n[node name="Decor" type="Node3D" parent="{lv.root}"]\nmetadata/note = "Sinh bởi tools/basement_decor.py. Mỗi món là DecorProp: kéo/xoay/đổi model trực tiếp được."\n'
    groups = []
    for it in lv.items:
        if it[1] != "torch" and it[0] not in groups:
            groups.append(it[0])
    for g in groups:
        out += f'\n[node name="{g}" type="Node3D" parent="{lv.root}/Decor"]\n'
    flame = next((d["text"] for p, d in lv.nodes.items() if d["name"] == "Flame" and "/Torches/" in p), "")
    flame_mesh = re.search(r'mesh = SubResource\("([^"]+)"\)', flame).group(1)
    for nm, parent, x, z, nx_ in lv.extra_torches:
        out += f'\n[node name="{nm}" type="OmniLight3D" parent="{parent}"]\nposition = Vector3({fmt(x)}, 3.6, {fmt(z)})\n'
        out += 'light_color = Color(1, 0.62, 0.32, 1)\nlight_energy = 2.2\nomni_range = 11.0\nomni_attenuation = 1.2\n'
        out += f'\n[node name="Flame" type="MeshInstance3D" parent="{parent}/{nm}"]\ncast_shadow = 0\nmesh = SubResource("{flame_mesh}")\n'
        out += f'\n[node name="TorchModel" type="Node3D" parent="{parent}/{nm}"]\n'
        out += f"position = Vector3({fmt(-nx_ * 0.1)}, {fmt(TORCH_DROP)}, 0)\n"
        if nx_ != 0:
            out += f"rotation = Vector3(0, {fmt(facing_yaw(nx_, 0))}, 0)\n"
        out += 'script = ExtResource("dc_prop")\nmodel = ExtResource("dc_torch")\n'
    counter = {}
    for room, key, x, y, z, yaw, scale in lv.items:
        counter[(room, key)] = counter.get((room, key), 0) + 1
        nm = f"{key.capitalize()}{counter[(room, key)]}"
        if key == "torch":
            out += f'\n[node name="TorchModel" type="Node3D" parent="{room}"]\n'
        else:
            out += f'\n[node name="{nm}" type="Node3D" parent="{lv.root}/Decor/{room}"]\n'
        out += f"position = Vector3({fmt(x)}, {fmt(y)}, {fmt(z)})\n"
        if abs(yaw) > 1e-6:
            out += f"rotation = Vector3(0, {fmt(yaw)}, 0)\n"
        sc = scale if isinstance(scale, tuple) else (scale, scale, scale)
        if any(abs(v - 1.0) > 1e-6 for v in sc):
            out += f"scale = Vector3({fmt(sc[0])}, {fmt(sc[1])}, {fmt(sc[2])})\n"
        out += 'script = ExtResource("dc_prop")\n'
        out += f'model = ExtResource("dc_{key}")\n'
        size = MODELS[key][1]
        if size is not None:
            out += f"collision_size = Vector3({fmt(size[0])}, {fmt(size[1])}, {fmt(size[2])})\n"
            off = MODELS[key][2]
            if off != (0.0, 0.0):
                out += f"collision_offset = Vector3({fmt(off[0])}, 0, {fmt(off[1])})\n"
    if lv.nl != "\n":
        out = out.replace("\n", lv.nl)
    open(lv.path, "w", encoding="utf-8", newline="").write(out)


def main():
    scenes = sys.argv[1:] or ["basement_1", "basement_2", "basement_3"]
    uids = model_uids()
    for sc in scenes:
        lv = Level(sc)
        for room in lv.rooms:
            decorate_room(lv, room)
        decorate_corridors(lv)
        reach, blocked = verify(lv)
        write_scene(lv, uids)
        print(f"{sc}: {len(lv.items)} món, {blocked} ô bị chiếm, {reach} ô đi được (BFS ổn)")


if __name__ == "__main__":
    main()
