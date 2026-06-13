# 埋点 / 数据后台 · 搭建说明

给《剑神三千年》加的访客埋点。能回答你四个问题：

1. **多少独立访客玩了游戏**（按 IP 算，已加盐哈希，不存原始IP）
2. **每个人玩到第几章、停在哪个节点**（章节漏斗 + 流失点）
3. **哪里最好玩 / 哪里容易流失**（漏斗里掉人最多的那一档，就是最该改的）
4. **大家分别选了什么路线**（每个选择点的分布 + 逐访客路线明细）

数据后台页面：部署后访问 `https://你的域名/admin.html`，输入口令即可看。

---

## 一、它是怎么搭起来的（原理）

游戏托管在 Cloudflare Pages（静态站）。要拿到访客真实IP、要存数据、要算统计，
靠的是 **Cloudflare Pages Functions + D1 数据库**（都在 Cloudflare 免费额度内，小游戏完全够用）。

```
玩家浏览器
  └─ web/telemetry.js     发埋点事件（sendBeacon，关页面也能发出 → 抓得到流失点）
        │  POST /api/collect
        ▼
functions/api/collect.js  取真实IP→加盐哈希成“访客指纹”，取国家，写进 D1
        ▼
   D1 数据库 events 表     一条条原始事件流水
        ▲
        │  GET /api/stats?token=口令
functions/api/stats.js    聚合成：独立访客 / 章节漏斗 / 流失点 / 选择分布 / 结局 / 逐访客
        ▲
web/admin.html            后台看板（口令保护，已对搜索引擎隐藏）
```

**重要：`functions/` 目录在仓库根目录**，不在 `web/` 里面。
现有的部署命令 `wrangler pages deploy web`（在仓库根运行）会**自动**把根目录的 `functions/` 一起打包上线，
所以 `.github/workflows/deploy-cf.yml` 不用改。

埋点是**容错**的：没绑定数据库时 `/api/collect` 静默放过，游戏照常跑，绝不会因为埋点报错而白屏。

---

## 二、一次性搭建（约 5 分钟）

### 最省事：跑脚本

在项目根目录执行：

```bash
bash tools/telemetry/setup.sh
```

它会自动：建 D1 数据库 `soya_analytics` → 建表 → 让你设两个密钥。
跑完后**还要在网页后台点一下**把数据库绑定到项目（见下面第 4 步），脚本结尾也会再提醒你。

### 或者手动四步

```bash
# 1) 建数据库（会打印一段 database_id，记一下）
npx wrangler d1 create soya_analytics

# 2) 建表
npx wrangler d1 execute soya_analytics --remote --file=functions/schema.sql --yes

# 3) 设两个环境变量（密钥）
npx wrangler pages secret put STATS_TOKEN   --project-name=soya-galgame-sword   # 后台看数据的口令，自己想一个
npx wrangler pages secret put TELEMETRY_SALT --project-name=soya-galgame-sword  # IP加盐，随便一长串，设好别改
```

**4) 绑定数据库到项目（只能在网页后台点，这步必须做）**

Cloudflare 控制台 → **Workers & Pages** → 选 `soya-galgame-sword`
→ **Settings → Functions → D1 database bindings → Add binding**

| 填什么 | 值 |
| --- | --- |
| Variable name（变量名） | `DB` ← 必须大写，代码按这名字找库 |
| D1 database | `soya_analytics` |

保存后，`git push` 触发一次部署让绑定生效。

> 为什么这步要手点：Cloudflare Pages 的绑定目前主要在网页后台配置，命令行还不能稳定地加 Pages 绑定。
> 好处是它和部署解耦——就算还没绑，网站照常上线，绑好后数据就开始进来了。

---

## 三、怎么看数据

打开 `https://你的域名/admin.html`，输入 `STATS_TOKEN`。各板块含义：

- **总览**：独立访客 / 到访 / 开始 / 通关，以及开始率、通关率。
- **章节漏斗**：每章抵达人数 + 流失百分比。<b>红色流失率最高那档 = 最该改的剧情。</b>
- **流失点**：没通关的人最后停在哪个节点，按人数排。排前面的节点重点查节奏。
- **选择分布**：每个选择点各选项被多少人选。<b>票多的路线值得加料。</b>
- **结局分布 / 国家 / 按天趋势 / 逐访客明细**（明细里点“路线”看每人的完整选择序列）。

---

## 四、隐私与成本

- **不存原始IP**：服务端把 `IP + 盐` 做 SHA-256 后只取前 16 位当“访客指纹”，用来数独立访客、串起同一人的旅程。
- 另存浏览器端随机 `cid`（localStorage），换IP也能认出同一人。
- 还存了国家/城市（Cloudflare 提供）和 User-Agent，用于粗略画像。
- 建议在游戏里加一句轻量隐私说明（可选）。如果当地法规要求，可加“同意后才埋点”。
- **成本**：D1 免费额度 5GB、每天 500 万次读 / 10 万次写，单女主小黄油的体量远远用不完。

---

## 五、本地联调（可选）

```bash
# 用 wrangler 在本地跑 Functions + 本地 D1（--local 用本地模拟库）
npx wrangler pages dev web --d1 DB=soya_analytics
# 然后建本地表：
npx wrangler d1 execute soya_analytics --local --file=functions/schema.sql --yes
```

打开它给的本地地址，玩两步、做个选择，再开 `/admin.html` 输入随便设的本地 `STATS_TOKEN` 看数据流。
（本地要让 `/api/stats` 通过，需在 `wrangler pages dev` 时通过 `--binding STATS_TOKEN=xxx` 注入。）

---

## 六、埋点都打在哪（给改代码的人）

`web/engine.js` 里调用 `window.TLM.*`：

| 事件 | 触发点 | 答什么问题 |
| --- | --- | --- |
| `visit` | 页面加载（telemetry.js 自动） | 多少人来过 |
| `start` | `startStory()` 新游戏 / `loadSnap()` 继续 | 多少人真的开始 |
| `chapter` | `show()` 里章节标题变化 | 章节漏斗 |
| `progress` | `show()` 每节点节流上报 + 离开页面补发 | 流失点（最后停在哪） |
| `choice` | `pickChoice()` | 走了什么路线 |
| `ending` | `showEnding()` | 通关 & 哪个结局 |

加新章节/新选择**不用动埋点**——它读 `STORY.chapters` 和节点信息自动带上。
