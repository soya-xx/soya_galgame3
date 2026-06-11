/* 文风测试：AI味句式、行长、台词规范 */
import { STORY, fail, ok, finish } from './load.mjs';

const nodes = STORY.nodes;
const banned = [
  [/不是[^。！？，]{0,14}而是/, '「不是…而是…」句式'],
  [/本质上/, '「本质上」'],
  [/究极的|宏大叙事|赋能|闭环|抓手|颗粒度/, 'AI味词汇'],
  [/范式|涌现|阈值|上下文/, '技术黑话'],
  [/众所周知/, '「众所周知」'],
  [/在这个.{0,6}的(时代|世界)里/, '空泛开场套话']
];
let hits = 0;
for (const id of Object.keys(nodes)) {
  const t = nodes[id].t || '';
  for (const [re, name] of banned) {
    if (re.test(t)) { fail(`${id} 命中${name}: ${t}`); hits++; }
  }
  if (t.length > 48) { fail(`${id} 行过长(${t.length}>48): ${t.slice(0, 30)}…`); hits++; }
}
if (!hits) ok('无AI味句式，所有行长≤48字');

/* 结局文本同样检查 */
for (const [eid, def] of Object.entries(STORY.endings)) {
  for (const [re, name] of banned) {
    if (re.test(def.text || '') || re.test(def.intel || '')) fail(`结局 ${eid} 命中${name}`);
  }
}
ok('结局文案检查完成');
finish('style');
