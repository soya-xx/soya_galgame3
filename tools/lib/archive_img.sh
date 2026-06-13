#!/bin/bash
# 共用图片归档/留痕函数 —— 两条铁律：
#   1) 任何"旧图/废图"都不许 rm，一律归档进 design/archive/。
#   2) 任何产出的图都要标注生成模型（归档文件名 + 日志 + 现役清单都带 model）。
# 开发准则见 design/archive/README.md。macOS bash 3.2 兼容。
#
# 用法（在脚本里 source 后调用；先 export IMG_MODEL 指明本管线模型）：
#   IMG_MODEL=gpt-image-2            # 例：gpt-image-2 / flux-2-pro / nano-banana-pro
#   source "$ROOT/tools/lib/archive_img.sh"
#   archive_img  <文件> [reason] [note]   # 移动归档（文件即将被删/被覆盖，无需保留原位）
#   archive_keep <文件> [reason] [note]   # 复制归档（文件仍需留在原位继续用）
#   record_model <现役文件> [model] [note] # 接受/装载一张图时，登记它由哪个模型生成
#
# reason 取值：original | superseded | rejected （详见 README）。缺省 discarded。
# model  缺省取环境变量 $IMG_MODEL，再缺省 unknown。

# 归档根目录：相对本脚本定位仓库根，任何 $ROOT 的调用方都一致
_ARCHIVE_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"   # = tools/
_ARCHIVE_ROOT="$(cd "$_ARCHIVE_LIB_DIR/.." && pwd)"                       # 仓库根
ARCHIVE_DIR="${ARCHIVE_DIR:-$_ARCHIVE_ROOT/design/archive}"
ARCHIVE_LOG="$ARCHIVE_DIR/ARCHIVE_LOG.tsv"
ASSET_MODELS="${ASSET_MODELS:-$_ARCHIVE_ROOT/design/asset-models.tsv}"

# 内部：计算归档目标路径并落日志，回显目标路径
_archive_dest() {
  local src="$1" reason="${2:-discarded}" note="${3:-}"
  local model="${IMG_MODEL:-unknown}"
  local base name ext stamp dest rel suffix
  base="$(basename "$src")"
  name="${base%.*}"; ext="${base##*.}"
  [ "$name" = "$ext" ] && ext="png"            # 无扩展名兜底
  stamp="$(date -u +%Y%m%dT%H%M%SZ)"
  mkdir -p "$ARCHIVE_DIR/$reason"
  # 文件名自带：资产名__原因__模型__时间[__备注]
  suffix="${name}__${reason}__${model}__${stamp}${note:+__$note}"
  dest="$ARCHIVE_DIR/$reason/${suffix}.${ext}"
  local i=1                                      # 同秒冲突追加序号
  while [ -e "$dest" ]; do
    dest="$ARCHIVE_DIR/$reason/${suffix}-${i}.${ext}"
    i=$((i+1))
  done
  rel="${dest#$_ARCHIVE_ROOT/}"
  if [ ! -f "$ARCHIVE_LOG" ]; then
    printf 'utc_iso\treason\tmodel\tasset_key\toriginal_path\tarchived_relpath\tnote\n' > "$ARCHIVE_LOG"
  fi
  printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
    "$stamp" "$reason" "$model" "$name" "${src#$_ARCHIVE_ROOT/}" "$rel" "$note" >> "$ARCHIVE_LOG"
  printf '%s' "$dest"
}

# 移动归档：文件即将被删除或被新图覆盖时调用
archive_img() {
  local src="$1"
  [ -f "$src" ] || return 0                    # 不存在则静默放过
  local dest; dest="$(_archive_dest "$@")"
  mv "$src" "$dest"
}

# 复制归档：要留一份历史，但原文件还得继续用时调用
archive_keep() {
  local src="$1"
  [ -f "$src" ] || return 0
  local dest; dest="$(_archive_dest "$@")"
  cp "$src" "$dest"
}

# 登记现役素材由哪个模型生成（一图一行，同路径覆盖旧记录）
record_model() {
  local f="$1" model="${2:-${IMG_MODEL:-unknown}}" note="${3:-}"
  local rel="${f#$_ARCHIVE_ROOT/}"
  case "$rel" in /*|../*) return 0;; esac        # 仓库外路径(如/tmp暂存)不入清单
  mkdir -p "$(dirname "$ASSET_MODELS")"
  [ -f "$ASSET_MODELS" ] || printf 'relpath\tmodel\tnote\n' > "$ASSET_MODELS"
  local tmp="${ASSET_MODELS}.tmp.$$"
  awk -F'\t' -v r="$rel" 'NR==1 || $1!=r' "$ASSET_MODELS" > "$tmp" && mv "$tmp" "$ASSET_MODELS"
  printf '%s\t%s\t%s\n' "$rel" "$model" "$note" >> "$ASSET_MODELS"
}
