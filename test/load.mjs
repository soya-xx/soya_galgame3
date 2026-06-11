/* 在 Node 中加载浏览器端剧本（共享 window shim） */
import { readFileSync } from 'node:fs';
import { join } from 'node:path';
import { fileURLToPath } from 'node:url';
import vm from 'node:vm';

const root = join(fileURLToPath(new URL('.', import.meta.url)), '..', 'web');
const ctx = { window: {} };
ctx.window.window = ctx.window;
vm.createContext(ctx);
const files = ['script/dsl.js', 'script/characters.js', 'script/ch0.js', 'script/ch1.js',
  'script/ch2.js', 'script/ch3.js', 'script/ch4.js', 'script/ch5.js', 'script/endings.js'];
for (const f of files) {
  const code = readFileSync(join(root, f), 'utf8');
  vm.runInContext(`(function(window){ with(window){ ${code} } })(window)`, ctx, { filename: f });
}
export const W = ctx.window;
export const STORY = ctx.window.STORY;
export const CHARS = ctx.window.CHARS;
export const MUSIC = ctx.window.MUSIC;
export const BGS = ctx.window.BGS;
export const CG_TITLES = ctx.window.CG_TITLES;
export const evalCond = ctx.window.evalCond;
export const applyFx = ctx.window.applyFx;

export function fail(msg) { console.error('  ✘ ' + msg); failures.push(msg); }
export function ok(msg) { console.log('  ✔ ' + msg); }
export const failures = [];
export function finish(name) {
  if (failures.length) { console.error(`\n${name}: ${failures.length} 处失败`); process.exit(1); }
  console.log(`\n${name}: 全部通过`);
}
