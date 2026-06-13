/*
 * 埋点采集端  ——  POST /api/collect
 * 部署在 Cloudflare Pages Functions 上，能拿到真实访客IP和地理位置。
 *
 * 设计要点：
 *  - 只存“IP 加盐哈希”，不存原始IP（既能数独立访客，也更隐私友好）。
 *  - 没绑定 D1 数据库时静默放过，绝不报错拖垮游戏页面。
 *  - 用 text/plain 接收，配合前端 navigator.sendBeacon，避免 CORS 预检、且关页面也能发出去。
 */

const CHAPTER_COUNT = 7; // 序章+5章+尾声，用于过滤脏数据

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8' },
  });
}

// 取一段 SHA-256 十六进制，做访客指纹
async function hashHex(str) {
  const buf = await crypto.subtle.digest('SHA-256', new TextEncoder().encode(str));
  const arr = Array.from(new Uint8Array(buf));
  return arr.map((b) => b.toString(16).padStart(2, '0')).join('');
}

function clampStr(v, max) {
  if (v == null) return null;
  const s = String(v);
  return s.length > max ? s.slice(0, max) : s;
}

function pickEvents(body) {
  if (!body) return [];
  if (Array.isArray(body)) return body;
  if (Array.isArray(body.batch)) return body.batch;
  return [body];
}

export async function onRequestPost(context) {
  const { request, env } = context;

  // 解析请求体（sendBeacon 用 text/plain 发 JSON 文本）
  let body;
  try {
    body = JSON.parse(await request.text());
  } catch (e) {
    return json({ ok: false, err: 'bad json' }, 400);
  }
  const events = pickEvents(body).slice(0, 50); // 单次最多 50 条，防滥用
  if (!events.length) return new Response(null, { status: 204 });

  // 没配数据库就直接放过——游戏照常跑，只是没数据落库
  if (!env.DB) return new Response(null, { status: 204 });

  // 服务端补充：访客指纹 + 地理位置
  const ip = request.headers.get('CF-Connecting-IP') || '';
  const ua = request.headers.get('User-Agent') || '';
  const salt = env.TELEMETRY_SALT || 'soya-default-salt';
  const visitor = ip ? (await hashHex(ip + '|' + salt)).slice(0, 16) : null;
  const cf = request.cf || {};
  const country = cf.country || null;
  const city = cf.city || null;
  const now = Date.now();
  const day = new Date(now).toISOString().slice(0, 10);

  const stmt = env.DB.prepare(
    `INSERT INTO events
      (ts, day, visitor, cid, country, city, type, ch, ci, node, step, name, ctx, took, alts, ending, vars, ua, ref)
     VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)`
  );

  const rows = [];
  for (const e of events) {
    if (!e || typeof e !== 'object' || !e.ev) continue;
    let ci = Number.isInteger(e.ci) ? e.ci : null;
    if (ci != null && (ci < 0 || ci >= CHAPTER_COUNT)) ci = null;
    rows.push(
      stmt.bind(
        now,
        day,
        visitor,
        clampStr(e.cid, 64),
        country,
        city,
        clampStr(e.ev, 16),
        clampStr(e.ch, 64),
        ci,
        clampStr(e.node, 32),
        Number.isFinite(e.step) ? Math.floor(e.step) : null,
        clampStr(e.name, 32),
        clampStr(e.ctx, 120),
        clampStr(e.took, 120),
        e.alts ? clampStr(JSON.stringify(e.alts), 400) : null,
        clampStr(e.ending, 24),
        e.vars ? clampStr(JSON.stringify(e.vars), 120) : null,
        clampStr(ua, 200),
        clampStr(e.ref, 200)
      )
    );
  }

  if (!rows.length) return new Response(null, { status: 204 });

  try {
    await env.DB.batch(rows);
  } catch (err) {
    // 落库失败也不要影响玩家；吞掉错误
    return new Response(null, { status: 204 });
  }
  return new Response(null, { status: 204 });
}

// 防止有人 GET 探测时报 405 噪音
export async function onRequestGet() {
  return json({ ok: true, msg: 'collector alive' });
}
