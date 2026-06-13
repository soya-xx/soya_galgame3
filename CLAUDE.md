# 开发准则 · 剑神三千年

男性向龙傲天修仙视觉小说（单女主 向向/Soya）。本文是给协作者/AI 的工作约定，先读这里。

## 资产铁律（图片/CG/立绘）

1. **旧图、废图永不自动删除。** 它们是珍贵的历史素材。任何脚本在 `rm`/覆盖一张图前，
   必须先归档到 `design/archive/`。详见 [design/archive/README.md](design/archive/README.md)。
   - 出图脚本一律 `source "$ROOT/tools/lib/archive_img.sh"`，用
     `archive_img`（废稿移动归档）/ `archive_keep`（旧图覆盖前留底）代替 `rm -f`/裸覆盖。
   - **禁止**在出图/装载流程里出现 `rm -f "$out"` 这类丢图写法。

2. **每张图都要标注生成模型。** 验收通过装载现役时调用 `record_model "$out" "$IMG_MODEL"`，
   写入 [design/asset-models.tsv](design/asset-models.tsv)（`relpath  model  note`）。
   归档文件名与 `ARCHIVE_LOG.tsv` 也都带 `model` 列。查"某图什么模型生成的"看这份清单。
   - 现用模型：`gpt-image-2`（codex gpt-5.5 编排，底图主力）、`flux-2-pro`（BFL 图生图增强）、
     `nano-banana-pro`（grsai 图生图增强）。新管线在脚本顶部 `IMG_MODEL=...` 声明。

3. 新增/修改出图脚本时，套用上面两条的共用库即可，不要另造删除/覆盖逻辑。

## 资产流水线

- 底图：`codex exec -m gpt-5.5` 调 `gpt-image-2`，锚图锁角色一致性，校验宽≥1024，最多重试 3 次。
- 二次增强：`tools/flux_enhance.py`(flux-2-pro) 或 `tools/enhance_cg.py`(nano-banana-pro) 图生图。
- 规格与提示词：`design/asset-spec.md`；各批次状态：`design/asset-status-*.md`。

## 验收

```bash
npm run serve   # http://127.0.0.1:8013/  本地预览
npm test        # 结构图完整性 / 8结局路线模拟 / 文风红线 / 体验钩子
```

## Git

- 提交作者必须是 **soya-xx**，不得出现 B1lli。
- 提交/推送仅在用户明确要求时进行。

## 目录速览

- `design/story-bible.md` 故事圣经 · `design/asset-spec.md` 资产规格
- `design/archive/` 历史素材永久归档 · `design/asset-models.tsv` 现役图模型清单
- `web/` 游戏本体（可静态托管）· `web/script/` 剧本 DSL · `test/` 自动化验收
- `tools/` 出图/音效/部署脚本 · `tools/lib/archive_img.sh` 归档共用库
