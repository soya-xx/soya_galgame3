#!/bin/bash
# 串行补三张(并发串图后的修复)：cg_share_quilt, cg_tipsy_cling, luo_cry。务必单进程串行。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"; CHARS="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-overhaul.md"
SOYA_REF="$CHARS/soya_smile.png"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers, tasteful, no nudity, no explicit content."
SOYA="Soya the cat-girl: EXACTLY same character and same Chinese xianxia hanfu as the reference (white cross-collar wide-sleeve top, pastel-pink ruqun skirt, golden bell on black choker, cream-blonde wavy hair with two side buns, fluffy cat ears, big blue eyes, pink hair bow, fluffy cream tail)."
MC="the protagonist: tall young man, long black hair tied in a high ponytail, plain grey-blue xianxia robes."
SPRITE="wholesome family-friendly anime character sprite, full body standing, facing viewer, clean lineart, soft cel shading, TRANSPARENT background, full figure feet visible, no text, no watermark, correct anatomy."

gen() { out="$1"; ref="$2"; prompt="$3"; base=$(basename "$out")
  if [ -f "$out" ]; then echo "$base SKIP" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 4 ]; do
    [ $attempt -gt 1 ] && [ -f "$out" ] && archive_img "$out" rejected
    if [ "$ref" = "none" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    else
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    fi
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") )); w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 900 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 15
  done
  echo "$base FAIL" >> "$LOG"
}

echo "# 串行修复三张 $(date '+%m-%d %H:%M')" >> "$LOG"
gen "$CGD/cg_share_quilt.png" "$SOYA_REF" "$CG $SOYA With $MC Scene: a cold night in a small wooden room, Soya in human form burrowed under one shared quilt beside the protagonist, only her deeply flushed face, cat ears and one bare shoulder peeking out, fluffy tail wrapped around his arm under the quilt, she clings shyly with a small embarrassed pout, warm dim candlelight, tender tasteful fade-to-black mood, no explicit content. 横构图 landscape 尺寸1536x1024。"
gen "$CGD/cg_tipsy_cling.png" "$SOYA_REF" "$CG $SOYA With $MC Scene: warm lantern-lit room at night, tipsy Soya with deeply flushed cheeks and hazy happy eyes, giggling, clinging onto the protagonist's arm and sliding down against him, her hanfu collar loosened just slightly but tasteful, cat ears drooping happily, sweet comedic drunk mood, no nudity. 横构图 landscape 尺寸1536x1024。"
gen "$CHARS/luo_cry.png" "$CHARS/luo_joy.png" "$SPRITE EXACTLY the same wholesome stylized cartoon child and same modest grey junior-disciple robe as the reference, around twelve, two small hair buns, NOT sexualized. 竖构图 portrait 尺寸1024x1536。Expression change only: big frightened tearful eyes, trembling, hands drawn up near her mouth, about to cry, scared."
echo "DONE-FIX3 $(date '+%m-%d %H:%M')" >> "$LOG"
