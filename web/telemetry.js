/*
 * 《剑神三千年》前端埋点 SDK
 * 目标：数清独立访客、看每人玩到第几章/哪个节点、统计选了什么路线、在哪流失。
 *
 * 用法：engine.js 在关键节点调用 window.TLM.xxx()。
 * 传输：navigator.sendBeacon（关页面也能发出去，正好用来抓“最后停在哪” = 流失点）。
 * 隐私：浏览器端只生成一个随机 cid；真实IP由服务端取，落库前已加盐哈希。
 */
(function () {
  'use strict';

  var ENDPOINT = '/api/collect';
  var CID_KEY = 'jsg3_cid';

  // —— 浏览器端匿名ID：换IP（比如手机切网）也能认出同一个人 ——
  function uuid() {
    try {
      if (crypto && crypto.randomUUID) return crypto.randomUUID();
    } catch (e) {}
    return 'c-' + Date.now().toString(36) + '-' + Math.random().toString(36).slice(2, 10);
  }
  var cid;
  try {
    cid = localStorage.getItem(CID_KEY);
    if (!cid) { cid = uuid(); localStorage.setItem(CID_KEY, cid); }
  } catch (e) { cid = uuid(); }

  var step = 0;           // 本次会话推进计数
  var lastChapter = null; // 上一个章节标题，用来识别“进入新章”
  var disabled = false;   // 连续失败就停手，别打扰玩家

  function send(ev) {
    if (disabled || !ev || !ev.ev) return;
    ev.cid = cid;
    ev.step = step;
    var payload;
    try { payload = JSON.stringify(ev); } catch (e) { return; }
    try {
      if (navigator.sendBeacon) {
        // text/plain：避免 CORS 预检，且页面卸载时也能可靠送达
        var blob = new Blob([payload], { type: 'text/plain;charset=UTF-8' });
        if (navigator.sendBeacon(ENDPOINT, blob)) return;
      }
    } catch (e) {}
    // 兜底：keepalive fetch
    try {
      fetch(ENDPOINT, { method: 'POST', body: payload, keepalive: true, headers: { 'content-type': 'text/plain' } })
        .catch(function () {});
    } catch (e) { disabled = true; }
  }

  // 章节序号：用于排漏斗。STORY.chapters 按剧情顺序登记。
  function chapterIndex(title) {
    try {
      var arr = (window.STORY && window.STORY.chapters) || [];
      for (var i = 0; i < arr.length; i++) if (arr[i].title === title) return i;
    } catch (e) {}
    return null;
  }

  // 节流：progress 信标最多每 25 秒发一次，避免刷屏
  var lastProgressTs = 0;
  var PROGRESS_MS = 25000;

  window.TLM = {
    // 首次进入标题页：漏斗最顶端（多少人来过，但可能没点开始）
    visit: function () {
      send({
        ev: 'visit',
        ref: document.referrer || '',
        scr: (screen.width || 0) + 'x' + (screen.height || 0)
      });
    },

    // 开始一局（新游戏或继续）
    start: function (name, resumed) {
      step += 1;
      lastChapter = null;
      send({ ev: 'start', name: name || '', resumed: resumed ? 1 : 0 });
    },

    // 每推进一个剧情节点都调用：负责（a）识别进入新章 （b）节流上报当前进度
    node: function (nodeId, chapter, vars) {
      step += 1;
      // 进入新章 → 立刻发一条 chapter（漏斗里程碑，必报）
      if (chapter && chapter !== lastChapter) {
        lastChapter = chapter;
        send({ ev: 'chapter', ch: chapter, ci: chapterIndex(chapter), node: nodeId, vars: vars });
        lastProgressTs = nowMs();
        return;
      }
      // 章节内：节流上报 progress（用于细粒度定位“走到哪儿不玩了”）
      var t = nowMs();
      if (t - lastProgressTs >= PROGRESS_MS) {
        lastProgressTs = t;
        send({ ev: 'progress', ch: chapter, ci: chapterIndex(chapter), node: nodeId, vars: vars });
      }
    },

    // 玩家做出选择（路线！）
    choice: function (nodeId, chapter, ctx, took, alts) {
      step += 1;
      send({ ev: 'choice', ch: chapter, ci: chapterIndex(chapter), node: nodeId, ctx: ctx, took: took, alts: alts });
    },

    // 抵达结局
    ending: function (endId, chapter) {
      step += 1;
      send({ ev: 'ending', ending: endId, ch: chapter, ci: chapterIndex(chapter) });
    },

    // 离开页面前补一条当前节点 → 精确锁定流失点
    flush: function () {
      var s = window.JSG && window.JSG.state;
      if (!s || !s.node) return;
      var node = window.STORY && window.STORY.nodes[s.node];
      send({
        ev: 'progress',
        ch: node ? node.chapter : '',
        ci: node ? chapterIndex(node.chapter) : null,
        node: s.node,
        vars: s.vars,
        leave: 1
      });
    }
  };

  function nowMs() { return Date.now(); }

  // 页面进入即记一次访问；隐藏/卸载时补发流失信标
  if (document.readyState === 'complete' || document.readyState === 'interactive') {
    window.TLM.visit();
  } else {
    document.addEventListener('DOMContentLoaded', function () { window.TLM.visit(); });
  }
  document.addEventListener('visibilitychange', function () {
    if (document.visibilityState === 'hidden') window.TLM.flush();
  });
  window.addEventListener('pagehide', function () { window.TLM.flush(); });
})();
