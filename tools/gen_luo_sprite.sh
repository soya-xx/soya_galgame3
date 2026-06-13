#!/bin/bash
# 阿萝立绘（纯剧情角色，无福利）：措辞务必健康、端庄、明确动漫风、非写实、不性化。
# 先无参考定妆 luo_joy，再以其为锚做 luo_cry 表情差分保一致。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHARS="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-overhaul.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"

SPRITE="wholesome family-friendly anime visual novel character sprite, full body standing, facing viewer, clean lineart, soft cel shading, Chinese xianxia fantasy, TRANSPARENT background, full figure feet visible, no text, no watermark, correct anatomy, exactly two arms, each hand five fingers."
LUO="a cheerful young child sect-disciple, around twelve years old, wearing a plain modest high-collar grey junior-disciple robe that fully covers her, two small round hair buns, big round innocent eyes, a little gap-toothed kid; clearly a wholesome stylized cartoon child, modestly dressed, NOT sexualized in any way."

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

echo "# 阿萝立绘 $(date '+%m-%d %H:%M')" >> "$LOG"
gen "$CHARS/luo_joy.png" "none" "$SPRITE $LUO 尺寸1024x1536。Expression: beaming innocent excited smile, both hands clasped happily in front of chest, bouncing on her toes, eyes sparkling with naive hope."
gen "$CHARS/luo_cry.png" "$CHARS/luo_joy.png" "$SPRITE EXACTLY the same child character and same modest grey robe as the reference. 尺寸1024x1536。Expression change only: big frightened tearful eyes, trembling, hands drawn up to her mouth, about to cry, scared."
echo "DONE-LUO $(date '+%m-%d %H:%M')" >> "$LOG"
