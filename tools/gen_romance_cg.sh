#!/bin/bash
# 等v2主批量完成后，接力生成3张恋爱线CG
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"
LOG="$ROOT/design/asset-status-v2.md"
SOYA_REF="$ROOT/web/assets/characters/soya_smile.png"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
SOYA_V2="Soya the cat-girl: EXACTLY the same character and same Chinese xianxia hanfu outfit as the reference image (white cross-collar wide-sleeve top, pastel-pink ruqun skirt, floating pink ribbons, golden bell on black choker, cream-blonde wavy hair with two side buns, cat ears, big blue eyes, fluffy tail)."
MC="the protagonist: tall young man, long black hair tied in a high ponytail, plain grey-blue xianxia robes"
MCW="the protagonist: tall young man, long black hair tied in a high ponytail, white xianxia robes"

# 等主批量结束（最多90分钟）
i=0
while [ $i -lt 180 ]; do
  grep -q "^DONE" "$LOG" && break
  sleep 30; i=$((i+1))
done

gen() {
  out="$CGD/$1.png"; prompt="$2"
  attempt=1
  while [ $attempt -le 3 ]; do
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$SOYA_REF" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "${w:-0}" -ge 1024 ] 2>/dev/null; then echo "$1.png OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$1.png RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 20
  done
  echo "$1.png FAIL" >> "$LOG"
}

echo "# 恋爱线CG接力 $(date '+%H:%M')" >> "$LOG"
gen cg_spring "$CG $SOYA_V2 尺寸1536x1024。Scene: a hot spring pool in a night bamboo forest, very thick white steam everywhere, Soya in the water up to her shoulders, half turned away, looking back over her shoulder surprised and deeply blushing, wet cream-blonde hair clinging, cat ears with water droplets, her golden bell resting on a rock at the water edge, steam tastefully covering everything below her shoulders, no nudity visible, flustered comedic mood, fireflies"
gen cg_first_kiss "$CG $SOYA_V2 with $MC. 尺寸1536x1024。Scene: moonlit small wooden room at night, Soya in a faintly glowing translucent form leaning down to softly kiss the protagonist who lies propped on the bed, foreheads close, eyes gently closed, golden light particles rising from her hair like drifting embers, the edges of her figure slightly fading into light, bittersweet and tender, dark blue palette with warm gold accents"
gen cg_dawn_kiss "$CG $SOYA_V2 with $MCW. 尺寸1536x1024。Scene: warm sunrise light flooding through a window, Soya tiptoeing up to kiss the protagonist softly on the lips, his hands gently catching her shoulders, golden bell shining at her neck, pink petals drifting in the morning light, tears of joy on her cheeks, celebratory warm reunion, romantic"
echo "ROMANCE_DONE $(date '+%H:%M')" >> "$LOG"
