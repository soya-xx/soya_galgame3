/*
 * 统计看板数据端  ——  GET /api/stats?token=XXX
 * 把原始事件聚合成作者关心的几张表：独立访客 / 章节漏斗 / 流失点 / 选择分布 / 结局 / 逐访客路线。
 * 用 STATS_TOKEN 环境变量保护，别让外人看你的后台数据。
 */

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json; charset=utf-8', 'cache-control': 'no-store' },
  });
}

async function q(env, sql, ...binds) {
  const stmt = env.DB.prepare(sql);
  const r = await (binds.length ? stmt.bind(...binds) : stmt).all();
  return r.results || [];
}

export async function onRequestGet(context) {
  const { request, env } = context;

  if (!env.DB) return json({ ok: false, err: '尚未绑定 D1 数据库（绑定名应为 DB）' }, 503);
  if (!env.STATS_TOKEN) return json({ ok: false, err: '尚未设置 STATS_TOKEN 环境变量，后台未受保护，已拒绝访问' }, 503);

  const url = new URL(request.url);
  const auth = request.headers.get('Authorization') || '';
  const token = url.searchParams.get('token') || auth.replace(/^Bearer\s+/i, '');
  if (token !== env.STATS_TOKEN) return json({ ok: false, err: 'token 不对' }, 401);

  try {
    // —— 总览 ——
    const overview = (await q(env,
      `SELECT
         COUNT(DISTINCT visitor) AS visitors,
         COUNT(DISTINCT cid)     AS cids,
         COUNT(*)                AS events,
         MIN(ts) AS firstTs, MAX(ts) AS lastTs,
         SUM(CASE WHEN type='visit' THEN 1 ELSE 0 END) AS visits,
         COUNT(DISTINCT CASE WHEN type='start'  THEN cid     END) AS starts,
         COUNT(DISTINCT CASE WHEN type='ending' THEN visitor END) AS finishers
       FROM events`))[0] || {};

    // —— 国家/地区分布 ——
    const byCountry = await q(env,
      `SELECT country, COUNT(DISTINCT visitor) AS v
       FROM events WHERE country IS NOT NULL AND country<>''
       GROUP BY country ORDER BY v DESC LIMIT 30`);

    // —— 按天：独立访客 + 开始局数 ——
    const byDay = await q(env,
      `SELECT day,
         COUNT(DISTINCT visitor) AS visitors,
         COUNT(DISTINCT CASE WHEN type='start' THEN cid END) AS starts,
         COUNT(DISTINCT CASE WHEN type='ending' THEN visitor END) AS finishers
       FROM events WHERE day IS NOT NULL
       GROUP BY day ORDER BY day DESC LIMIT 60`);

    // —— 章节序号 → 标题 映射 ——
    const ciRows = await q(env,
      `SELECT ci, ch FROM events WHERE ci IS NOT NULL AND ch IS NOT NULL AND ch<>'' GROUP BY ci ORDER BY ci`);
    const ciLabel = {};
    ciRows.forEach((r) => { ciLabel[r.ci] = r.ch; });

    // —— 每个访客抵达的最深章节（漏斗用） ——
    const maxci = await q(env,
      `SELECT visitor, MAX(ci) AS mci
       FROM events WHERE ci IS NOT NULL AND visitor IS NOT NULL
       GROUP BY visitor`);
    const maxCi = ciRows.length ? ciRows[ciRows.length - 1].ci : 6;
    const funnel = [];
    for (let i = 0; i <= maxCi; i++) {
      const reached = maxci.filter((r) => r.mci >= i).length;
      funnel.push({ ci: i, label: ciLabel[i] || ('章节' + i), reached });
    }

    // —— 流失点：没看到结局的访客，最后停在哪个节点 ——
    const dropoff = await q(env,
      `SELECT node, ch, ci, COUNT(*) AS c FROM (
         SELECT e.visitor, e.node, e.ch, e.ci
         FROM events e
         JOIN (SELECT visitor, MAX(ts) AS mts FROM events WHERE node IS NOT NULL AND visitor IS NOT NULL GROUP BY visitor) m
           ON e.visitor = m.visitor AND e.ts = m.mts
         WHERE e.node IS NOT NULL
           AND e.visitor NOT IN (SELECT visitor FROM events WHERE type='ending' AND visitor IS NOT NULL)
         GROUP BY e.visitor
       ) GROUP BY node ORDER BY c DESC LIMIT 40`);

    // —— 选择分布（路线）：每个选择点各选项有多少人 ——
    const choices = await q(env,
      `SELECT node, ctx, took,
         COUNT(*) AS c, COUNT(DISTINCT visitor) AS v
       FROM events WHERE type='choice'
       GROUP BY node, ctx, took
       ORDER BY node, v DESC`);

    // —— 结局分布 ——
    const endings = await q(env,
      `SELECT ending, COUNT(*) AS c, COUNT(DISTINCT visitor) AS v
       FROM events WHERE type='ending' AND ending IS NOT NULL
       GROUP BY ending ORDER BY v DESC`);

    // —— 逐访客摘要（最近 300 人） ——
    const visitors = await q(env,
      `SELECT visitor,
         MAX(country) AS country,
         MAX(name) AS name,
         MAX(ci) AS mci,
         MIN(ts) AS firstTs, MAX(ts) AS lastTs,
         COUNT(DISTINCT CASE WHEN type='choice' THEN id END) AS choices,
         MAX(CASE WHEN type='ending' THEN ending END) AS ending
       FROM events WHERE visitor IS NOT NULL
       GROUP BY visitor
       ORDER BY lastTs DESC LIMIT 300`);

    // —— 逐访客选了什么（路线明细，最近 1500 条选择） ——
    const choiceRows = await q(env,
      `SELECT visitor, ctx, took, ts
       FROM events WHERE type='choice' AND visitor IS NOT NULL
       ORDER BY ts DESC LIMIT 1500`);
    const routeByVisitor = {};
    // 时间倒序取出，按访客分组后再正序，得到该访客的选择顺序
    for (let i = choiceRows.length - 1; i >= 0; i--) {
      const r = choiceRows[i];
      (routeByVisitor[r.visitor] = routeByVisitor[r.visitor] || []).push({ ctx: r.ctx, took: r.took });
    }
    visitors.forEach((v) => { v.route = routeByVisitor[v.visitor] || []; v.label = ciLabel[v.mci] || ''; });

    return json({
      ok: true,
      generatedTs: Date.now(),
      overview, byCountry, byDay, ciLabel, funnel, dropoff, choices, endings, visitors,
    });
  } catch (err) {
    return json({ ok: false, err: String(err && err.message || err) }, 500);
  }
}
