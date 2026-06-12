#!/bin/bash
# 修正11张问题CG + cg_betrayal（方向/构图/角色一致性全部订正）
# 每张备份原图到 design/cg_backup/，生成后验宽>=1024才保留，最多3次重试
set -u
CG_DIR="/Users/b1lli/Documents/soya_galgame3/web/assets/cg"
BAK_DIR="/Users/b1lli/Documents/soya_galgame3/design/cg_backup"
LOG="/Users/b1lli/Documents/soya_galgame3/design/gen_fix_cg.log"
SOYA_REF="/Users/b1lli/Documents/soya_galgame3/web/assets/characters/soya_smile.png"
CAT_REF="/Users/b1lli/Documents/soya_galgame3/web/assets/characters/cat_normal.png"

mkdir -p "$BAK_DIR"
echo "# gen_fix_cg $(date '+%Y-%m-%d %H:%M')" > "$LOG"

STYLE="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
SOYA="Soya: cute petite cat-girl, long wavy cream-blonde hair with two small side buns, fluffy cat ears (cream fur, pink inner), big round vivid blue eyes, small pink ribbon bow on her hair, black choker with a small golden bell, fluffy cream-brown cat tail. OUTFIT: white cross-collar top with wide flowing sleeves, high-waisted pastel-pink ruqun skirt with layered white gauze, long floating pink silk ribbons (piaodai) drifting around her arms, light-blue sash accents. Match face, hair, ears, eyes, bow, bell and tail from the reference image; keep the xianxia hanfu outfit."
HERO="protagonist: tall young man, long black hair tied neatly in a high ponytail, sharp dark eyes, clean features"

gen() {
  local name="$1"
  local refs="$2"   # soya | cat | none
  local prompt="$3"
  local out="$CG_DIR/$name.png"

  # backup
  if [ -f "$out" ]; then cp "$out" "$BAK_DIR/${name}_bak.png"; fi

  local attempt=1
  while [ $attempt -le 3 ]; do
    echo "[$(date +%H:%M:%S)] $name attempt$attempt" | tee -a "$LOG"
    rm -f "$out"

    if [ "$refs" = "soya" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
        -i "$SOYA_REF" \
        -- "NOGIT. Use gpt-image-2 to generate a 1536x1024 PNG. Save to: $out

$STYLE $SOYA $HERO

Scene: $prompt" >/dev/null 2>&1
    elif [ "$refs" = "cat" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
        -i "$CAT_REF" \
        -- "NOGIT. Use gpt-image-2 to generate a 1536x1024 PNG. Save to: $out

$STYLE Cat form: small cream-white fluffy cat, pink ribbon bow on ear, golden bell on collar, vivid blue eyes. Match the reference cat exactly.

Scene: $prompt" >/dev/null 2>&1
    else
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
        -- "NOGIT. Use gpt-image-2 to generate a 1536x1024 PNG. Save to: $out

$STYLE $HERO

Scene: $prompt" >/dev/null 2>&1
    fi

    if [ -f "$out" ]; then
      local w
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "${w:-0}" -ge 1024 ] 2>/dev/null; then
        echo "$name OK width=$w" | tee -a "$LOG"
        return 0
      fi
      rm -f "$out"
    fi
    echo "$name RETRY" | tee -a "$LOG"
    attempt=$((attempt+1))
    sleep 15
  done
  echo "$name FAIL" | tee -a "$LOG"
}

# ── 1. cg_betrayal ─────────────────────────────────────────────────────────────
# 问题：剑从正面穿出（被背刺），视角应正面，画面要干净
gen cg_betrayal none \
"Memory flashback. A colossal white-jade ascension platform soaring above a sea of golden clouds, white jade columns framing the sides. A white-robed young swordsman with long loose flowing black hair is shown in a CLEAN FRONTAL VIEW (full body, face toward viewer). A sword blade PIERCES OUTWARD FROM THE CENTER OF HIS CHEST pointing toward the viewer — he was stabbed through the back, the blade tip now protrudes from the front of his robes. Arms falling open helplessly. Expression: tragic shock and grief, tears on his face. Golden light shattering like glass shards bursting outward around him. Visible just behind his right shoulder: a blurred silver-haired figure retreating. Clean composition, no visual clutter, strong emotional impact. Tragic, devastating."

# ── 2. cg_confront ─────────────────────────────────────────────────────────────
# 问题：主角持完整剑，应持断剑（剑刃断去一半）
gen cg_confront none \
"On a colossal ascension altar platform floating high above storm clouds, lightning cracking the sky. A silver-haired white-robed holy lord stands atop glowing golden ritual circles at the UPPER portion of the frame, looking down with cold authority. Below him at lower-center: the protagonist in white xianxia robes (long black hair in high ponytail) holds a BROKEN SWORD upward defiantly — the blade is snapped off halfway, leaving only a jagged half-blade — pointing it directly up at the holy lord despite its brokenness. Wind, torn robes, dramatic upward-looking perspective. Defiant versus imposing."

# ── 3. cg_wanjian ──────────────────────────────────────────────────────────────
# 问题：仰视视角，应为俯视（上帝视角向下）
gen cg_wanjian none \
"STRICT GOD'S-EYE BIRD'S-EYE VIEW, camera pointing STRAIGHT DOWN from high above. The entire frame is filled with a sea of ten thousand ancient flying swords, all oriented POINTING DOWNWARD, converging from every direction toward a single tiny lone white-robed figure standing on a small stone altar far below at the bottom-center of the frame. The swords are visible above and around, densely packed, blotting out the sky. The lone figure below appears very small, almost ant-like. Golden dawn light, clouds parting from the sword formations. Blinding, overwhelming scale. The perspective must be looking DOWN from above — aerial overhead view."

# ── 4. cg_tomb_bow ─────────────────────────────────────────────────────────────
# 问题：剑竖直站立，应弯曲躬身如老臣叩首
gen cg_tomb_bow none \
"Close-up shot inside an ancient underground sword tomb cavern lit by green-blue ghost light. The focal point: a single ancient rusted sword that has half-emerged from cracked stone floor, but its BLADE CURVES DEEPLY DOWNWARD IN A BOW — like an elderly court minister performing a deep prostration of reverence. The tip of the curved blade nearly touches the ground. The sword is visibly bent in a deep, respectful bowing shape. The protagonist's hand (white xianxia sleeve) gently rests on the curved spine of this bowing blade, touching it tenderly. In the dark background, dozens of other ancient swords are also visible in various degrees of bowing their blades. The emotion: reverence, recognition, moving. A sword paying its respects to its true master."

# ── 5. cg_stairs ───────────────────────────────────────────────────────────────
# 问题：袍发向后飘，应向上冲；垂直构图感不足
gen cg_stairs none \
"Vertical epic composition. A colossal white-jade ceremonial staircase ascends toward a blinding source of golden divine light at the TOP of the frame. The protagonist (long black hair in high ponytail, white xianxia robes) climbs UPWARD step by step, pushing against crushing heavenly pressure descending from above. His white robes and long black hair are BLASTED DRAMATICALLY UPWARD toward the golden light above — the fabric billows and streams upward above his head, the hair rises toward the sky, as if a divine pressure from above pushes everything upward. Each step he has already passed glows with a circular golden ring of cracked breakthrough light. White-robed kneeling priests line both sides of the stairway, looking up at him in awe. Strong upward vertical thrust throughout the composition. 'This is not breaking through — this is returning to one's true place.'"

# ── 6. cg_moon_reveal ──────────────────────────────────────────────────────────
# 问题：开心大笑，应害羞微笑；双臂张开，应单手伸向观众
gen cg_moon_reveal soya \
"Full moon night over a misty bamboo grove with drifting fireflies. Soya the cat-girl (use reference image for face, hair, ears, eyes, bow, bell, tail) materializes standing ABOVE the surface of a still reflecting pool, in a gentle swirl of pale-pink light petals rising around her. Her expression: a GENTLE SHY SMILE — closed lips curved softly, head slightly tilted to one side, eyes warm and slightly bashful, a delicate blush on her cheeks. ONE hand extends gently and gracefully OUTWARD toward the viewer in a welcoming gesture; the other hand rests at her side. She is NOT laughing or grinning widely — strictly a quiet, shy, delicate smile. Soft moonlight halos around her. Magical, ethereal, gentle."

# ── 7. cg_liu_kneel ────────────────────────────────────────────────────────────
# 问题：双膝叩首，应单膝跪礼
gen cg_liu_kneel none \
"Rainy night before an ancient stone law hall doorway with warm lantern light spilling from within. An old stern-faced man in grey xianxia robes performs a formal SINGLE-KNEE KNEEL: his LEFT knee is pressed on the wet stone flagstones, his right knee is raised and bent, one fist is pressed formally to the stone beside his kneeling knee, his head is bowed with remaining dignity — this is a formal one-knee bow of submission, NOT a full prostration with both knees or forehead to ground. Before him stands a calm composed young man with long black hair in high ponytail wearing white xianxia robes, looking down at the kneeling elder. Rain on wet stone, lantern reflections in puddles. A moment of profound significance."

# ── 8. cg_end_true ─────────────────────────────────────────────────────────────
# 问题：Soya自己拿鱼干，应男主递鱼干给Soya；无窗台场景
gen cg_end_true soya \
"Morning scene. A windowsill in warm golden sunrise light, curtains and window frame visible. Soya (use reference for face, hair, ears, eyes, bow, bell, tail, xianxia hanfu) sits on the windowsill having just woken up, blinking with sleepy eyes, a warm gentle smile on her face, tears of joy glistening on her cheeks. FROM THE LEFT SIDE of the frame: the protagonist's arm and hand reach in, clearly extending a small wrapped packet of dried fish OUTWARD TOWARD SOYA — he is the one offering and giving the food to her. His face may be visible at the left edge looking at her warmly. Soya is the recipient. Morning sunshine, joyful, tender reunion."

# ── 9. cg_end_leave ────────────────────────────────────────────────────────────
# 问题：猫耳完全裸露，应被兜帽遮住仅露出尖；两人非并排
gen cg_end_leave soya \
"Warm dusk light. A humble rustic roadside noodle stall in a small mountain town, warm amber lanterns hanging above. Soya (face, hair, eyes from reference) is wearing a travelling hooded cloak that MOSTLY COVERS her cat ears — the hood is pulled up, with only the very pointed tips of her cat ears barely poking through the fabric of the hood. She and the protagonist (long black hair ponytail, plain dark travel clothes) sit SIDE BY SIDE on the same wooden bench, shoulders close together, happily eating noodles from bowls, leaning slightly toward each other, relaxed and content. A cloth-wrapped bundle with the silhouette of a sword inside leans against the bench leg beside them. Cozy, warm, everyday happiness in hiding."

# ── 10. cg_auction ─────────────────────────────────────────────────────────────
# 问题：展示的是完整剑，应只是断剑残段（上三分之一）
gen cg_auction none \
"Inside an ornate auction hall with red silk hangings and silhouetted bidders and auctioneers in the background. On a raised display pedestal covered with red silk sits ONLY A BROKEN RUSTY SWORD TIP — just the upper broken section of an ancient sword, approximately the top third of a blade length, heavily corroded with rust, with a ragged jagged break at the bottom where it was severed long ago. This is a fragment, a relic. In the foreground, the protagonist (long black hair in high ponytail, grey-blue xianxia robes) gazes at this ancient fragment, his EYES REFLECTING a subtle mysterious GOLDEN INNER GLOW from the broken blade — his pupils faintly lit gold, his expression arrested with recognition and reverence. Dramatic spotlight on the broken relic. The bidders around him see only junk; he alone perceives its true nature."

# ── 11. cg_sword_tomb ──────────────────────────────────────────────────────────
# 问题：万剑无躬身动态；Soya拉手而非拉袖
gen cg_sword_tomb soya \
"Epic wide shot inside a vast underground ancient sword tomb cavern of cathedral scale. Green-blue ghost light emanates from below. The protagonist (long black hair in high ponytail, white xianxia robes) walks at the center of a wide stone aisle. Soya (use reference for face, hair, ears, eyes, bow, bell, tail, hanfu) walks beside him and reaches out with one hand to grip the SLEEVE of his robe at the wrist — holding his sleeve not his hand. On both sides of the aisle extending into the far distance: thousands of ancient swords in their stone sheaths all LEAN AND BOW THEIR BLADES TOWARD THE PROTAGONIST — the blades physically incline forward at an angle, tips dipping in reverent obeisance like rows of soldiers bowing, the motion rippling outward in both directions as far as the eye can see. Overwhelming epic scale. Emotional, momentous."

echo "DONE $(date '+%H:%M:%S')" | tee -a "$LOG"
