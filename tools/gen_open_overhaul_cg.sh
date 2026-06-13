#!/bin/bash
# 开局重做·新增炸点CG。务必单进程串行(并发会串图)。
# cg_guard_death：向向(猫形态)守仇人五代人到死的病态深情闪回。锚 cat_normal 保一致性。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"
LOG="$ROOT/design/asset-status-overhaul.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
CAT_REF="$ROOT/web/assets/characters/cat_normal.png"
SOYA_REF="$ROOT/web/assets/characters/soya_smile.png"
source "$ROOT/tools/lib/archive_img.sh"
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy."
CAT="a small cream-white cat — EXACTLY the same cat as the reference image: cream-white fur, big bright blue eyes, a golden bell on a black collar, a small pink ribbon"
SOYA="Soya the cat-girl in HUMAN form — EXACTLY the same character and outfit as the reference image: cream-blonde wavy hair with two side buns, white cat ears, big blue eyes, white cross-collar wide-sleeve top, pastel-pink ruqun skirt, a golden bell on a black choker"

# gen <out> <force0|1> <ref> <prompt>
gen() { out="$1"; force="$2"; ref="$3"; prompt="$4"; base=$(basename "$out")
  if [ "$force" = "1" ] && [ -f "$out" ]; then archive_keep "$out" superseded; fi
  if [ "$force" != "1" ] && [ -f "$out" ]; then echo "$base SKIP" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 3 ]; do
    [ $attempt -gt 1 ] && [ -f "$out" ] && archive_img "$out" rejected
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") )); w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 900 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 15
  done
  echo "$base FAIL" >> "$LOG"
}

echo "# 开局重做新增CG $(date '+%m-%d %H:%M')" >> "$LOG"
gen "$CGD/cg_guard_death.png" 0 "$CAT_REF" "$CG $CAT. 横构图 landscape 尺寸1536x1024。A cold eerie flashback: a dim old bedchamber lit by one failing candle, an emaciated dying old man lying on a wooden bed, drawing his last breath. At the foot of the bed sits the small cream-white cat, perfectly still, watching him die. The cat's blue eyes are curved into a faint patient unsettling near-smile, as if it has waited here for decades and is content. Behind, ghostly faded layered impressions of other deathbeds and other dying faces, suggesting five generations passing in the very same spot. Cold blue moonlight, deep shadows, dust motes, spine-chilling quiet devotion, NO blood, NO gore."
gen "$CGD/cg_nightmare.png" 0 "$SOYA_REF" "$CG $SOYA. 横构图 landscape 尺寸1536x1024。A yandere nightmare in a pitch-black void with faint cold rim light. Soya in human form leans in extremely close, first-person POV of someone lying bound below her, her face dominating the frame. She is crying — tears streaming down both cheeks — yet her mouth curves into a wide manic deeply-satisfied smile; her big blue eyes are wide, crazed, possessive and adoring. A single smear of dark blood on one cheek. One slim hand reaches down toward the viewer's throat, fingers closing (implied, NOT graphic, no wound shown). Cold blue-black palette, one dim light on her face, deep shadows, claustrophobic, spine-chilling obsessive-love horror. Tasteful, NO gore, NO injuries, only a faint blood smear on her face."
echo "DONE-OVERHAUL $(date '+%m-%d %H:%M')" >> "$LOG"
