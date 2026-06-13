#!/bin/bash
# 开场屈辱CG ×2 + 背刺版 cg_betrayal 重生成。务必单进程串行(并发会串图)。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"
LOG="$ROOT/design/asset-status-overhaul.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
MC="the protagonist: a tall young man, long black hair in a high ponytail, sharp dark eyes, drenched plain grey servant-disciple robe"
MCW="the protagonist: a tall young man, long black hair in a high ponytail, white ascension robes"
GU="the betrayer Gu Changsheng: a man in white-and-gold imperial robes, long black hair, a sorrowful yet cold face"

# gen <out> <force0|1> <prompt>
gen() { out="$1"; force="$2"; prompt="$3"; base=$(basename "$out")
  if [ "$force" = "1" ] && [ -f "$out" ]; then archive_keep "$out" superseded; fi
  if [ "$force" != "1" ] && [ -f "$out" ]; then echo "$base SKIP" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 3 ]; do
    [ $attempt -gt 1 ] && [ -f "$out" ] && archive_img "$out" rejected
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") )); w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 900 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 15
  done
  echo "$base FAIL" >> "$LOG"
}

echo "# 开场屈辱CG+背刺重生成 $(date '+%m-%d %H:%M')" >> "$LOG"
gen "$CGD/cg_kowtow.png" 0 "$CG $MC kneeling and kowtowing in the cold mud of a rainy night sect courtyard, forehead bloodied and pressed near a young arrogant inner-disciple's boot, the inner-disciple in fine dry robes sneering down under an umbrella, other disciples watching coldly from the rain, the protagonist's fists clenched in the mud, deep humiliation, cold blue rain, low angle looking down on him. 横构图 landscape 尺寸1536x1024。"
gen "$CGD/cg_kick.png" 0 "$CG The same arrogant young inner-disciple kicking $MC, who is sprawling sideways into the muddy rain water, splashing mud, a ring of disciples watching with cold amusement under umbrellas, rainy night sect courtyard, the protagonist propping himself up, jaw set, swallowing the humiliation, no blood gore, cold palette. 横构图 landscape 尺寸1536x1024。"
gen "$CGD/cg_betrayal.png" 1 "$CG Scene atop a white-jade ascension altar in blinding golden light, kneeling crowds far below. $MCW is run through from BEHIND — a slender sword thrust into his back, its bloody tip emerging from his chest. He is twisting his head back over his shoulder, eyes blown wide in shock and utter disbelief. Standing close behind him, gripping the sword hilt, is $GU. Around them, fragments of golden soul-light shatter outward like broken glass. The focus is the betrayed man's disbelieving backward stare. 横构图 landscape 尺寸1536x1024。"
echo "DONE-OPEN $(date '+%m-%d %H:%M')" >> "$LOG"
