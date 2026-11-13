import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync, mkdtempSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const library = join(root, 'assets/effects/pixelfx-main/pixelfx-main');
const palettes = {
  white: ['#161b26', '#343d50', '#626f85', '#9ba9be', '#c8d3e4', '#e6edf5', '#f7fbff', '#ffffff'],
  fire: ['#280c0a', '#671b10', '#ad3212', '#e95c18', '#ff9d32', '#ffd275', '#fff0b8', '#ffffff'],
  ice: ['#071e39', '#0c4262', '#147395', '#2ba9c9', '#6ed9ef', '#b3f0ff', '#e4fbff', '#ffffff'],
  lightning: ['#272038', '#554059', '#8a6560', '#c89d43', '#f4d84d', '#fff18b', '#fffbc7', '#ffffff'],
};
const previewRoot = mkdtempSync(join(tmpdir(), 'projectvng-orbs-'));
for (const [form, palette] of Object.entries(palettes)) {
  const output = join(previewRoot, form);
  const result = spawnSync(process.execPath, [join(library, 'tools/render.mjs'), 'projectiles/plasma-shot',
    '--sheet', '--no-actor', '--opts', JSON.stringify({ palette, size: 8 }), '--out', output], { encoding: 'utf8' });
  if (result.status !== 0) throw new Error(result.stderr || result.stdout);
  const target = join(root, 'assets/effects/pixelfx/projectiles', `orb-${form}`);
  mkdirSync(target, { recursive: true });
  const source = join(output, 'projectiles/plasma-shot');
  copyFileSync(join(source, 'plasma-shot.png'), join(target, `orb-${form}.png`));
  copyFileSync(join(source, 'plasma-shot.json'), join(target, `orb-${form}.json`));
  copyFileSync(join(source, 'contact.png'), join(target, 'contact.png'));
  writeFileSync(join(target, 'palette.json'), JSON.stringify({ source: 'projectiles/plasma-shot', palette, size: 8 }, null, 2) + '\n');
  console.log(`Exported orb-${form}`);
}
