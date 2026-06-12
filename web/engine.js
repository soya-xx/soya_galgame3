/* 《剑神三千年》引擎 */
(function () {
  'use strict';
  const $ = id => document.getElementById(id);
  const STORY = window.STORY, CHARS = window.CHARS, MUSIC = window.MUSIC, BGS = window.BGS;
  const AMB = window.AMB || {}, SFX = window.SFX || {};

  /* ---------- 全局持久数据 ---------- */
  const GKEY = 'jsg3_global';
  const DEFAULT_SETTINGS = { speed: 60, auto: 50, bgm: 60, sfxVol: 70, bgmOn: false, sfxOn: false, skipall: true };
  let G = { read: {}, cg: {}, ends: {}, intel: {}, settings: Object.assign({}, DEFAULT_SETTINGS) };
  try {
    const raw = localStorage.getItem(GKEY);
    if (raw) { const saved = JSON.parse(raw); G = Object.assign(G, saved); G.settings = Object.assign({}, DEFAULT_SETTINGS, saved.settings || {}); }
  } catch (e) {}
  function saveG() { try { localStorage.setItem(GKEY, JSON.stringify(G)); } catch (e) {} }

  /* ---------- 运行状态 ---------- */
  let state = null;
  function freshState() {
    return { name: '林惊澜', node: null, vars: { jian: 0, ban: 0, truth: 0 }, flags: [], choices: [], history: [] };
  }

  /* ---------- 工具 ---------- */
  function fmt(t) { return (t || '').replace(/\{player\}/g, state ? state.name : '你'); }
  let toastTimer = null;
  function toast(msg) {
    const el = $('toast'); el.textContent = msg; el.classList.remove('hidden');
    clearTimeout(toastTimer); toastTimer = setTimeout(() => el.classList.add('hidden'), 1600);
  }

  /* ---------- 音乐 ---------- */
  let audio = null, curTrack = null, audioReady = false;
  function ensureAudio() {
    if (!audio) { audio = new Audio(); audio.loop = true; }
    audioReady = true;
    if (pendingTrack) { const t = pendingTrack; pendingTrack = null; playTrack(t); }
  }
  let pendingTrack = null, fadeTimer = null;
  function playTrack(key) {
    if (!key || !MUSIC[key] || !G.settings.bgmOn) { stopMusic(); return; }
    if (!audioReady) { pendingTrack = key; return; }
    if (curTrack === key) { audio.volume = G.settings.bgm / 100; return; }
    curTrack = key;
    const target = G.settings.bgm / 100;
    clearInterval(fadeTimer);
    const swap = () => {
      audio.src = MUSIC[key]; audio.volume = 0;
      audio.play().catch(() => {});
      fadeTimer = setInterval(() => {
        audio.volume = Math.min(target, audio.volume + 0.08);
        if (audio.volume >= target) clearInterval(fadeTimer);
      }, 90);
    };
    if (!audio.paused && audio.src) {
      fadeTimer = setInterval(() => {
        audio.volume = Math.max(0, audio.volume - 0.1);
        if (audio.volume <= 0) { clearInterval(fadeTimer); swap(); }
      }, 70);
    } else swap();
  }
  function stopMusic() {
    curTrack = null;
    if (!audio || audio.paused) return;
    clearInterval(fadeTimer);
    fadeTimer = setInterval(() => {
      audio.volume = Math.max(0, audio.volume - 0.1);
      if (audio.volume <= 0) { clearInterval(fadeTimer); audio.pause(); }
    }, 70);
  }
  /* ---------- 环境音 + 一次性音效（与音乐共用 bgmOn 开关） ---------- */
  let ambAudio = null, curAmb = null;
  function playAmbient(key) {
    if (!key || !AMB[key] || !G.settings.sfxOn) { stopAmbient(); return; }
    if (curAmb === key && ambAudio && !ambAudio.paused) return;
    curAmb = key;
    if (!ambAudio) { ambAudio = new Audio(); ambAudio.loop = true; }
    ambAudio.src = AMB[key]; ambAudio.volume = Math.min(0.55, (G.settings.sfxVol / 100) * 0.6);
    ambAudio.play().catch(() => {});
  }
  function stopAmbient() { curAmb = null; if (ambAudio && !ambAudio.paused) ambAudio.pause(); }
  function playSfx(key) {
    if (!key || !SFX[key] || !G.settings.sfxOn) return;
    const a = new Audio(SFX[key]); a.volume = Math.min(0.9, (G.settings.sfxVol / 100) * 0.95);
    a.play().catch(() => {});
  }

  function syncMusicBtn() {
    const b = $('music-toggle'); if (!b) return;
    b.classList.toggle('on', G.settings.bgmOn || G.settings.sfxOn);
    b.title = '声音设置';
  }
  function syncSoundPop() {
    const tb = $('sp-bgm-toggle'), ts = $('sp-sfx-toggle');
    if (tb) { tb.textContent = G.settings.bgmOn ? '开' : '关'; tb.classList.toggle('on', G.settings.bgmOn); }
    if (ts) { ts.textContent = G.settings.sfxOn ? '开' : '关'; ts.classList.toggle('on', G.settings.sfxOn); }
    if ($('sp-bgm')) $('sp-bgm').value = G.settings.bgm;
    if ($('sp-sfx')) $('sp-sfx').value = G.settings.sfxVol;
  }
  function toggleSoundPop() {
    const p = $('sound-pop'); if (!p) return;
    if (p.classList.contains('hidden')) { syncSoundPop(); p.classList.remove('hidden'); }
    else p.classList.add('hidden');
  }
  function closeSoundPop() { const p = $('sound-pop'); if (p) p.classList.add('hidden'); }
  function curNode() { return state && STORY.nodes[state.node]; }
  function toggleBgm() {
    G.settings.bgmOn = !G.settings.bgmOn; saveG(); syncMusicBtn(); syncSoundPop();
    if (G.settings.bgmOn) { ensureAudio(); const n = curNode(); playTrack(n ? n.music : null); }
    else stopMusic();
  }
  function toggleSfx() {
    G.settings.sfxOn = !G.settings.sfxOn; saveG(); syncMusicBtn(); syncSoundPop();
    if (G.settings.sfxOn) { ensureAudio(); const n = curNode(); playAmbient(n ? n.amb : null); }
    else stopAmbient();
  }

  /* ---------- 背景 ---------- */
  let bgFront = 'bg-a', curBg = null;
  function setBg(key) {
    if (key === curBg) return;
    curBg = key;
    const showEl = $(bgFront === 'bg-a' ? 'bg-b' : 'bg-a');
    const hideEl = $(bgFront);
    bgFront = showEl.id;
    showEl.classList.remove('bgfall');
    if (key && BGS[key]) {
      const img = new Image();
      img.onload = () => { showEl.style.backgroundImage = 'url(' + BGS[key] + ')'; };
      img.onerror = () => { showEl.style.backgroundImage = ''; showEl.classList.add('bgfall'); };
      img.src = BGS[key];
    } else { showEl.style.backgroundImage = ''; showEl.classList.add('bgfall'); }
    showEl.classList.add('show'); hideEl.classList.remove('show');
  }

  /* ---------- 立绘 ---------- */
  const portraitEls = {};
  /* 占位平衡：全尺寸角色先认领槽位，小体型（猫）用剩余槽位，避免重叠 */
  function balancePositions(cast) {
    const order = ['left', 'right', 'center'];
    const taken = {};
    const entries = (cast || []).filter(en => {
      const ch = CHARS[en.c]; return ch && !ch.narrator && !ch.player;
    });
    entries.filter(en => !CHARS[en.c].small).forEach(en => {
      let pos = en.pos || CHARS[en.c].pos || 'left';
      if (taken[pos]) pos = order.find(p => !taken[p]) || pos;
      taken[pos] = true; en._pos = pos;
    });
    entries.filter(en => CHARS[en.c].small).forEach(en => {
      let pos = en.pos || CHARS[en.c].pos || 'left';
      if (taken[pos]) pos = order.find(p => !taken[p]) || pos;
      taken[pos] = true; en._pos = pos;
    });
  }
  function renderCast(node) {
    const holder = $('sprites');
    balancePositions(node.cast);
    const present = {};
    (node.cast || []).forEach(en => { present[en.c] = en; });
    for (const cid in portraitEls) {
      if (!present[cid]) { portraitEls[cid].classList.remove('visible', 'speaking'); }
    }
    (node.cast || []).forEach(en => {
      const ch = CHARS[en.c]; if (!ch || ch.narrator || ch.player) return;
      let el = portraitEls[en.c];
      if (!el) {
        el = document.createElement('div');
        el.className = 'portrait' + (ch.small ? ' small' : '');
        const img = document.createElement('img');
        img.alt = ch.name;
        img.onerror = function () {
          img.style.display = 'none';
          if (!el.querySelector('.ph')) {
            const ph = document.createElement('div'); ph.className = 'ph';
            const sp = document.createElement('span'); sp.textContent = ch.name; ph.appendChild(sp);
            el.appendChild(ph);
          }
        };
        el.appendChild(img);
        holder.appendChild(el); portraitEls[en.c] = el;
      }
      el.classList.remove('pos-left', 'pos-center', 'pos-right');
      el.classList.add('pos-' + (en._pos || en.pos || ch.pos || 'left'));
      const img = el.querySelector('img');
      const src = (ch.sprites || {})[en.e] || Object.values(ch.sprites || {})[0];
      if (src && img.getAttribute('src') !== src) {
        img.style.display = ''; const ph = el.querySelector('.ph'); if (ph) ph.remove();
        img.src = src;
      }
      el.classList.add('visible');
      const speaking = node.sp === en.c;
      el.classList.toggle('speaking', speaking);
      el.classList.toggle('dim', !speaking && !!CHARS[node.sp] && !CHARS[node.sp].narrator);
      if (CHARS[node.sp] && CHARS[node.sp].narrator) el.classList.remove('dim');
    });
  }

  /* ---------- CG（粘滞：声明开启，cgOff/换背景关闭） ---------- */
  let curCg = null;
  function hideCg() { curCg = null; $('cg-layer').classList.add('hidden'); }
  function renderCg(node, bgChanged) {
    const layer = $('cg-layer'), img = $('cg-img'), fb = $('cg-fallback');
    if (node.cg) {
      if (curCg !== node.cg) {
        curCg = node.cg;
        G.cg[node.cg] = 1; saveG();
        img.classList.remove('hidden'); fb.classList.add('hidden');
        img.onerror = () => { img.classList.add('hidden'); fb.classList.remove('hidden'); fb.textContent = '— ' + (window.CG_TITLES[node.cg] || node.cg) + ' —'; };
        img.src = 'assets/cg/' + node.cg + '.png';
      }
      layer.classList.remove('hidden');
    } else if (node.cgOff || bgChanged) {
      hideCg();
    } else if (!curCg) {
      layer.classList.add('hidden');
    }
  }

  /* ---------- 打字机 ---------- */
  let typeTimer = null, typing = false, fullText = '';
  function typeText(text) {
    clearInterval(typeTimer); typing = true; fullText = text;
    const el = $('text'); el.textContent = '';
    $('advance-hint').classList.remove('on');
    const ms = 86 - (G.settings.speed * 0.78);
    if (ms <= 9) { el.textContent = text; typing = false; $('advance-hint').classList.add('on'); onTextDone(); return; }
    let i = 0;
    typeTimer = setInterval(() => {
      i += 1; el.textContent = text.slice(0, i);
      if (i >= text.length) { clearInterval(typeTimer); typing = false; $('advance-hint').classList.add('on'); onTextDone(); }
    }, ms);
  }
  function completeType() {
    clearInterval(typeTimer); typing = false;
    $('text').textContent = fullText; $('advance-hint').classList.add('on');
    onTextDone();
  }

  /* ---------- 自动 / 快进 ---------- */
  let autoOn = false, skipOn = false, autoTimer = null, skipTimer = null;
  function setAuto(v) {
    autoOn = v; $('btn-auto').classList.toggle('on', v);
    if (v) { setSkip(false); if (!typing) scheduleAuto(); } else clearTimeout(autoTimer);
  }
  function scheduleAuto() {
    clearTimeout(autoTimer);
    const node = STORY.nodes[state.node];
    if (!autoOn || !node || node.ch) return;
    /* 每行展现完停留2-5秒：按行长缩放，滑杆只在区间内微调 */
    const factor = 1.25 - (G.settings.auto / 200);
    const dwell = Math.min(5000, Math.max(2000, (1400 + fullText.length * 60) * factor));
    autoTimer = setTimeout(() => { if (autoOn && !typing) advance(); }, dwell);
  }
  function setSkip(v) {
    skipOn = v; $('btn-skip').classList.toggle('on', v);
    clearInterval(skipTimer);
    if (v) {
      setAuto(false);
      skipTimer = setInterval(() => {
        const node = STORY.nodes[state.node];
        if (!node || node.ch) { setSkip(false); return; }
        /* 快进跳过全部文本（含未读）；遇到选项分支才停 */
        completeType(); advance();
      }, 70);
    }
  }
  function onTextDone() { if (autoOn) scheduleAuto(); }

  /* ---------- 隐藏UI（截图） ---------- */
  let uiHidden = false;
  function setHideUI(v) {
    uiHidden = v;
    $('stage').classList.toggle('ui-hidden', v);
    if (v) toast('已隐藏界面 · 点击画面恢复');
  }

  /* ---------- 主流程 ---------- */
  let busy = false;
  function show(id) {
    let node = STORY.nodes[id];
    let guard = 0;
    while (node && node.auto && guard < 50) {
      let target = node.goElse;
      for (const r of node.auto) { if (window.evalCond(r.cond, state)) { target = r.go; break; } }
      node = STORY.nodes[target]; guard += 1;
    }
    if (!node) { toast('剧本断链：' + id); return; }
    state.node = node.id;
    G.read[node.id] = 1;
    if (node.fx) window.applyFx(node.fx, state);
    if (node.note) { G.intel[node.id] = node.note; saveG(); }
    if (node.title) showChapterCard(node.title);
    const bgChanged = node.bg !== curBg;
    setBg(node.bg);
    playTrack(node.music);
    playAmbient(node.amb);
    if (node.sfx) playSfx(node.sfx);
    renderCg(node, bgChanged);
    renderCast(node);
    const ch = CHARS[node.sp] || {};
    const plate = $('speaker');
    let nm = null;
    if (ch.player) nm = state.name;
    else if (!ch.narrator) nm = node.as || ch.name;
    if (nm) {
      plate.textContent = nm; plate.classList.remove('hidden');
      plate.classList.toggle('soya', ch.cls === 'soya');
    } else plate.classList.add('hidden');
    const text = fmt(node.t);
    state.history.push({ n: nm || '', t: text, cls: ch.cls || '' });
    if (state.history.length > 300) state.history.shift();
    hideChoices();
    typeText(text);
    if (node.end) pendingEnd = node.end; else pendingEnd = null;
    preloadAhead(node.id);
    saveG();
  }

  /* ---------- 图片预加载：沿剧情顺序提前各3张（CG/角色/背景） ---------- */
  const preloaded = new Set();
  function warm(url) { if (!url || preloaded.has(url)) return; preloaded.add(url); const im = new Image(); im.src = url; }
  function spriteUrl(c) { const ch = CHARS[c.c]; if (!ch || !ch.sprites) return null; return ch.sprites[c.e] || ch.sprites[ch.defaultExpr] || null; }
  function preloadAhead(fromId) {
    const bgs = [], cgs = [], sps = []; const seen = new Set(); let q = [fromId], steps = 0;
    while (q.length && steps < 80 && (bgs.length < 3 || cgs.length < 3 || sps.length < 3)) {
      const id = q.shift(); if (!id || seen.has(id)) continue; seen.add(id); steps += 1;
      const n = STORY.nodes[id]; if (!n) continue;
      if (n.bg && BGS[n.bg] && bgs.length < 3 && bgs.indexOf(BGS[n.bg]) < 0) bgs.push(BGS[n.bg]);
      if (n.cg && cgs.length < 3) { const u = 'assets/cg/' + n.cg + '.png'; if (cgs.indexOf(u) < 0) cgs.push(u); }
      if (n.cast) n.cast.forEach(c => { const u = spriteUrl(c); if (u && sps.length < 3 && sps.indexOf(u) < 0) sps.push(u); });
      if (n.next) q.push(n.next);
      if (n.ch) n.ch.forEach(c => q.push(c.go));
      if (n.auto) { n.auto.forEach(r => q.push(r.go)); if (n.goElse) q.push(n.goElse); }
    }
    bgs.concat(cgs, sps).forEach(warm);
  }

  let pendingEnd = null;
  function advance() {
    if (busy || !state) return;
    const node = STORY.nodes[state.node];
    if (!node) return;
    if (typing) { completeType(); return; }
    if (node.ch) { showChoices(node); return; }
    if (node.end) { showEnding(node.end); return; }
    if (node.next) show(node.next);
  }

  /* ---------- 选项 ---------- */
  function showChoices(node) {
    const wrap = $('choices'), box = $('choice-box');
    if (!wrap.classList.contains('hidden')) return;
    box.innerHTML = '';
    const avail = node.ch.filter(c => window.evalCond(c.cond, state));
    avail.forEach((c, i) => {
      const b = document.createElement('button');
      b.textContent = c.t;
      b.onclick = (ev) => { ev.stopPropagation(); pickChoice(node, c); };
      box.appendChild(b);
    });
    wrap.classList.remove('hidden');
    setAuto(false); setSkip(false);
  }
  function hideChoices() { $('choices').classList.add('hidden'); }
  function pickChoice(node, c) {
    state.choices.push({
      chapter: node.chapter || '', ctx: fmt(node.t).slice(0, 46),
      took: c.t, alts: node.ch.filter(x => x !== c).map(x => x.t)
    });
    if (c.fx) window.applyFx(c.fx, state);
    hideChoices();
    show(c.go);
  }

  /* ---------- 章节卡 ---------- */
  let cardTimer = null;
  function showChapterCard(text) {
    const card = $('chapter-card');
    $('chapter-card-text').textContent = text;
    card.classList.remove('hidden');
    clearTimeout(cardTimer);
    cardTimer = setTimeout(() => card.classList.add('hidden'), 2300);
    card.onclick = () => card.classList.add('hidden');
  }

  /* ---------- 结局 ---------- */
  function showEnding(endId) {
    const E = STORY.endings[endId];
    if (!E) { toast('未定义结局: ' + endId); return; }
    G.ends[endId] = 1;
    if (E.cg) G.cg[E.cg] = 1;
    if (E.intel) G.intel['end_' + endId] = E.intel;
    saveG();
    setAuto(false); setSkip(false); stopMusic();
    $('ending-kind').textContent = E.kind || '结局';
    $('ending-name').textContent = E.name;
    $('ending-text').textContent = fmt(E.text || '');
    $('ending-intel').textContent = E.intel ? '【情报入册】' + E.intel : '';
    $('ending-screen').classList.remove('hidden');
  }

  /* ---------- 历史 ---------- */
  function renderHistory() {
    const list = $('history-list'); list.innerHTML = '';
    state.history.slice(-200).forEach(h => {
      const d = document.createElement('div');
      d.className = 'hline' + (h.cls === 'soya' ? ' soya' : '');
      d.innerHTML = (h.n ? '<b>' + h.n + '</b>' : '') + h.t.replace(/</g, '&lt;');
      list.appendChild(d);
    });
    setTimeout(() => { list.scrollTop = list.scrollHeight; }, 30);
  }

  /* ---------- 存读档 ---------- */
  function snapshot() {
    const node = STORY.nodes[state.node] || {};
    return {
      ts: Date.now(), state: JSON.parse(JSON.stringify(state)),
      chapter: node.chapter || '', pv: fmt(node.t || '').slice(0, 30)
    };
  }
  function writeSave(key, snap) { try { localStorage.setItem('jsg3_save_' + key, JSON.stringify(snap)); } catch (e) { toast('存档失败'); } }
  function readSave(key) { try { const r = localStorage.getItem('jsg3_save_' + key); return r ? JSON.parse(r) : null; } catch (e) { return null; } }
  function loadSnap(snap) {
    state = snap.state;
    hideCg();
    enterGame();
    show(state.node);
    toast('已读取');
  }
  function quickSave() { if (!state) return; writeSave('q', snapshot()); toast('快速存档完成'); }
  function quickLoad() { const s = readSave('q'); if (s) loadSnap(s); else toast('没有快速存档'); }
  let savesMode = 'save';
  function openSaves(mode) {
    savesMode = mode;
    $('saves-title').textContent = mode === 'save' ? '存档' : '读档';
    const holder = $('save-slots'); holder.innerHTML = '';
    const qs = readSave('q');
    const mk = (key, label, snap) => {
      const d = document.createElement('div');
      d.className = 'slot' + (snap ? '' : ' empty');
      const time = snap ? new Date(snap.ts).toLocaleString('zh-CN', { hour12: false }) : '—— 空 ——';
      d.innerHTML = '<span class="no">' + label + '</span><span class="meta">' +
        (snap ? snap.state.name + ' · ' + (snap.chapter || '') + ' · ' + time + '<span class="pv">' + (snap.pv || '') + '</span>' : time) + '</span>';
      if (snap && key !== 'q') {
        const del = document.createElement('button'); del.className = 'del'; del.textContent = '删除';
        del.onclick = (ev) => { ev.stopPropagation(); localStorage.removeItem('jsg3_save_' + key); openSaves(savesMode); };
        d.appendChild(del);
      }
      d.onclick = () => {
        if (savesMode === 'save') {
          if (key === 'q') { toast('快存请用对话框按钮或F5'); return; }
          if (!state) { toast('没有进行中的剧情'); return; }
          writeSave(key, snapshot()); openSaves('save'); toast('已存档');
        } else { if (snap) { closeAll(); loadSnap(snap); } }
      };
      holder.appendChild(d);
    };
    mk('q', '快存', qs);
    for (let i = 1; i <= 9; i++) mk(String(i), '槽 ' + i, readSave(String(i)));
    openOverlay('saves');
  }
  function latestSave() {
    let best = null;
    ['q', '1', '2', '3', '4', '5', '6', '7', '8', '9'].forEach(k => {
      const s = readSave(k); if (s && (!best || s.ts > best.ts)) best = s;
    });
    return best;
  }

  /* ---------- 分支·结局·情报 ---------- */
  function renderFlow() {
    const r = $('flow-routes'); r.innerHTML = '';
    if (!state || !state.choices.length) {
      r.innerHTML = '<div class="fitem">本回还没有做出过选择。</div>';
    } else {
      let lastCh = null;
      state.choices.forEach(c => {
        if (c.chapter !== lastCh) {
          lastCh = c.chapter;
          const h = document.createElement('div'); h.className = 'fchap'; h.textContent = c.chapter || '——';
          r.appendChild(h);
        }
        const d = document.createElement('div'); d.className = 'fitem';
        d.innerHTML = '<span class="ctx">' + c.ctx.replace(/</g, '&lt;') + '</span>' +
          '<span class="took">→ ' + c.took + '</span>' +
          c.alts.map(a => '<span class="alt">未选：' + a + '</span>').join('');
        r.appendChild(d);
      });
    }
    const e = $('flow-ends'); e.innerHTML = '';
    const order = ['END_TRUE', 'END_ALLY', 'END_ASH', 'END_SLEEP', 'END_DEMON', 'END_LEAVE', 'END_REFUSE', 'END_ARENA'];
    order.forEach(id => {
      const E = STORY.endings[id]; if (!E) return;
      const got = !!G.ends[id];
      const d = document.createElement('div'); d.className = 'eitem ' + (got ? 'got' : 'locked');
      d.innerHTML = '<span class="mark">' + (got ? '◆' : '◇') + '</span><span>' +
        (got ? E.kind + '·' + E.name : '？？？ —— ' + (E.hint || '尚未抵达')) + '</span>';
      e.appendChild(d);
    });
    const it = $('flow-intel'); it.innerHTML = '';
    const keys = Object.keys(G.intel);
    if (!keys.length) it.innerHTML = '<div class="fitem">还没有收集到情报。坏结局也会留下线索。</div>';
    keys.forEach(k => {
      const d = document.createElement('div'); d.className = 'fitem intel'; d.textContent = '◈ ' + G.intel[k];
      it.appendChild(d);
    });
  }

  /* ---------- CG鉴赏 ---------- */
  function renderGallery() {
    const grid = $('gallery-grid'); grid.innerHTML = '';
    Object.keys(window.CG_TITLES).forEach(key => {
      const cell = document.createElement('div'); cell.className = 'gcell';
      if (G.cg[key]) {
        const img = document.createElement('img');
        img.src = 'assets/cg/' + key + '.png';
        img.onerror = () => { img.remove(); cell.textContent = window.CG_TITLES[key]; cell.style.fontSize = '13px'; cell.style.color = '#9a937f'; };
        cell.appendChild(img);
        cell.onclick = () => { $('gallery-img').src = 'assets/cg/' + key + '.png'; $('gallery-view').classList.remove('hidden'); };
      } else cell.textContent = '？';
      grid.appendChild(cell);
    });
  }

  /* ---------- 浮层管理 ---------- */
  const overlays = ['history', 'saves', 'settings', 'flow', 'gallery', 'name-modal'];
  function openOverlay(id) { closeAll(); $(id).classList.remove('hidden'); }
  function closeAll() { overlays.forEach(o => $(o).classList.add('hidden')); $('gallery-view').classList.add('hidden'); }
  function anyOverlayOpen() { return overlays.some(o => !$(o).classList.contains('hidden')); }

  /* ---------- 画面切换 ---------- */
  function enterGame() {
    $('title-screen').classList.add('hidden');
    $('ending-screen').classList.add('hidden');
    $('stage').classList.remove('hidden');
    closeAll();
  }
  function enterTitle() {
    setAuto(false); setSkip(false); stopMusic();
    $('stage').classList.add('hidden');
    $('ending-screen').classList.add('hidden');
    closeAll();
    $('title-screen').classList.remove('hidden');
    $('btn-continue').disabled = !latestSave();
    const tk = new Image();
    tk.onload = () => { $('title-bg').style.setProperty('--titleimg', 'url(assets/ui/title_keyvisual.png)'); };
    tk.src = 'assets/ui/title_keyvisual.png';
  }
  function newGame() {
    $('name-input').value = '林惊澜';
    openOverlay('name-modal');
    setTimeout(() => $('name-input').focus(), 60);
  }
  function startStory() {
    const v = $('name-input').value.trim().replace(/\s+/g, '');
    if (!v) { toast('总得有个名字'); return; }
    if (v.length > 8) { toast('名字太长了'); return; }
    state = freshState(); state.name = v;
    hideCg();
    enterGame();
    show(STORY.start);
  }

  /* ---------- 事件绑定 ---------- */
  function bind() {
    $('stage').addEventListener('click', (ev) => {
      if (ev.target.closest('#vn-bar') || ev.target.closest('#choices') || ev.target.closest('#chapter-card') || ev.target.closest('#music-toggle') || ev.target.closest('#sound-pop')) return;
      ensureAudio();
      if (!$('sound-pop').classList.contains('hidden')) { closeSoundPop(); return; }
      if (uiHidden) { setHideUI(false); return; }
      if (skipOn) { setSkip(false); return; }
      advance();
    });
    $('stage').addEventListener('wheel', (ev) => {
      if (anyOverlayOpen()) return;
      if (ev.deltaY < 0) { renderHistory(); openOverlay('history'); }
    }, { passive: true });

    $('vn-bar').addEventListener('click', (ev) => {
      const b = ev.target.closest('button'); if (!b) return;
      ensureAudio();
      const act = b.dataset.act;
      if (act === 'history') { renderHistory(); openOverlay('history'); }
      if (act === 'auto') setAuto(!autoOn);
      if (act === 'skip') setSkip(!skipOn);
      if (act === 'flow') { renderFlow(); openOverlay('flow'); }
      if (act === 'qsave') quickSave();
      if (act === 'qload') quickLoad();
      if (act === 'save') openSaves('save');
      if (act === 'load') openSaves('load');
      if (act === 'settings') openOverlay('settings');
      if (act === 'hideui') setHideUI(true);
      if (act === 'title') { if (confirm('回到标题？未保存的进度会丢失。')) enterTitle(); }
    });

    $('title-menu').addEventListener('click', (ev) => {
      const b = ev.target.closest('button'); if (!b) return;
      ensureAudio();
      const act = b.dataset.act;
      if (act === 'new') newGame();
      if (act === 'continue') { const s = latestSave(); if (s) loadSnap(s); }
      if (act === 'load') { savesMode = 'load'; openSaves('load'); }
      if (act === 'flow') { renderFlow(); openOverlay('flow'); }
      if (act === 'gallery') { renderGallery(); openOverlay('gallery'); }
      if (act === 'settings') openOverlay('settings');
    });

    $('name-ok').onclick = startStory;
    $('name-cancel').onclick = () => { closeAll(); };
    $('name-input').addEventListener('keydown', (ev) => { if (ev.key === 'Enter') startStory(); });

    document.querySelectorAll('[data-close]').forEach(b => { b.onclick = () => closeAll(); });
    $('gallery-view').onclick = () => $('gallery-view').classList.add('hidden');

    document.querySelectorAll('.tab').forEach(t => {
      t.onclick = () => {
        document.querySelectorAll('.tab').forEach(x => x.classList.remove('active'));
        t.classList.add('active');
        ['routes', 'ends', 'intel'].forEach(p => $('flow-' + p).classList.toggle('hidden', t.dataset.tab !== p));
      };
    });

    $('ending-title').onclick = enterTitle;
    $('ending-flow').onclick = () => { renderFlow(); openOverlay('flow'); };

    syncMusicBtn();
    syncSoundPop();
    $('music-toggle').onclick = (ev) => { ev.stopPropagation(); ensureAudio(); toggleSoundPop(); };
    $('sp-bgm-toggle').onclick = (ev) => { ev.stopPropagation(); ensureAudio(); toggleBgm(); };
    $('sp-sfx-toggle').onclick = (ev) => { ev.stopPropagation(); ensureAudio(); toggleSfx(); };
    $('sp-bgm').oninput = e => { G.settings.bgm = +e.target.value; if (audio) audio.volume = G.settings.bgm / 100; saveG(); };
    $('sp-sfx').oninput = e => {
      G.settings.sfxVol = +e.target.value;
      if (ambAudio) ambAudio.volume = Math.min(0.55, (G.settings.sfxVol / 100) * 0.6);
      saveG();
    };
    $('sound-pop').addEventListener('click', ev => ev.stopPropagation());

    $('set-speed').value = G.settings.speed;
    $('set-auto').value = G.settings.auto;
    $('set-bgm').value = G.settings.bgm;
    $('set-sfx').value = G.settings.sfxVol;
    $('set-speed').oninput = e => { G.settings.speed = +e.target.value; saveG(); };
    $('set-auto').oninput = e => { G.settings.auto = +e.target.value; saveG(); };
    $('set-bgm').oninput = e => { G.settings.bgm = +e.target.value; if (audio) audio.volume = G.settings.bgm / 100; syncSoundPop(); saveG(); };
    $('set-sfx').oninput = e => { G.settings.sfxVol = +e.target.value; if (ambAudio) ambAudio.volume = Math.min(0.55, (G.settings.sfxVol / 100) * 0.6); syncSoundPop(); saveG(); };

    document.addEventListener('keydown', (ev) => {
      if ($('name-modal') && !$('name-modal').classList.contains('hidden')) return;
      if (ev.key === 'Escape') { closeAll(); return; }
      if ($('stage').classList.contains('hidden')) return;
      if (anyOverlayOpen()) return;
      ensureAudio();
      if (ev.key === ' ' || ev.key === 'Enter') { ev.preventDefault(); advance(); }
      if (ev.key === 'Control') { if (!skipOn) setSkip(true); }
      if (ev.key.toLowerCase() === 'a') setAuto(!autoOn);
      if (ev.key.toLowerCase() === 'h') { renderHistory(); openOverlay('history'); }
      if (ev.key === 'F5') { ev.preventDefault(); quickSave(); }
      if (ev.key === 'F9') { ev.preventDefault(); quickLoad(); }
      const node = state && STORY.nodes[state.node];
      if (node && node.ch && !$('choices').classList.contains('hidden')) {
        const idx = parseInt(ev.key, 10);
        if (idx >= 1) {
          const btns = $('choice-box').querySelectorAll('button');
          if (btns[idx - 1]) btns[idx - 1].click();
        }
      }
    });
    document.addEventListener('keyup', (ev) => { if (ev.key === 'Control') setSkip(false); });
  }

  /* ---------- 启动 ---------- */
  window.JSG = {
    get state() { return state; }, show, advance, startStory,
    setName(n) { if (state) state.name = n; }, freshState,
    _internals: { snapshot, loadSnap }
  };
  bind();
  enterTitle();
})();
