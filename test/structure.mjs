/* 结构测试：图完整性、可达性、立绘映射、CG配额、结局路线模拟 */
import { STORY, CHARS, MUSIC, BGS, CG_TITLES, evalCond, applyFx, fail, ok, finish } from './load.mjs';

const nodes = STORY.nodes;
const ids = Object.keys(nodes);
console.log(`节点总数: ${ids.length}`);
if (ids.length < 700) fail(`节点数过少 (${ids.length} < 700)，体量不达标`);

/* 1. 链接完整性 */
let broken = 0;
for (const id of ids) {
  const n = nodes[id];
  const targets = [];
  if (n.next) targets.push(n.next);
  if (n.ch) n.ch.forEach(c => targets.push(c.go));
  if (n.auto) { n.auto.forEach(a => targets.push(a.go)); if (n.goElse) targets.push(n.goElse); }
  for (const t of targets) if (!nodes[t]) { fail(`${id} → 不存在的节点 ${t}`); broken++; }
  if (!n.next && !n.ch && !n.end && !n.auto) fail(`${id} 是死胡同（无 next/ch/end/auto）`);
}
if (!broken) ok('所有跳转目标存在，无断链');

/* 2. 可达性（无条件图） */
const seen = new Set();
const queue = [STORY.start];
while (queue.length) {
  const id = queue.pop();
  if (!id || seen.has(id)) continue;
  seen.add(id);
  const n = nodes[id]; if (!n) continue;
  if (n.next) queue.push(n.next);
  if (n.ch) n.ch.forEach(c => queue.push(c.go));
  if (n.auto) { n.auto.forEach(a => queue.push(a.go)); if (n.goElse) queue.push(n.goElse); }
}
const orphans = ids.filter(i => !seen.has(i));
if (orphans.length) fail(`不可达节点 ${orphans.length} 个: ${orphans.slice(0, 8).join(', ')}`);
else ok(`全部 ${ids.length} 个节点从起点可达`);

/* 3. 立绘映射：所有具名发言人与在场角色都有立绘 */
let spriteIssues = 0;
for (const id of ids) {
  const n = nodes[id];
  if (n.auto) continue;
  const ch = CHARS[n.sp];
  if (!ch) { fail(`${id} 未知发言人 ${n.sp}`); spriteIssues++; continue; }
  if (!ch.narrator && !ch.player && !ch.sprites) { fail(`${id} 发言人 ${n.sp} 无立绘`); spriteIssues++; }
  for (const en of (n.cast || [])) {
    const c = CHARS[en.c];
    if (!c) { fail(`${id} 在场角色未知 ${en.c}`); spriteIssues++; continue; }
    if (en.e && !(c.sprites || {})[en.e]) { fail(`${id} 角色 ${en.c} 缺表情 ${en.e}`); spriteIssues++; }
  }
  if (n.bg && !BGS[n.bg]) { fail(`${id} 未知背景 ${n.bg}`); }
  if (n.music && !MUSIC[n.music]) { fail(`${id} 未知音乐 ${n.music}`); }
  if (n.cg && !CG_TITLES[n.cg]) { fail(`${id} CG ${n.cg} 不在标题表`); }
}
if (!spriteIssues) ok('具名发言人/在场角色全部有立绘与表情');

/* 4. 每章 CG ≥ 3 */
const byChap = {};
for (const id of ids) {
  const n = nodes[id];
  if (!n.cg) continue;
  const c = n.chapter || '?';
  (byChap[c] = byChap[c] || new Set()).add(n.cg);
}
for (const c of Object.keys(byChap)) {
  const cnt = byChap[c].size;
  if (c !== '尾声' && cnt < 3) fail(`章节「${c}」CG 只有 ${cnt} 张 (<3)`);
}
ok('章节CG配额: ' + Object.entries(byChap).map(([c, s]) => `${c}=${s.size}`).join(' / '));

/* 5. 选项规范：≥2项、文本≤10字、无重复 */
let chCount = 0;
for (const id of ids) {
  const n = nodes[id];
  if (!n.ch) continue;
  chCount++;
  if (n.ch.length < 2) fail(`${id} 选项不足2个`);
  const labels = n.ch.map(c => c.t);
  if (new Set(labels).size !== labels.length) fail(`${id} 选项重复`);
  labels.forEach(l => { if (l.length > 10) fail(`${id} 选项过长: ${l}`); });
}
if (chCount < 12) fail(`选择点过少: ${chCount} < 12`);
else ok(`选择点 ${chCount} 处`);

/* 6. 结局注册与情报奖励 */
const ENDS = ['END_TRUE', 'END_ALLY', 'END_ASH', 'END_SLEEP', 'END_DEMON', 'END_LEAVE', 'END_REFUSE', 'END_ARENA'];
for (const e of ENDS) {
  const def = STORY.endings[e];
  if (!def) { fail(`结局 ${e} 未注册`); continue; }
  if (!def.intel) fail(`结局 ${e} 缺情报奖励`);
  if (!def.hint) fail(`结局 ${e} 缺解锁提示`);
  const node = ids.find(i => nodes[i].end === e);
  if (!node) fail(`结局 ${e} 没有终止节点`);
  else if (!seen.has(node)) fail(`结局 ${e} 终止节点不可达`);
}
ok('8个结局全部注册且带情报奖励');

/* 7. 路线模拟：用脚本化选择走通每个结局 */
function simulate(plan, expectEnd, maxSteps = 4000) {
  const state = { vars: { jian: 0, ban: 0, truth: 0 }, flags: [] };
  let cur = STORY.start, steps = 0, picks = [...plan];
  while (steps++ < maxSteps) {
    const n = nodes[cur];
    if (!n) return `断链于 ${cur}`;
    if (n.auto) {
      let target = n.goElse;
      for (const r of n.auto) if (evalCond(r.cond, state)) { target = r.go; break; }
      if (!target) return `路由 ${cur} 无出口`;
      cur = target; continue;
    }
    if (n.fx) applyFx(n.fx, state);
    if (n.end) return n.end === expectEnd ? 'OK' : `到达 ${n.end}，期望 ${expectEnd}`;
    if (n.ch) {
      const avail = n.ch.filter(c => evalCond(c.cond, state));
      if (!avail.length) return `${cur} 无可用选项`;
      const want = picks.shift();
      let pick = avail.find(c => c.t === want);
      if (want && !pick) return `${cur} 找不到选项「${want}」(可用: ${avail.map(c => c.t).join('/')})`;
      if (!pick) pick = avail[0];
      if (pick.fx) applyFx(pick.fx, state);
      cur = pick.go; continue;
    }
    cur = n.next;
  }
  return '超出步数上限';
}

const routes = [
  ['END_REFUSE', ['让它进来', '让她走', '还是不签']],
  ['END_ARENA', ['让它进来', '签', '接', '买鱼干', '装侥幸', '盯着看', '摸耳朵', '认输']],
  ['END_TRUE', ['让它进来', '问清楚再签', '接', '买鱼干', '不解释', '盯着看', '摸耳朵', '藏拙', '钓他抬价', '立刻转身', '末座', '救', '长老认错人了', '摊牌', '周旋', '为她活', '直取飞升台', '斩契约']],
  ['END_ALLY', ['让它进来', '问清楚再签', '接', '买鱼干', '不解释', '移开眼', '摸耳朵', '藏拙', '钓他抬价', '愣在原地', '不去', '救', '是', '封印面板', '周旋', '为她活', '直取飞升台', '斩契约']],
  ['END_ASH', ['让它进来', '签', '接', '攒着买剑', '装侥幸', '盯着看', '忍住', '锋芒', '十倍碾过去', '立刻转身', '上座', '转身走', '长老认错人了', '装不知道', '拔剑', '为她活', '直取飞升台', '烧契约']],
  ['END_SLEEP', ['让它进来', '签', '接', '攒着买剑', '装侥幸', '盯着看', '忍住', '锋芒', '十倍碾过去', '立刻转身', '上座', '转身走', '长老认错人了', '装不知道', '拔剑', '为她活', '直取飞升台', '斩契约']],
  ['END_DEMON', ['关窗', '签', '接', '攒着买剑', '不解释', '盯着看', '忍住', '锋芒', '十倍碾过去', '愣在原地', '上座', '转身走', '长老认错人了', '装不知道', '拔剑', '为恨活']],
  ['END_LEAVE', ['让它进来', '问清楚再签', '接', '买鱼干', '装侥幸', '移开眼', '摸耳朵', '藏拙', '钓他抬价', '愣在原地', '不去', '救', '是', '封印面板', '周旋', '为她活', '带她走，不打了']]
];
for (const [end, plan] of routes) {
  const r = simulate(plan, end);
  if (r === 'OK') ok(`路线模拟 ${end} 通过`);
  else fail(`路线模拟 ${end} 失败: ${r}`);
}

/* 8. 玩家名插值存在 */
const usesName = ids.filter(i => (nodes[i].t || '').includes('{player}')).length;
if (usesName < 10) fail(`{player} 使用过少: ${usesName}`);
else ok(`{player} 插值 ${usesName} 处`);

/* 9. cond 引用的 flag 必须有来源 */
const setFlags = new Set();
for (const id of ids) {
  const n = nodes[id];
  const fxs = [];
  if (n.fx) fxs.push(n.fx);
  if (n.ch) n.ch.forEach(c => c.fx && fxs.push(c.fx));
  for (const fx of fxs.flat()) if (fx && fx.flag) setFlags.add(fx.flag);
}
const condFlags = new Set();
for (const id of ids) {
  const n = nodes[id];
  const conds = [];
  if (n.ch) n.ch.forEach(c => c.cond && conds.push(c.cond));
  if (n.auto) n.auto.forEach(a => a.cond && conds.push(a.cond));
  for (const c of conds) (c.flags || []).concat(c.not || []).forEach(f => condFlags.add(f));
}
for (const f of condFlags) if (!setFlags.has(f)) fail(`条件引用了从未设置的flag: ${f}`);
ok(`flag 来源检查完成 (${setFlags.size} 个flag)`);

finish('structure');
