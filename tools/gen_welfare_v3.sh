#!/bin/bash
# v3：补完待生成图 + 主路线新增福利向CG。守红线：含蓄/点到浓处留白/无露骨。
# 风格对齐 gen_romance_cg.sh：SOYA_REF 锚图锁一致，codex gpt-image-2，归档留痕。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"
CHARS="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-overhaul.md"
SOYA_REF="$CHARS/soya_smile.png"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"

CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers, tasteful, no nudity, no explicit content."
SOYA="Soya the cat-girl: EXACTLY the same character and same Chinese xianxia hanfu outfit as the reference (white cross-collar wide-sleeve top, pastel-pink ruqun skirt with white gauze, floating pink ribbons, golden bell on black choker, cream-blonde wavy hair with two side buns, fluffy cat ears, big blue eyes, pink hair bow, fluffy cream tail)."
MC="the protagonist: tall young man, long black hair tied in a high ponytail, plain grey-blue xianxia robes"

gen() { # gen <out绝对路径> <参考图|none> <提示词>
  out="$1"; ref="$2"; prompt="$3"; base=$(basename "$out")
  if [ -f "$out" ]; then echo "$base SKIP 已存在" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 3 ]; do
    [ $attempt -gt 1 ] && [ -f "$out" ] && archive_img "$out" rejected
    if [ "$ref" = "none" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    else
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    fi
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") ))
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 900 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 15
  done
  echo "$base FAIL 3次未成" >> "$LOG"
}

echo "# 福利v3+补图 $(date '+%m-%d %H:%M')" >> "$LOG"

# === 补完待生成（成人，安全措辞） ===
gen "$CGD/cg_qian_last.png" "$CHARS/qian_resolve.png" "$CG Qian Tong: a wiry man around thirty in a worn pale-grey sect robe, lean sharp face, EXACTLY matching the reference. Scene: atop a vast white-jade ascension altar amid swirling golden sacrificial light, Qian Tong for once standing fully straight and tall, arms thrown wide to shield a crowd of frightened robed people huddled behind him, desperate selfless resolve on his face, epic tragic low heroic angle. 尺寸1536x1024。"
gen "$CGD/cg_gu_seed.png" "none" "$CG Scene: close shot of Gu Changsheng the Holy Master, a serene sorrowful man in white-and-gold imperial robes with long black hair, raising one hand to strike but it freezing in mid-air for a breath, his compassionate face torn with hesitation and old guilt, golden divine light, a flicker of grief in his eyes. 尺寸1536x1024。"

# === 主路线新增福利向（含蓄/fade-to-black） ===
gen "$CGD/cg_lap_ear.png" "$SOYA_REF" "$CG $SOYA With $MC. Scene: cozy warm wooden room by candlelight, Soya lying on her side with her head resting on the seated protagonist's lap, eyes blissfully half-closed, one fluffy cat ear gently scratched by his fingers, soft blush, content almost-purring expression, fluffy tail curled around her, fully clothed in her hanfu, tender comedic intimacy. 尺寸1536x1024。"
gen "$CGD/cg_hair_dry.png" "$SOYA_REF" "$CG $SOYA With $MC. Scene: night after a hot spring, thinning steam, Soya wrapped in the protagonist's oversized grey robe sitting with her back to him on a low bench, as he gently towels and combs her long wet cream-blonde hair, damp cat ears, she peeks back over her shoulder shyly blushing, the oversized robe collar slipping a little but tastefully covering her, no nudity, quiet intimate warmth. 尺寸1536x1024。"
gen "$CGD/cg_share_quilt.png" "$SOYA_REF" "$CG $SOYA With $MC. Scene: a cold night in a small wooden room, Soya in human form burrowed under one shared quilt beside the protagonist, only her deeply flushed face, cat ears and one bare shoulder peeking out, fluffy tail wrapped around his arm under the quilt, she clings shyly with a small embarrassed pout, warm dim candlelight, tender tasteful fade-to-black mood, no explicit content. 尺寸1536x1024。"
gen "$CGD/cg_tipsy_cling.png" "$SOYA_REF" "$CG $SOYA With $MC. Scene: warm lantern-lit room at night, tipsy Soya with deeply flushed cheeks and hazy happy eyes, giggling, clinging onto the protagonist's arm and sliding down against him, her hanfu collar loosened just slightly but tasteful, cat ears drooping happily, sweet comedic drunk mood, no nudity. 尺寸1536x1024。"

echo "DONE $(date '+%m-%d %H:%M')" >> "$LOG"
