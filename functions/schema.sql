-- 《剑神三千年》埋点数据库（Cloudflare D1 / SQLite）
-- 一张原始事件流水表，所有看板统计都从它聚合而来。
-- 建表命令见 tools/telemetry/setup.sh 或 design/telemetry-setup.md

CREATE TABLE IF NOT EXISTS events (
  id        INTEGER PRIMARY KEY AUTOINCREMENT,
  ts        INTEGER NOT NULL,   -- 服务端收到的时间（epoch 毫秒）
  day       TEXT,               -- YYYY-MM-DD（UTC），方便按天统计
  visitor   TEXT,               -- 访客指纹：CF-Connecting-IP 加盐哈希（≈“独立IP”，不存原始IP）
  cid       TEXT,               -- 浏览器端随机ID（localStorage，跨IP仍能认人）
  country   TEXT,               -- 来访国家/地区（CF 提供）
  city      TEXT,               -- 来访城市（CF 提供，可能为空）
  type      TEXT NOT NULL,      -- 事件类型：visit|start|chapter|progress|choice|ending
  ch        TEXT,               -- 章节标题，如“第一章·扮猪吃虎”
  ci        INTEGER,            -- 章节序号（0=序章…6=尾声），用来排漏斗
  node      TEXT,               -- 当前剧情节点id，如 ch1_007（用于定位流失点）
  step      INTEGER,            -- 本次会话内的推进计数（单调递增）
  name      TEXT,               -- 玩家给主角起的名字
  ctx       TEXT,               -- 选择题的提示语
  took      TEXT,               -- 玩家选了哪个选项（路线）
  alts      TEXT,               -- 没选的其它选项（JSON 数组）
  ending    TEXT,               -- 结局id，如 END_TRUE
  vars      TEXT,               -- 关键数值快照 {jian,ban,truth}（JSON）
  ua        TEXT,               -- User-Agent（粗略区分设备）
  ref       TEXT                -- 来源页 referrer
);

CREATE INDEX IF NOT EXISTS idx_events_visitor ON events(visitor);
CREATE INDEX IF NOT EXISTS idx_events_type    ON events(type);
CREATE INDEX IF NOT EXISTS idx_events_ts       ON events(ts);
CREATE INDEX IF NOT EXISTS idx_events_day      ON events(day);
CREATE INDEX IF NOT EXISTS idx_events_ending   ON events(ending);
