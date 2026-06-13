# design/archive/ —— 历史素材永久归档

> 开发铁律：**旧图、废图都是珍贵的历史素材，一律永久保存，禁止自动删除。**
> 任何生成/增强脚本在覆盖或丢弃一张图前，必须先把它归档到这里。

## 为什么

AI 迭代出图会反复覆盖、重试、淘汰。早期脚本用 `rm -f`/直接覆盖处理"废图/旧图"，
珍贵的中间稿和历史版本一去不返。现在统一归档留底，任何一版都能找回、对比、复用。

## 目录结构

```
design/archive/
├── original/     现役图被编辑/重生成前的"原始底稿"（覆盖前留底）
├── superseded/   被新版本取代下线的旧现役图
├── rejected/     生成后未通过校验/复核的废稿（旧脚本里被 rm 的那些）
├── ARCHIVE_LOG.tsv   每一次归档的流水账（机器可读）
└── README.md
```

历史批次以"原因/日期-说明"子目录保留原始文件名，便于成组追溯：

- `superseded/v1-lolita-2026-06-12/` —— v1 洛丽塔版人设全套（被 v2 仙侠版取代）
- `original/cg-fix-2026-06-12/` —— gen_fix_cg 批次修图前的原始 CG

## 命名约定

自动归档的单文件统一命名（自带元信息，文件名即标签）：

```
<资产名>__<原因>__<模型>__<UTC时间戳>[__<备注>].png
例： cg_betrayal__rejected__gpt-image-2__20260613T0830Z.png
    soya_smile__superseded__gpt-image-2__20260613T0915Z.png
```

- **原因** `original | superseded | rejected`
- **模型** 生成该图的模型：`gpt-image-2` / `flux-2-pro` / `nano-banana-pro` …
- **时间戳** UTC，`date -u +%Y%m%dT%H%M%SZ`

`ARCHIVE_LOG.tsv` 列：`utc_iso  reason  model  asset_key  original_path  archived_relpath  note`

## 怎么用（脚本接入）

所有出图脚本 source 共用库 `tools/lib/archive_img.sh`，用函数代替 `rm`/裸覆盖：

```bash
IMG_MODEL=gpt-image-2                      # 先声明本管线生成模型
source "$ROOT/tools/lib/archive_img.sh"

archive_img  "$out" rejected               # 废稿：移动归档（腾出原路径重试）
archive_keep "$out" superseded             # 旧图：覆盖前复制留底
record_model "$out" "$IMG_MODEL"           # 验收通过：登记现役图的生成模型
```

Python 管线（`tools/flux_enhance.py`）内置同格式的 `_archive` / `_record_model`，无需额外接入。

## 配套：现役素材模型清单

`design/asset-models.tsv`（列 `relpath  model  note`）记录**每一张现役图由哪个模型生成**，
由各脚本 `record_model` 自动维护。查"某张图什么模型生成的"看这里。
