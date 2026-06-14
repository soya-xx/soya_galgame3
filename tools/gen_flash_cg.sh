#!/bin/bash
ROOT="$(cd "$(dirname "$0")/.." && pwd)"; CGD="$ROOT/web/assets/cg"; CHD="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-cg-wave1.md"; IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
out="$CGD/cg_flash_yandere.png"; ref="$CHD/soya_smile.png"
P="high-quality anime visual novel CG, EXTREME close-up of a face filling the whole frame, Chinese xianxia. The face is Soya the cat-girl — EXACTLY the same character as the reference: cream-blonde hair, white cat ears, big blue eyes. But here her expression is YANDERE/病娇: eyes opened too wide, pupils fixed in adoring obsessive intensity, a small sweet smile that is subtly, deeply WRONG; a single faint tear track; a faint dark smudge on one cheek. Pitch-black background, harsh single rim light on the face, claustrophobic, a subliminal horror jolt meant to flash for a split second. Spine-chilling, tasteful, NO gore, only a faint smudge. 横构图 landscape 1536x1024."
a=1; while [ $a -le 3 ]; do
  [ -f "$out" ] && archive_img "$out" rejected
  codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$P" >/dev/null 2>&1
  if [ -f "$out" ]; then w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
    [ "${w:-0}" -ge 1024 ] 2>/dev/null && { record_model "$out" "$IMG_MODEL"; echo "cg_flash_yandere OK a$a" >> "$LOG"; exit 0; }; fi
  a=$((a+1)); sleep 10
done; echo "cg_flash_yandere FAIL" >> "$LOG"
