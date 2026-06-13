#!/bin/bash
# 剧情大修 v2 新增美术：钱通立绘(硬前置) + 新CG。模式同 regen_xianxia.sh。
# 用法: bash tools/gen_overhaul_art.sh   (建议后台跑 + 监控 mtime)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHARS="$ROOT/web/assets/characters"
CGD="$ROOT/web/assets/cg"
LOG="$ROOT/design/asset-status-overhaul.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"

SPRITE="high-quality anime visual novel character sprite, full body standing, facing viewer, clean lineart, soft cel shading, Chinese xianxia fantasy, TRANSPARENT background, full figure with feet visible, no text, no watermark, correct anatomy, exactly two arms, each hand five fingers."
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
MC="the protagonist: tall young man, long black hair tied in a high ponytail, sharp dark eyes, plain grey-blue xianxia sect robes"
QIAN="Qian Tong: a wiry shifty man around thirty, worn pale-grey sect outer-disciple robe, lean sharp face, clever darting eyes, an ingratiating servile smile where the eyes narrow first, back slightly hunched from years of bowing and scraping, nimble scheming hands, plain and NOT handsome, the look of a small-time informer."
LUO="A-Luo: a small skinny twelve-year-old girl disciple, simple grey sect robe, hair in two short buns, big round innocent eyes, eager hopeful expression."
GU="Gu Changsheng the Holy Master: a serene sorrowful man in white-and-gold imperial robes, long black hair, gentle compassionate yet weary face."

gen() { # gen <输出绝对路径> [<参考1>] <提示词>
  out="$1"
  if [ $# -eq 3 ]; then ref1="$2"; prompt="$3"; else ref1=""; prompt="$2"; fi
  base=$(basename "$out")
  if [ -f "$out" ]; then echo "$base SKIP 已存在" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 3 ]; do
    [ $attempt -gt 1 ] && [ -f "$out" ] && archive_img "$out" rejected
    if [ -n "$ref1" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref1" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    else
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    fi
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") ))
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 900 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK attempt$attempt w=$w" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"
    attempt=$((attempt+1)); sleep 15
  done
  echo "$base FAIL 3次未成" >> "$LOG"; return 0
}

echo "# 大修美术 $(date '+%m-%d %H:%M')" >> "$LOG"

# === A. 钱通立绘（硬前置：他要开口必须有立绘） ===
# 先无参考定妆 fawn，再以 fawn 为锚做表情差分，保一致性
gen "$CHARS/qian_fawn.png" "$SPRITE $QIAN 尺寸1024x1536。Expression: ingratiating fawning smile, rubbing both hands together, head tilted in a servile bow, eyes narrowed in a fake grin."
gen "$CHARS/qian_fear.png" "$CHARS/qian_fawn.png" "$SPRITE EXACTLY the same character and same worn grey robe as the reference. 尺寸1024x1536。Expression change only: face drained white with terror, eyes wide, mouth open in dread, hands trembling raised, the moment he realizes his own name is on the death roster."
gen "$CHARS/qian_resolve.png" "$CHARS/qian_fawn.png" "$SPRITE EXACTLY the same character and same worn grey robe as the reference. 尺寸1024x1536。Expression change only: for once standing fully straight, no more servile smile, a desperate quiet resolve in his eyes, fists clenched at his sides, a man who has decided to do one selfless thing."

# === B. 钱通相关 CG（1536x1024） ===
gen "$CGD/cg_qian_inform.png" "$CHARS/qian_fawn.png" "$CG $QIAN 尺寸1536x1024。Scene: a dim corner of a stone corridor at night, Qian Tong furtively whispering and passing a folded note to a tall black-robed figure whose collar bears a small golden-eye emblem, his posture fawning and sneaky, cold blue moonlight, an air of quiet betrayal."
gen "$CGD/cg_qian_roster.png" "$CHARS/qian_fawn.png" "$CG $QIAN 尺寸1536x1024。Scene: a gold-flecked name scroll unrolled in lantern light, Qian Tong staring down at his own name brushed onto it, his fawning smile cracking into horror, hand frozen halfway, warm cruel lantern glow."
gen "$CGD/cg_qian_last.png" "$CHARS/qian_resolve.png" "$CG $QIAN with $MC. 尺寸1536x1024。Scene: atop a vast white-jade ascension altar amid swirling golden sacrificial light, Qian Tong for once standing straight, throwing himself in front of frightened young conscripts to shield them, desperate selfless resolve on his face, epic tragic lighting."

# === C. 阿萝 / 顾长生（stretch / 可选） ===
gen "$CGD/cg_luo_flower.png" "$CG $LUO 尺寸1536x1024。Scene: a small twelve-year-old girl disciple wearing an oversized big red silk celebration flower on her chest, looking up with innocent excited joy, not knowing 'ascension' means death, warm golden light with a cruel ironic undertone, soft focus crowd behind."
gen "$CHARS/luo_joy.png" "$SPRITE $LUO 尺寸1024x1536。Expression: beaming innocent excited smile, wearing a big red celebration flower, both hands clasped happily."
gen "$CHARS/luo_cry.png" "$CHARS/luo_joy.png" "$SPRITE EXACTLY the same little girl and grey robe as the reference. 尺寸1024x1536。Expression change only: big frightened tearful eyes, trembling, the red flower slipping, about to cry."
gen "$CGD/cg_gu_seed.png" "$CG $GU 尺寸1536x1024。Scene: close shot of Gu Changsheng on the celestial altar raising his hand to strike but it pausing in mid-air for a breath, his compassionate face torn with hesitation and old guilt, golden divine light, a flicker of the brother he betrayed in his eyes."

echo "DONE $(date '+%m-%d %H:%M')" >> "$LOG"
