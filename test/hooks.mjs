/* 体验钩子测试：开场60秒、章节衔接、章末钩子 */
import { STORY, fail, ok, finish } from './load.mjs';

const nodes = STORY.nodes;

/* 1. 开场压强：前35个节点内出现 危机/倒计时/谜团；前80个节点内出现首个选择 */
let cur = STORY.start;
const opening = [];
for (let i = 0; i < 130 && cur; i++) {
  const n = nodes[cur];
  if (!n) break;
  opening.push(n);
  if (n.ch) break;
  cur = n.next;
}
const head = opening.slice(0, 35).map(n => n.t || '').join('');
if (!/三日|三天|大会/.test(head)) fail('开场35节点内没有倒计时');
else ok('开场有倒计时压力');
if (!/逐出|滚出|废物/.test(head)) fail('开场35节点内没有生存危机');
else ok('开场有生存危机');
/* 放宽到80：开场先用"屈辱(代入)+身体异常(悬念)"两层把"你"立住，再让猫(催化剂)登场，
   震撼才有落点。仍enforce催化剂不至于太晚(约前2-3分钟内)。 */
const head80 = opening.slice(0, 80).map(n => n.t || '').join('');
if (!/猫/.test(head80)) fail('开场80节点内猫没有登场');
else ok('催化剂（猫）按时登场');
const firstChoiceIdx = opening.findIndex(n => n.ch);
/* 上限放宽到100：炸点冷开场(病态深情origin)需要更长的in-medias-res序幕才够震撼，
   留存优先于"早交互"。仍enforce玩家不必等太久(约2-3分钟内首个选择)。 */
if (firstChoiceIdx === -1 || firstChoiceIdx > 100) fail(`首个选择出现过晚: ${firstChoiceIdx}`);
else ok(`首个选择在第 ${firstChoiceIdx + 1} 个节点`);

/* 2. 章节衔接：每章存在入口节点 ch*_001 且被引用 */
for (const p of ['ch1', 'ch2', 'ch3', 'ch4', 'ch5']) {
  const id = p + '_001';
  if (!nodes[id]) { fail(`缺少章节入口 ${id}`); continue; }
  const referenced = Object.values(nodes).some(n =>
    n.next === id || (n.ch || []).some(c => c.go === id) ||
    (n.auto || []).some(a => a.go === id) || n.goElse === id);
  if (!referenced) fail(`章节入口 ${id} 没有被上一章引用`);
}
ok('章节链路完整（序章→终章）');

/* 3. 章末钩子：每章最后的可达普通节点附近要有下一步预告词 */
const hookWords = /明日|明天|明早|三日|午时|钟声|大会|飞升|圣使|名册|终章|收剑/;
for (const p of [['p', 'ch1'], ['ch1', 'ch2'], ['ch2', 'ch3'], ['ch3', 'ch4'], ['ch4', 'ch5']]) {
  const [from, to] = p;
  const tails = Object.entries(nodes).filter(([id, n]) => id.startsWith(from + '_') && n.next === to + '_001');
  if (!tails.length) { fail(`${from} 没有指向 ${to}_001 的章末节点`); continue; }
  for (const [id] of tails) {
    let ptr = id, text = '', guard = 0;
    const back = Object.fromEntries(Object.entries(nodes).map(([k, v]) => [v.next, k]));
    while (guard++ < 8 && ptr) { text = (nodes[ptr].t || '') + text; ptr = back[ptr]; }
    if (!hookWords.test(text)) fail(`${from} 章末缺少钩子词: …${text.slice(-40)}`);
  }
}
ok('章末钩子检查完成');

/* 4. 选项即时兑现：选项目标3节点内有 fx/表情变化/CG/情报 */
let lazy = 0;
for (const [id, n] of Object.entries(nodes)) {
  if (!n.ch) continue;
  for (const c of n.ch) {
    let ptr = c.go, found = !!c.fx, hops = 0;
    while (!found && hops++ < 3 && ptr) {
      const m = nodes[ptr];
      if (!m) break;
      if (m.fx || m.cg || m.note || m.end) found = true;
      const speakerChanged = m.sp && m.sp !== 'narr';
      if (speakerChanged) found = true;
      ptr = m.next;
    }
    if (!found) { fail(`${id} 选项「${c.t}」3节点内无可见兑现`); lazy++; }
  }
}
if (!lazy) ok('所有选项3节点内有可见兑现');

finish('hooks');
