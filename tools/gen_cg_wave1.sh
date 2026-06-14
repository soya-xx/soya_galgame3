#!/bin/bash
# CG 扩充 Wave1：6 羁绊身世闪回 + 7 羁绊结局收束定格。串行，锚图锁画风/角色一致。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"; CHD="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-cg-wave1.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"
CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy. 横构图 landscape 1536x1024."

gen() { out="$1"; ref="$2"; prompt="$3"; base=$(basename "$out")
  if [ -f "$out" ]; then echo "$base SKIP(exists)" >> "$LOG"; return 0; fi
  a=1; while [ $a -le 3 ]; do
    [ -f "$out" ] && archive_img "$out" rejected
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK a$a" >> "$LOG"; return 0; fi; fi
    echo "$base RETRY a$a" >> "$LOG"; a=$((a+1)); sleep 10
  done; echo "$base FAIL" >> "$LOG"; }

echo "# CG Wave1 $(date '+%m-%d %H:%M')" >> "$LOG"
# 身世闪回（偏冷色、回忆质感）
gen "$CGD/cg_shen_kneel.png" "$CHD/shen_proud.png" "$CG A cold memory: a ~10-year-old boy in fine robes kneels utterly alone on the stone floor of a vast dim ancestral hall, rows of memorial tablets towering above him, three days of exhaustion on his small face. Loneliness, harsh discipline, cold blue dawn light from high windows. Melancholy flashback tone."
gen "$CGD/cg_zhou_vigil.png" "$CHD/zhou_worry.png" "$CG An old man sits keeping vigil at a sick bed deep in the night, a small clay medicine pot warming on a stove, his paralyzed elderly mother asleep under a thin quilt. He tucks her blanket with worn hands. Warm dim lamplight, quiet filial devotion, twenty years of patience in his posture. Tender, sad."
gen "$CGD/cg_luo_wall.png" "$CHD/luo_joy.png" "$CG A 12-year-old girl with a big red silk flower in her hair peeks over a low courtyard wall, eyes shining with longing, watching disciples practice sword in the distance. Innocent yearning, warm afternoon light, she does not yet know what 'ascending to heaven' costs. Bittersweet."
gen "$CGD/cg_liu_fire.png" "$CHD/liu_warm.png" "$CG A flashback 3000 years ago: a powerful swordsman pulls a small soot-covered child out of a burning village at night, embers and smoke everywhere, the child clinging to him. The last child saved from the flames. Heroic, warm firelight against dark, the origin of a family's vow. NO gore."
gen "$CGD/cg_xuanyi_village.png" "$CHD/xuanyi_polite.png" "$CG A bleak flashback: a tiny 3-year-old child sits utterly alone amid a destroyed silent village at dusk, the sole survivor, a tall white-robed figure approaching to lift him from the ruins. Desolate, ashen grey palette, faint cold hope in the approaching figure. Somber, NO gore, NO bodies shown."
gen "$CGD/cg_qian_starve.png" "$CHD/qian_fear.png" "$CG A grim quiet memory: a thin frightened child crouches in a bare cold hut during a famine, watching a family member lying still and weak under a ragged blanket, an empty rice bowl on the dirt floor. Cold grey-brown palette, hunger and helpless fear. Somber, restrained, NO gore."
# 结局收束定格
gen "$CGD/cg_shen_grave.png" "$CHD/shen_resolve.png" "$CG On a misty cliff (Listening-Rain Cliff), a simple stone grave with an unsheathed sword laid before it, dawn light, falling petals. A quiet memorial to a young sword cultivator. Peaceful, melancholy, no people, reverent."
gen "$CGD/cg_liu_lantern.png" "$CHD/liu_warm.png" "$CG A single warm paper lantern glows at the doorway of an old residence at night, kept eternally lit, empty quiet courtyard, gentle snow or rain. A lamp lit for someone who will never return. Lonely, warm-against-dark, deeply melancholy."
gen "$CGD/cg_xuanyi_bow.png" "$CHD/xuanyi_cruel.png" "$CG A one-armed man in tattered white-gold robes kneels among broken altar stones and bows deeply toward a vast canopy of swords filling the sky, atoning with his last strength. Cold dawn light, falling ash, a believer's final penance. Solemn, tragic, NO gore."
gen "$CGD/cg_qian_grave.png" "$CHD/qian_fear.png" "$CG A small crude wooden grave marker stands in a quiet meadow, a little girl with a red flower kneeling beside it having just finished writing clumsy characters on it. Soft warm light, childlike grief and tenderness. Touching, gentle, melancholy."
gen "$CGD/cg_zhou_bowl.png" "$CHD/zhou_smile.png" "$CG A single bowl of steaming rice placed on the worn ledge of an old kitchen stove, the rest of the chore-hall empty, warm morning light through a small window, a worn ladle nearby. An offering for someone gone. Quiet, warm, aching nostalgia, no people."
gen "$CGD/cg_luo_bury.png" "$CHD/luo_cry.png" "$CG A girl kneels at a small grave and buries a big red silk flower in the earth before it, tears on her face but calm, soft overcast light. Saying goodbye to childhood illusions and to her mother. Gentle, sorrowful, restrained."
gen "$CGD/cg_gu_descend.png" "$CHD/gu_calm.png" "$CG A gentle white-robed man walks down endless celestial stone stairs away from a towering altar, his back to us, his step visibly lighter, a 3000-year burden lifted, soft gold light ahead. Bittersweet freedom, serene, melancholy."
echo "DONE-WAVE1 $(date '+%m-%d %H:%M')" >> "$LOG"
