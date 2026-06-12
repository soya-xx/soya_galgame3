#!/bin/bash
# 仙侠风v2批量重生成：以 soya_smile(v2) 与 cat_normal(v2) 为锚，覆盖旧图
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CHARS="$ROOT/web/assets/characters"
CGD="$ROOT/web/assets/cg"
UID2="$ROOT/web/assets/ui"
LOG="$ROOT/design/asset-status-v2.md"
SOYA_REF="$CHARS/soya_smile.png"
CAT_REF="$CHARS/cat_normal.png"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
SPRITE="high-quality anime visual novel character sprite, full body standing, facing viewer, clean lineart, soft cel shading, pastel colors, TRANSPARENT background, full figure with feet visible, no text, no watermark, correct anatomy, exactly two arms, each hand five fingers."
SOYA_V2="Soya the cat-girl: EXACTLY the same character and same Chinese xianxia hanfu outfit as the reference image (white cross-collar wide-sleeve top, pastel-pink ruqun skirt with white gauze layers, floating pink silk ribbons, light-blue sash, golden bell on black choker, cream-blonde wavy hair with two side buns, cat ears, big blue eyes, pink hair bow, fluffy tail)."
CAT_V2="EXACTLY the same cream-colored anime kitten as the reference image: flat cel shading, feline head with short muzzle and almond blue cat eyes, pink bow near ear, collar with golden bell, NOT human-faced."
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
MC="the protagonist: tall young man, long black hair tied in a high ponytail, sharp dark eyes, plain grey-blue xianxia sect robes"
MCW="the protagonist: tall young man, long black hair tied in a high ponytail, white xianxia robes"

gen() { # gen <输出绝对路径> <参考1> [参考2] <提示词>
  out="$1"; ref1="$2"
  if [ $# -eq 4 ]; then ref2="$3"; prompt="$4"; else ref2=""; prompt="$3"; fi
  base=$(basename "$out")
  attempt=1
  while [ $attempt -le 3 ]; do
    if [ -n "$ref2" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref1" -i "$ref2" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    else
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref1" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    fi
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") ))
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 600 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then echo "$base OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"
    attempt=$((attempt+1)); sleep 20
  done
  echo "$base FAIL 保留旧图" >> "$LOG"; return 0
}

echo "# v2仙侠化批量 $(date '+%m-%d %H:%M')" >> "$LOG"
# A. 向向人形差分（尺寸随提示词默认竖版；锚图即构图模板）
gen "$CHARS/soya_joy.png"   "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: beaming open-mouth grin, sparkling eyes, ears perked up, tail straight up, one fist raised in cheer"
gen "$CHARS/soya_pout.png"  "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: puffed cheeks pouting, ears half down, tail lashing, arms crossed"
gen "$CHARS/soya_tear.png"  "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: big teary eyes about to cry, ears flat down, tail drooping, hands clutched in front of chest"
gen "$CHARS/soya_blush.png" "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: deep blush, flustered, looking aside, hands pressed to own cheeks"
gen "$CHARS/soya_shock.png" "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: wide eyes, small open mouth, ears straight up, tail puffed, hands half raised"
gen "$CHARS/soya_calm.png"  "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: quiet melancholy gentle look, soft sad smile, ears slightly lowered, hands folded"
gen "$CHARS/soya_fade.png"  "$SOYA_REF" "$SPRITE $SOYA_V2 尺寸1024x1536。Pose change only: weakened and tired, eyes half open, faint smile, leaning slightly, pale translucent glow on her edges"
# B. 猫差分
gen "$CHARS/cat_alert.png" "$CAT_REF" "$SPRITE $CAT_V2 尺寸1024x1536。Pose change only: standing on four legs, alert, ears perked, tail raised high"
gen "$CHARS/cat_sad.png"   "$CAT_REF" "$SPRITE $CAT_V2 尺寸1024x1536。Pose change only: lying down with head on paws, ears flat, sad eyes"
# C. 含Soya的CG与标题（全部1536x1024）
gen "$UID2/title_keyvisual.png" "$SOYA_REF" "$CG $SOYA_V2 尺寸1536x1024。Scene: Soya in her xianxia hanfu sitting on an old tiled rooftop at night beside a slender Chinese sword stuck upright, huge full moon behind, falling pink petals, night-blue palette with pink accents, anime key visual composition, empty copy space at the left third for title text"
gen "$CGD/cg_moon_reveal.png" "$SOYA_REF" "$CG $SOYA_V2 尺寸1536x1024。Scene: full moon over bamboo grove and mirror lake, Soya appearing in a swirl of pale-pink light petals, standing barefoot on the water surface, shy smile, reaching one hand toward viewer, her hanfu ribbons floating"
gen "$CGD/cg_sword_tomb.png" "$SOYA_REF" "$CG $SOYA_V2 with $MC. 尺寸1536x1024。Scene: vast underground sword tomb cavern, ten thousand ancient swords half-risen from stone bowing their blades toward the protagonist walking in the center, Soya in her hanfu holding his sleeve, green-blue ghost light, epic wide shot"
gen "$CGD/cg_collapse.png" "$SOYA_REF" "$CG $SOYA_V2 with $MC. 尺寸1536x1024。Scene: night corridor, Soya fainting limp in the protagonist's arms, her golden bell dim with a hairline crack, his eyes wide in fear, cold moonlight"
gen "$CGD/cg_panel_truth.png" "$SOYA_REF" "$CG $SOYA_V2 with $MC. 尺寸1536x1024。Scene: dark wooden room at blue night, Soya sleeping peacefully on a bed in her hanfu, translucent golden contract threads of light flowing out from her chest into a sword-shaped glow held in the protagonist's hands, his face stricken with grief, moonlight through window"
gen "$CGD/cg_core_burn.png" "$SOYA_REF" "$CG $SOYA_V2 with $MC. 尺寸1536x1024。Scene: Soya standing between the wounded protagonist and an unseen enemy, arms spread wide protecting him, her body igniting into blue-white flame from the edges of her hanfu, golden bell blazing with light, tearful determined smile, devastating and beautiful"
gen "$CGD/cg_end_true.png" "$SOYA_REF" "$CG $SOYA_V2 with $MCW. 尺寸1536x1024。Scene: morning windowsill in warm sunrise light, Soya just woken up blinking with tears of joy, golden bell ringing with light, the protagonist's hand offering a small dried fish, both smiling, intimate warm reunion"
gen "$CGD/cg_end_leave.png" "$SOYA_REF" "$CG $SOYA_V2 尺寸1536x1024。Scene: dusk noodle stall in a small town, Soya wearing a hooded cloak over her hanfu with cat ears poking the hood up, happily slurping noodles, beside her a young black-ponytail man in plain clothes cooking noodles smiling faintly, a cloth-wrapped sword leaning on the bench, warm amber lanterns, cozy"
gen "$CGD/cg_end_refuse.png" "$CAT_REF" "$CG 尺寸1536x1024。Scene: dusk over old xianxia town rooftops, the same cream anime kitten as the reference (pink bow, golden bell collar, feline face) sitting alone on a roof ridge, watching from afar a distant ordinary man walking home below, melancholic warm orange light, lonely tender wide shot"
echo "DONE $(date '+%H:%M')" >> "$LOG"
