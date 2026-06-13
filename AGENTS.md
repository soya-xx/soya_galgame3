# AGENTS.md · 给 AI 协作者（Codex / Claude Code 等）

> 本文是 Codex 等读 `AGENTS.md` 的工具的入口。**通用开发准则在 [CLAUDE.md](CLAUDE.md)，务必先读、严格遵守**
> （资产铁律：旧图废图永久归档禁删、每图标注模型；Git 作者必须 soya-xx；文笔铁律：大白话/CG承载高光）。
> 本文只补一件 CLAUDE.md 没讲的事：**怎么读懂并用上这套访客埋点数据，据此决定改哪段剧情。**

---

## 一、这套数据能回答什么（也就是它存在的目的）

游戏托管在 Cloudflare Pages，埋点收集真实访客行为，用来指导剧情迭代：

1. **多少独立访客**玩了游戏（按 IP 加盐哈希去重，不存原始IP）
2. **每个人玩到第几章 / 停在哪个节点**（章节漏斗 + 流失点）
3. **哪里最好玩 / 哪里劝退**（漏斗里流失率最高那一档 = 最该改的剧情）
4. **大家分别选了什么路线**（每个选择点的分布 + 逐访客路线）→ 给热门路线加料

搭建方式（建库/绑定/密钥）见 [design/telemetry-setup.md](design/telemetry-setup.md)，本文不重复。

## 二、系统组成（文件地图）

| 角色 | 文件 | 说明 |
|---|---|---|
| 前端 SDK | [web/telemetry.js](web/telemetry.js) | `window.TLM.*`，用 sendBeacon 发事件 |
| 打点接入 | [web/engine.js](web/engine.js) | 在 开始/章节切换/选择/结局 四处调用 TLM |
| 采集端 | [functions/api/collect.js](functions/api/collect.js) | 取真实IP→哈希成 visitor、取地区，写 D1 |
| 统计端 | [functions/api/stats.js](functions/api/stats.js) | 聚合成漏斗/流失点/选择分布等，token 保护 |
| 数据库表 | [functions/schema.sql](functions/schema.sql) | D1 `events` 单表流水 |
| 看板 | [web/admin.html](web/admin.html) | 人看的页面；AI 直接走下面的 API |

埋点是容错的：没绑数据库时 collect 静默放过，**不会因埋点报错影响游戏**。

## 三、怎么取数据（AI 直接用这个）

统计端返回结构化 JSON，AI 分析走它，不要去解析 admin.html。

```bash
# $STATS_TOKEN = 你在 Cloudflare 设的后台口令；$HOST = 线上域名
curl -s "https://$HOST/api/stats?token=$STATS_TOKEN" | jq .
```

返回字段字典（`c`=总次数，`v`=独立访客数，`ci`=章节序号 0..6，`mci`=该访客到达的最深章节序号）：

```jsonc
{
  "ok": true,
  "overview": { "visitors": 独立访客, "cids": 浏览器数, "events": 总事件,
                "visits": 到访次数, "starts": 开始局数, "finishers": 通关人数,
                "firstTs": 最早, "lastTs": 最近 },
  "byCountry": [{ "country": "CN", "v": 独立访客 }],
  "byDay":     [{ "day": "2026-06-13", "visitors": , "starts": , "finishers": }],
  "ciLabel":   { "0": "序章·…", "1": "第一章·…", … },        // 章节序号→标题
  "funnel":    [{ "ci": 0, "label": "序章·…", "reached": 抵达该章的独立访客 }],
  "dropoff":   [{ "node": "ch1_317", "ch": "第一章·…", "c": 停在此处的人数 }], // ★流失点
  "choices":   [{ "node": "p_070", "ctx": 选择提示语, "took": 选项文案, "c": , "v": }],
  "endings":   [{ "ending": "END_TRUE", "c": , "v": }],
  "visitors":  [{ "visitor": 指纹, "country": , "name": 起的名字, "mci": 最深章节,
                 "ending": 通关结局, "choices": 选择数,
                 "route": [{ "ctx": , "took": }], "lastTs": }]
}
```

口令错 → 401；没绑库 → 503（带中文说明）。

> 临时只读直查 D1（可选，需 wrangler 登录）：
> `npx wrangler d1 execute soya_analytics --remote --command "SELECT type,count(*) FROM events GROUP BY type"`
> **只读查询**，绝不在 events 表上做破坏性写操作。

## 四、把数据翻成剧情决策（核心工作流）

> 节点 id 前缀 → 剧本文件的映射（拿到 `dropoff[].node` 就能直接打开对应文件）：

| 前缀 | 文件 | 章节 |
|---|---|---|
| `p_*` | [web/script/ch0.js](web/script/ch0.js) | 序章 |
| `ch1_*` | [web/script/ch1.js](web/script/ch1.js) | 第一章 |
| `ch2_*` | [web/script/ch2.js](web/script/ch2.js) | 第二章 |
| `ch3_*` | [web/script/ch3.js](web/script/ch3.js) | 第三章 |
| `ch4_*` | [web/script/ch4.js](web/script/ch4.js) | 第四章 |
| `ch5_*` | [web/script/ch5.js](web/script/ch5.js) | 终章 |
| `endx_*` | [web/script/endings.js](web/script/endings.js) | 尾声 / 8 结局 |

四类信号 → 对应动作：

1. **漏斗某档流失率高**（`funnel`：相邻两档 reached 落差大）
   → 打开那一章剧本，重点看**长段纯阅读**（没有选择也没有 CG 的连续节点）。
   → 按文笔铁律改：插一张 CG 承载、拆一个小选择、加章节卡断节奏。**别堆华丽词藻，要大白话推进。**

2. **流失点 `dropoff` 排名靠前的 node**
   → 用上表映射打开文件，定位该节点上下文，检查是不是"读字墙 / 节奏拖沓 / 期待落空"。
   → 这是最精确的"该改哪句"指针。

3. **选择分布 `choices` 一边倒**（某 node 下某 `took` 的 v 远高于其它）
   → 冷门选项：可能门槛太高、不吸引人、或没被看见——给它加诱因或加料。
   → 热门路线：玩家用脚投票，**往这条线多写内容/CG**（这正是埋点要服务的目的）。

4. **结局分布 `endings` 畸形**（某结局占比畸高、某结局几乎没人到）
   → 对照 [design/story-bible.md](design/story-bible.md) 的结局矩阵与 [web/script/endings.js](web/script/endings.js) 的触发条件，
     检查冷门结局的隐藏变量门槛（剑心 jian / 羁绊 ban / 真相 truth）是否过苛或路径太隐蔽。

**铁律提醒**：任何据数据做的剧情改动，仍要过 `npm test`（结构完整性 / 8 结局可达 / 文风红线 / 体验钩子），且 Git 作者必须是 soya-xx。

## 五、改埋点本身时的约定（少数情况）

- **加新章节、新选择，不用动埋点**：SDK 读 `STORY.chapters` 和节点信息自动带上 `ci`/`node`/`ch`。
- 打点位置在 [web/engine.js](web/engine.js)：`startStory`/`loadSnap`（start）、`show`（chapter+progress）、`pickChoice`（choice）、`showEnding`（ending）。
- 新增事件类型时，三处都要改：`telemetry.js` 发送、`schema.sql` 字段、`stats.js` 聚合，并同步本文字段字典。
- **隐私红线**：不要把原始 IP 落库（只存哈希）；不要在前端或日志里泄露 `STATS_TOKEN` / `TELEMETRY_SALT`；
  `TELEMETRY_SALT` 一旦上线别改（改了独立访客会重新计数）。

## 六、当前状态

埋点代码已就位并经端到端实测（前端触发 + Workers 运行时 + D1 落库 + 看板渲染均通过）。
**上线前还需一次性操作**：建 D1、在 Cloudflare 后台把数据库以变量名 `DB` 绑定到 Pages 项目、设两个密钥，
然后部署。未完成这步时线上无数据，统计端返回 503。步骤见 [design/telemetry-setup.md](design/telemetry-setup.md)。
