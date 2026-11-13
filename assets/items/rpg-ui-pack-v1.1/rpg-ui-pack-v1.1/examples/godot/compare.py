"""Compare the Godot screenshot with the Python reference render, pixel by pixel."""
import json
import sys
from pathlib import Path

from PIL import Image

here = Path(__file__).resolve().parent
a = Image.open(here / 'screenshot-1x.png').convert('RGB')
b = Image.open(here / 'expected-1x.png').convert('RGB')
assert a.size == b.size == (320, 180), (a.size, b.size)
pa, pb = a.load(), b.load()
bad = [(x, y) for y in range(180) for x in range(320) if pa[x, y] != pb[x, y]]
diff = b.copy()
dp = diff.load()
for x, y in bad:
    dp[x, y] = (255, 0, 255)
diff.resize((960, 540), Image.Resampling.NEAREST).save(here / 'diff-3x.png')
layout = json.loads((here / 'layout.json').read_text())['elements']
per = {}
for e in layout:
    w, h = e.get('w', 16), e.get('h', 16 if e['type'] != 'bar' else 8)
    if e['type'] == 'text':
        w, h = 6 * len(e['text']), 9
    key = f"{e['type']}:{e.get('sprite') or e.get('name') or e.get('kind') or e.get('text', '')[:12]}"
    n = sum(1 for x, y in bad if e['x'] <= x < e['x'] + w and e['y'] <= y < e['y'] + h)
    if n:
        per[key] = per.get(key, 0) + n
report = {'mismatched_pixels': len(bad), 'total': 320 * 180, 'by_element': per}
(here / 'compare.json').write_text(json.dumps(report, indent=1) + '\n')
print(json.dumps(report, indent=1))
sys.exit(0 if not bad else 1)
