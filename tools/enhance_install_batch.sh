#!/bin/bash
# 结局福利CG批量 Step2+装载：grsai增强（失败回退底图）→ 统一1536宽 → web/assets/cg/
# 用法: bash tools/enhance_install_batch.sh <底图目录>
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${1:-/tmp/cg_end_base}"
FIN=/tmp/cg_end_final
LOG="$FIN/enhance.log"
mkdir -p "$FIN"
source "$ROOT/tools/lib/archive_img.sh"   # 覆盖现役CG前归档+模型留痕
echo "# enhance_install $(date '+%H:%M')" > "$LOG"

for f in "$SRC"/cg_*.png; do
  k=$(basename "$f" .png)
  out="$FIN/$k.png"
  [ -f "$out" ] && { echo "$k SKIP" >> "$LOG"; continue; }
  if python3 "$ROOT/tools/enhance_cg.py" "$f" "$out" "$k" >> "$LOG" 2>&1; then
    echo "$k ENHANCED" >> "$LOG"; MODELK="nano-banana-pro"
  else
    cp "$f" "$out"
    echo "$k FALLBACK_BASE" >> "$LOG"; MODELK="gpt-image-2"
  fi
  archive_keep "$ROOT/web/assets/cg/$k.png" superseded   # 覆盖现役CG前留底
  sips -Z 1536 "$out" --out "$ROOT/web/assets/cg/$k.png" >/dev/null 2>&1
  record_model "$ROOT/web/assets/cg/$k.png" "$MODELK" "img2img增强,底图gpt-image-2"
  echo "$k INSTALLED" >> "$LOG"
done
echo "DONE $(date '+%H:%M')" >> "$LOG"
