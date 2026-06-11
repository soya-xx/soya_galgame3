/* 剧本 DSL：让章节文件用紧凑语法写节点，自动串链 next。 */
window.STORY = { nodes: {}, start: null, endings: {}, chapters: [] };

window.makeChapter = function (prefix, chapterTitle) {
  const S = window.STORY;
  if (chapterTitle) S.chapters.push({ prefix, title: chapterTitle });
  let seq = 0;
  let pendingId = null;
  let lastNode = null;
  let cur = { bg: null, music: null, cast: [] };

  function rid(name) { return prefix + '_' + name; }
  /* 绝对id：以已知章节前缀开头；否则视为本章短标签 */
  function resolve(t) { return /^(p|ch[0-9]|endx)_/.test(t) ? t : rid(t); }
  function nextId() {
    if (pendingId) { const v = pendingId; pendingId = null; return v; }
    seq += 1; return prefix + '_' + String(seq).padStart(3, '0');
  }
  function snapshot() { return cur.cast.map(e => ({ c: e.c, e: e.e, pos: e.pos })); }
  function parseCast(arr) {
    return (arr || []).map(s => {
      if (typeof s !== 'string') return s;
      let pos = null, rest = s;
      const at = s.indexOf('@'); if (at >= 0) { pos = s.slice(at + 1); rest = s.slice(0, at); }
      const [c, e] = rest.split(':');
      const def = (window.CHARS[c] || {});
      return { c, e: e || def.defaultExpr || null, pos: pos || def.pos || 'left' };
    });
  }
  function push(node) {
    if (S.nodes[node.id]) throw new Error('重复节点id: ' + node.id);
    if (lastNode && !lastNode.next && !lastNode.ch && !lastNode.end && !lastNode.auto) lastNode.next = node.id;
    S.nodes[node.id] = node;
    if (!S.start) S.start = node.id;
    lastNode = node;
    return node;
  }

  function line(sp, expr, text, opts) {
    opts = opts || {};
    if (opts.bg) cur.bg = opts.bg;
    if (opts.music) cur.music = opts.music;
    if (opts.cast) cur.cast = parseCast(opts.cast);
    const ch = window.CHARS[sp] || {};
    if (sp && !ch.narrator && !ch.player) {
      let entry = cur.cast.find(e => e.c === sp);
      if (!entry) { entry = { c: sp, e: expr || ch.defaultExpr || null, pos: ch.pos || 'left' }; cur.cast.push(entry); }
      if (expr) entry.e = expr;
    }
    const node = {
      id: nextId(), sp: sp || 'narr', t: text,
      bg: cur.bg, music: cur.music, cast: snapshot(),
      chapter: chapterTitle || ''
    };
    if (opts.cg) node.cg = opts.cg;
    if (opts.cgOff) node.cgOff = true;
    if (opts.fx) node.fx = opts.fx;
    if (opts.title) node.title = opts.title;
    if (opts.note) node.note = opts.note;
    if (opts.as) node.as = opts.as;
    return push(node);
  }

  const api = {
    id: rid,
    label(name) { pendingId = rid(name); },
    scene(opts) {
      if (opts.bg !== undefined) cur.bg = opts.bg;
      if (opts.music !== undefined) cur.music = opts.music;
      if (opts.cast !== undefined) cur.cast = parseCast(opts.cast);
    },
    l: line,
    n(text, opts) { return line('narr', null, text, opts); },
    mc(text, opts) { return line('mc', null, text, opts); },
    /* 选项挂在最后一个节点上：[标签, 目标(短名或全id), fx?, cond?] */
    choice(items) {
      if (!lastNode) throw new Error('choice 前没有节点');
      lastNode.ch = items.map(it => {
        const o = { t: it[0], go: resolve(it[1]) };
        if (it[2]) o.fx = it[2];
        if (it[3]) o.cond = it[3];
        return o;
      });
    },
    jump(target) { if (lastNode) lastNode.next = resolve(target); },
    /* 路由节点：按顺序匹配第一个满足条件的分支，不渲染 */
    router(rules, fallback) {
      return push({
        id: nextId(),
        auto: rules.map(r => ({ cond: r[0], go: resolve(r[1]) })),
        goElse: fallback ? resolve(fallback) : null
      });
    },
    /* 终止节点：进入结局 */
    theEnd(endId) { if (lastNode) lastNode.end = endId; },
    ending(endId, def) { S.endings[endId] = def; }
  };
  return api;
};

/* 条件判定：{min:{ban:10}, max:{jian:2}, flags:['x'], not:['y']} */
window.evalCond = function (cond, state) {
  if (!cond) return true;
  const v = state.vars, f = state.flags;
  if (cond.min) for (const k in cond.min) if ((v[k] || 0) < cond.min[k]) return false;
  if (cond.max) for (const k in cond.max) if ((v[k] || 0) > cond.max[k]) return false;
  if (cond.flags) for (const k of cond.flags) if (f.indexOf(k) < 0) return false;
  if (cond.not) for (const k of cond.not) if (f.indexOf(k) >= 0) return false;
  return true;
};

/* 效果：{jian:1, ban:-2, flag:'x', unflag:'y'} 或数组 */
window.applyFx = function (fx, state) {
  if (!fx) return;
  const list = Array.isArray(fx) ? fx : [fx];
  for (const e of list) {
    for (const k in e) {
      if (k === 'flag') { if (state.flags.indexOf(e[k]) < 0) state.flags.push(e[k]); }
      else if (k === 'unflag') { const i = state.flags.indexOf(e[k]); if (i >= 0) state.flags.splice(i, 1); }
      else state.vars[k] = (state.vars[k] || 0) + e[k];
    }
  }
};
