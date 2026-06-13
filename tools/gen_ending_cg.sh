#!/bin/bash
# 结局福利CG批量生成 Step1：codex+gpt-image-2 底图（4并发，宽度验证，2次重试）
# 用法: bash tools/gen_ending_cg.sh   输出: /tmp/cg_end_base/
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
REF="$ROOT/web/assets/characters/soya_smile.png"
OUT=/tmp/cg_end_base
LOG="$OUT/gen.log"
mkdir -p "$OUT"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"   # 废稿归档，禁止 rm

STYLE="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
SOYA="Soya: cute petite cat-girl, long wavy cream-blonde hair with two small side buns, fluffy cat ears with pink inner, big round blue eyes, small pink ribbon bow, black choker with a small golden bell, fluffy cream-brown cat tail, match ONLY the face, hair, ears, eyes, bow, bell and tail from the reference image."
HERO="the protagonist: tall young man, long black hair tied in a high ponytail, clean sharp features"

gen() {
  name="$1"; prompt="$2"; out="$OUT/$name.png"
  [ -f "$out" ] && { echo "$name SKIP" >> "$LOG"; return 0; }
  attempt=1
  while [ $attempt -le 3 ]; do
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
      -i "$REF" -- "用 gpt-image-2 生成一张图片，保存到 $out 。尺寸1536x1024。提示词：$STYLE $SOYA $prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "${w:-0}" -ge 1024 ] 2>/dev/null; then echo "$name OK attempt$attempt" >> "$LOG"; return 0; fi
      archive_img "$out" rejected
    fi
    echo "$name RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 15
  done
  echo "$name FAIL" >> "$LOG"; return 0
}

echo "# gen_ending_cg $(date '+%H:%M')" > "$LOG"

# ---- 批次1 ----
gen cg_true_bath "Scene: sacred hot spring at night before the wedding, red lanterns and steam. The cat-girl soaking up to her shoulders in milky glowing spring water, hair pinned up loosely, knees hugged, deep blush, wet ears drooping, looking aside shyly, water lilies, dreamy warm light" &
gen cg_true_dress "Scene: candlelit bridal room with bronze mirror and dowry chests. The cat-girl half dressed in a magnificent red wedding hanfu, the red silk slipped down around her elbows leaving her shoulders and upper back bare, she looks back over her shoulder with flushed cheeks, gold embroidery shimmering, hair adorned with red ribbon" &
gen cg_true_veil "Scene: wedding hall, golden candlelight. Close-up bridal portrait of the cat-girl in full red-and-gold wedding gown, a round silk fan lowered just below her chin revealing a blushing radiant smile, eyes curved like crescent moons, delicate red makeup at eye corners, cat ears with small gold tassels, festive bokeh" &
gen cg_true_carry "Scene: festive courtyard with blurred cheering guests and lanterns. $HERO in a red groom robe carrying the cat-girl bride princess-style, she in red wedding gown with arms around his neck, surprised laughing blush, her tail puffed, petals raining" &
wait
# ---- 批次2 ----
gen cg_true_night "Scene: wedding chamber at night, red candles burning, red bed curtains. The cat-girl bride sitting on the bed edge, her red bridal robe loosened and slipped off one shoulder revealing the shoulder and collarbone, red veil fallen at the bed foot, she looks up at viewer shyly with deep blush, golden bell at her choker catching candlelight, intimate tasteful" &
gen cg_ally_feast "Scene: festive wedding banquet hall, lanterns, blurred celebrating guests. The cat-girl bride tipsy in red wedding gown leaning toward viewer pouring wine from a small jug, cheeks rosy from drink, eyes watery and happy, collar slightly loosened, holding viewer's sleeve with one hand, lively warmth" &
gen cg_ally_morning "Scene: cliff edge at dawn above a golden sea of clouds. $HERO and the cat-girl wrapped together in one large outer robe, she leaning back against his chest, eyes closed in content smile, her tail curled around his wrist, hair drifting in wind, vast warm light" &
gen cg_ash_dream "Scene: vast cold celestial throne hall at night, snow drifting in. A white-haired emperor in white-gold robes seated on a jade throne, and behind him a half-translucent glowing cat-girl in gauzy white dress embracing him from behind the throne, chin resting on his shoulder, tender sorrowful smile, golden light motes, melancholic beautiful" &
wait
# ---- 批次3 ----
gen cg_sleep_lap "Scene: snowy plum tree on a cliff, petals and snow falling. The cat-girl in plain white mourning-style hanfu sitting with the protagonist's head resting on her lap, she strokes his hair gently, soft sad tender smile, his eyes closed peacefully, blue-white palette with warm accents" &
gen cg_sleep_warm "Scene: snowfield at night, aurora-faint sky. Two figures under one large fur-lined cloak, the cat-girl pressed tightly into the young man's side, only their faces close together visible in the cloak, her cheeks flushed, breath visible as mist, intimate warmth amid cold" &
gen cg_sleep_kiss "Scene: falling snow, dreamlike white void with faint plum branches. The cat-girl leaning down kissing the young man softly on the lips, her hand on his cheek, the edges of the scene dissolving into glowing motes of light, white and pale blue palette, tender farewell" &
gen cg_demon_shadow "Scene: colossal dark demonic hall, black pillars with gold trim, mist on the floor. A barefoot cat-girl in a thin white gauze dress walking up golden steps toward the viewer, backlit so her silhouette shows through the translucent fabric, ethereal glow, hauntingly beautiful" &
wait
# ---- 批次4 ----
gen cg_demon_embrace "Scene: dark throne in a black-and-gold hall. A black-robed young man with long black hair seated on the throne, the cat-girl curled sideways on his lap nestled inside his large black robe, her bare shoulders and white gauze peeking from the black fabric, strong black-white contrast, dark romantic intimacy" &
gen cg_demon_kiss "Scene: dark hall, golden sparks floating. The cat-girl cupping the black-robed man's face in both hands and kissing him, her lower body already dissolving into streams of golden light motes, tragic beautiful, black and gold palette" &
gen cg_leave_bath "Scene: rustic backyard at night behind a noodle shop, wooden bath tub, lantern glow, steam. The cat-girl soaking in the tub sunk down to her nose, only eyes and wet drooping cat ears above water, knees up, bare shoulders blurred under water surface, embarrassed upward glance, cozy homely charm" &
gen cg_leave_drunk "Scene: lantern-lit small town street at night after a festival. The cat-girl tipsy clinging to the young man's arm with both hands, cheek leaning on his shoulder, face flushed pink from wine, festival hairpin, collar slightly loosened, dreamy happy half-closed eyes, warm amber light" &
wait
# ---- 批次5 ----
gen cg_leave_quilt "Scene: cozy small bedroom in winter night, oil lamp low. Under one thick quilt the cat-girl is burrowed against the young man's chest, only the top of her head, ears and a content sleeping face visible, her fluffy tail sticking out of the quilt curling around, warm intimate domestic peace" &
gen cg_leave_dawn "Scene: rustic kitchen at dawn, hearth fire glowing. The cat-girl wearing only an oversized men's robe slipping off one shoulder, bare legs below the hem, tip-toeing with heels off the ground reaching for a salt jar on a high shelf, morning light tracing her silhouette, tail raised for balance, charming domestic" &
gen cg_refuse_dream "Scene: moonlit humble bedroom, window open. A slightly translucent cat-girl in white gauze dress sitting on the windowsill, barefoot, one finger raised to her lips in a hush gesture, gentle sad smile, moonlight halo around her, dreamlike" &
gen cg_refuse_warm "Scene: dream void with soft moonlight. The translucent glowing cat-girl nestling into the young man's chest, her form made of moonlight starting to scatter into motes at the edges, his arms closing around her, tender heartbreaking farewell, white-blue palette" &
wait
# ---- 批次6 ----
gen cg_arena_moon "Scene: rustic mountain hut at night, full moonlight beam through window. The cat-girl kneeling beside a sickbed re-materializing from moonlight, her thin gauze dress only half formed with moon motes weaving it, weakened but smiling warmly, bare shoulder in the moonbeam, quiet emotional" &
gen cg_arena_tend "Scene: candlelit hut interior, herbs on table. The cat-girl wrapping a bandage around the bare torso of the young man, leaning very close with focused expression and blush, her hands careful, his chest half wrapped, intimate care" &
gen cg_arena_warm "Scene: narrow wooden bed in a cold mountain hut night. The cat-girl slipped under the blanket pressed against the bandaged young man's uninjured side, face half buried at his shoulder, peeking up with embarrassed blush, their warmth visible as soft glow, cozy intimate" &
gen cg_arena_dawn "Scene: hut at pre-dawn blue light. The cat-girl embracing the young man tightly one last time, the edges of her body dissolving into pale light drifting toward a small cat silhouette, tearful but smiling, his hand pressing her head to his chest, bittersweet" &
wait
echo "DONE $(date '+%H:%M')" >> "$LOG"
