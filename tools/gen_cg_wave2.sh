#!/bin/bash
# CG 扩充 Wave2：正篇各路线情绪关键点补 CG（11 张）。先等 Wave1 完成再串行跑，避免并发串图。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"; CHD="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-cg-wave2.md"; W1="$ROOT/design/asset-status-cg-wave1.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy. 横构图 landscape 1536x1024."

# 等 Wave1 收尾，避免两个 codex 并发
for i in $(seq 1 120); do grep -q "DONE-WAVE1" "$W1" 2>/dev/null && break; sleep 30; done

gen() { out="$1"; ref="$2"; prompt="$3"; base=$(basename "$out")
  if [ -f "$out" ]; then echo "$base SKIP(exists)" >> "$LOG"; return 0; fi
  a=1; while [ $a -le 3 ]; do
    [ -f "$out" ] && archive_img "$out" rejected
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK a$a" >> "$LOG"; return 0; fi; fi
    echo "$base RETRY a$a" >> "$LOG"; a=$((a+1)); sleep 10
  done; echo "$base FAIL" >> "$LOG"; }

echo "# CG Wave2 $(date '+%m-%d %H:%M')" >> "$LOG"
gen "$CGD/cg_zhou_bun.png" "$CHD/zhou_smile.png" "$CG A kindly limping old man in a shabby robe hurries through cold night rain in a poor chore-yard to press two steaming white mantou buns into the hands of a soaked, mud-splattered young man kneeling by a brick pile. Warm steam against cold blue rain, quiet kindness. Touching."
gen "$CGD/cg_zhou_yam.png" "$CHD/zhou_smile.png" "$CG The same kindly old man, by a sunlit courtyard wall where he is washing vegetables, presses a hot roasted sweet potato into a young man's hands, his calloused palms open, a gentle weathered smile. Warm afternoon light, homely warmth, the wisdom of a humble man. Tender."
gen "$CGD/cg_moon_vow.png" "$CHD/soya_smile.png" "$CG By a still moonlit lake, Soya the cat-girl in human form (cream-blonde hair, white cat ears, pastel-pink ruqun, golden bell choker) sits beside a young man with a black ponytail, smiling a soft secretive smile as if hiding a happy secret, tail curled. Tranquil silver moonlight on water, tender intimacy. Beautiful, gentle."
gen "$CGD/cg_cliff_shen.png" "$CHD/shen_proud.png" "$CG An ominous memory: silhouetted figures of a noble clan in fine robes stand at the top of a high cliff at dusk, looking coldly down, while far below a young man falls toward a ravine of mist. Cold foreboding palette, betrayal foreshadowed, dramatic. NO gore."
gen "$CGD/cg_shen_whip.png" "$CHD/shen_shock.png" "$CG A proud young sword cultivator in moon-white robes stands cornered against a wall by several stern brocade-clad clan stewards, head lowered, fists clenched white, his usual arrogance cracked into silent humiliation. Tense, oppressive, the pawn behind the pawn. Cold light."
gen "$CGD/cg_golden_date.png" "$CHD/xuanyi_polite.png" "$CG At a lavish night banquet, a refined white-gold-robed envoy with a faint cold smile drops a small glowing golden date into a wine cup held by the viewer, his eyes sharp and appraising behind the smile. Warm banquet lamplight, hidden menace. Tense, ornate."
gen "$CGD/cg_seal_cry.png" "$CHD/cat_sad.png" "$CG A small cream-white cat with a golden bell (one hairline crack on the bell, faintly glowing) buries its face into a young man's open palm and weeps, in a dim humble room by candlelight. Tender, heartbreaking, intimate, the bell glowing a little brighter. Soft warm shadows."
gen "$CGD/cg_vote_betray.png" "$CHD/zhou_worry.png" "$CG In a dim sect great hall, robed elders sit around a long table; the sect master pushes a small jade token back to the table's center, eyes averted, while two disciples drag a shouting old chore-hand (kindly weathered face) toward the door as he looks back in anger. Cold institutional light, quiet betrayal, one humble man protesting. Dramatic, somber."
gen "$CGD/cg_forget.png" "$CHD/cat_alert.png" "$CG Heartbreaking: a small cream-white cat backed into the corner of a bed, fur bristling, baring tiny teeth and hissing in fear at a young man's gently outstretched hand, a faint thin scratch on the back of his hand. Dim dusk room, the pain of being forgotten by the one you love. Soft sorrowful light, NO gore."
gen "$CGD/cg_empty_tomb.png" "$CHD/shen_resolve.png" "$CG By torchlight a young man in dark night-clothes kneels before a pried-open stone cenotaph; inside lies only a single sword on dark cloth — no body. His face is shocked and grim, dawning horror. Cold blue tomb light, ominous revelation. NO gore."
gen "$CGD/cg_gu_crack.png" "$CHD/gu_mad.png" "$CG Close dramatic shot: a gentle compassionate white-robed holy lord's serene mask shatters for the first time into raw anguish and fury, tears and rage together, blinding golden altar light behind him, a 3000-year grief breaking loose. Intense, operatic, cold gold and shadow."
echo "DONE-WAVE2 $(date '+%m-%d %H:%M')" >> "$LOG"
