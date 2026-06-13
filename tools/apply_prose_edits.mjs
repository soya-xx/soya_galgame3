/* 应用文笔大白话替换清单：只换 C.n/C.mc/C.l 整行，结构行一律拒绝。
   用法: node tools/apply_prose_edits.mjs <edits.json>
   edits.json 形如 [{file, edits:[{old,neu,why}], summary}, ...] */
import fs from 'node:fs';

const STRUCT = /choice\(|router\(|C\.label\(|C\.jump\(|C\.scene\(|makeChapter|C\.theEnd\(|C\.ending\(/;
const CALL = /^\s*C\.(n|mc|l)\(/;

const jsonPath = process.argv[2];
if (!jsonPath) { console.error('需要 edits.json 路径'); process.exit(1); }
const data = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

let applied = 0, skipped = 0;
const report = [];

for (const entry of data) {
  const file = entry.file;
  if (!file || !Array.isArray(entry.edits)) continue;
  let src = fs.readFileSync(file, 'utf8');
  for (const e of entry.edits) {
    const { old, neu } = e;
    if (!old || neu == null) { skipped++; report.push(`SKIP[${file}] 空old/neu`); continue; }
    // 安全闸：old/neu 不得含结构行
    if (STRUCT.test(old) || STRUCT.test(neu)) { skipped++; report.push(`SKIP[${file}] 触及结构行: ${old.slice(0,30)}`); continue; }
    // neu 每个非空行必须是 C.n/C.mc/C.l 调用
    const neuBad = neu.split('\n').some(l => l.trim() && !CALL.test(l));
    if (neuBad) { skipped++; report.push(`SKIP[${file}] neu非法行: ${neu.slice(0,40)}`); continue; }
    // opts 保全闸：old 带 {cg/cgOff/fx/note/cast...} 则 neu 必须原样含之
    const optsM = old.match(/,\s*(\{.*\})\s*\)\s*;?\s*$/);
    if (optsM && !neu.includes(optsM[1])) { skipped++; report.push(`SKIP[${file}] 丢失opts: ${optsM[1].slice(0,40)}`); continue; }
    // old 必须恰好出现一次
    const idx = src.indexOf(old);
    if (idx < 0) { skipped++; report.push(`MISS[${file}] 找不到: ${old.slice(0,40)}`); continue; }
    if (src.indexOf(old, idx + 1) >= 0) { skipped++; report.push(`DUP[${file}] 多处匹配: ${old.slice(0,40)}`); continue; }
    src = src.slice(0, idx) + neu + src.slice(idx + old.length);
    applied++;
  }
  fs.writeFileSync(file, src);
}

console.log(`应用 ${applied} 条，跳过 ${skipped} 条`);
if (report.length) console.log('--- 跳过明细 ---\n' + report.join('\n'));
