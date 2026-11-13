import { spawnSync } from 'node:child_process';
import { copyFileSync, mkdirSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const output = mkdtempSync(join(tmpdir(), 'arcana-lightning-beam-'));
const library = join(root, 'assets/effects/pixelfx-main/pixelfx-main');
const palette = ['#191838', '#343366', '#605c9c', '#9290d0', '#d5d7ff', '#f0edb3', '#fffac9', '#ffffff'];
const result = spawnSync(process.execPath, [join(library, 'tools/render.mjs'), 'arcane/arcane-beam', '--sheet', '--no-actor', '--opts', JSON.stringify({ palette }), '--out', output], { encoding: 'utf8' });
if (result.status !== 0) throw new Error(result.stderr || result.stdout);
const target = join(root, 'assets/effects/pixelfx/lightning/horizontal-beam');
mkdirSync(target, { recursive: true });
for (const [src, dst] of [['arcane-beam.png', 'horizontal-beam.png'], ['arcane-beam.json', 'horizontal-beam.json'], ['contact.png', 'contact.png']]) {
  copyFileSync(join(output, 'arcane/arcane-beam', src), join(target, dst));
}
console.log('Exported horizontal lightning beam');
