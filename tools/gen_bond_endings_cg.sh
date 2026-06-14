#!/bin/bash
# 羁绊结局群·新增CG（八记结局用，复用旧图为主，仅补七张关键CG）。
# 务必单进程串行(并发会串图)。锚图锁角色一致性、画风一致(高质量动漫视觉小说)。
# 资产铁律：禁裸删/裸覆盖，统一走 archive_img.sh；每图 record_model 登记模型。
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CGD="$ROOT/web/assets/cg"
CHD="$ROOT/web/assets/characters"
LOG="$ROOT/design/asset-status-bond-endings.md"
NOGIT="只生成并保存图片文件；不要执行任何git操作，不要创建issue，不要提交代码。"
IMG_MODEL=gpt-image-2
source "$ROOT/tools/lib/archive_img.sh"

CG="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy. 横构图 landscape 尺寸1536x1024."
MC="the male lead: a young man with long black hair in a high ponytail, plain grey-blue disciple robe, a faint old scar on one bare shoulder, sharp calm eyes"
SHEN="Shen Qinglan — EXACTLY the same young man as the reference: proud handsome face, black hair, dark/black robe (formerly moon-white), a young sword cultivator"
LIU="Elder Liu Changqing — EXACTLY the same old man as the reference: stern aged face, grey hair and beard, a long old burn scar down the left cheek, plain cloth robe"
XUANYI="Xuanyi the holy envoy — EXACTLY the same person as the reference: refined pale face, white-gold priestly robe, here with ONE arm only (the other sleeve empty)"
ZHOU="Old Zhou — EXACTLY the same kindly old man as the reference: weathered round face, short grey hair, shabby chore-hand robe"
LUO="Luo, a 12-year-old girl — EXACTLY the same child as the reference: round innocent face, simple disciple clothes, a big red silk flower in her hair"
GU="Gu Changsheng — EXACTLY the same man as the reference: gentle compassionate face, flowing white holy-lord robe"
SOYA="Soya the cat-girl in human form — EXACTLY the same character as the reference: cream-blonde wavy hair with two side buns, white cat ears, big blue eyes, white cross-collar wide-sleeve top, pastel-pink ruqun skirt, a golden bell on a black choker"

# gen <out> <ref> <prompt>
gen() { out="$1"; ref="$2"; prompt="$3"; base=$(basename "$out")
  if [ -f "$out" ]; then echo "$base SKIP(exists)" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 3 ]; do
    [ -f "$out" ] && archive_img "$out" rejected
    codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$ref" -- "用 gpt-image-2 生成一张图片，保存到 $out 。$NOGIT 提示词：$prompt" >/dev/null 2>&1
    if [ -f "$out" ]; then
      mt=$(( $(date +%s) - $(stat -f %m "$out") )); w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "$mt" -lt 1200 ] && [ "${w:-0}" -ge 1024 ] 2>/dev/null; then record_model "$out" "$IMG_MODEL"; echo "$base OK attempt$attempt" >> "$LOG"; return 0; fi
    fi
    echo "$base RETRY attempt$attempt" >> "$LOG"; attempt=$((attempt+1)); sleep 12
  done
  echo "$base FAIL" >> "$LOG"
}

echo "# 羁绊结局CG $(date '+%m-%d %H:%M')" >> "$LOG"

gen "$CGD/cg_shen_fall.png" "$CHD/shen_resolve.png" \
  "$CG $SHEN. On a shattered white-jade sky altar amid a sea of floating swords, $SHEN throws himself in front of $MC and takes a beam of black sword-light through his chest, shielding the other man. Determined faint smile, a red silk flower falling from his chest into the cloud sea below. Heroic tragic sacrifice, golden light and black light clashing, dramatic. NO gore, only impact, tasteful."

gen "$CGD/cg_liu_legacy.png" "$CHD/liu_warm.png" \
  "$CG $LIU. The old man stands before an exploding ancestral sword-chest; hundreds of ancestral swords burst upward into a sky-filling sword sea, lending their light. He raises one hand in a final salute, the burn scar on his cheek lit gold, expression proud and at peace, life force spending itself. Epic, bittersweet, golden dusk. NO gore."

gen "$CGD/cg_xuanyi_break.png" "$CHD/xuanyi_cruel.png" \
  "$CG $XUANYI. Close shot of the one-armed envoy kneeling among broken altar stones, looking up at a sky full of swords with an expression of total faith collapse — eyes wide, hollow, a man whose whole belief just shattered. Cold pale light, falling ash, empty sleeve where one arm should be. Quiet devastation, spine of a believer broken. NO gore."

gen "$CGD/cg_zhou_carry.png" "$CHD/zhou_smile.png" \
  "$CG $ZHOU. The exhausted old man struggles up endless white-jade celestial stairs carrying a bamboo basket on a shoulder-pole, a small cream-white cat poking its head out of the basket, dried fish scattered on the steps behind him. He is collapsing from effort yet smiling, pushing on. Vast misty sacred mountain above, warm late light. Moving, heroic-of-the-humble, melancholy."

gen "$CGD/cg_luo_altar.png" "$CHD/luo_cry.png" \
  "$CG $LUO. The small girl stands alone and tiny at the front of an enormous sacrificial altar, a big red silk flower in her hair, golden sacrificial light rising around her, looking up with dawning terrified understanding. Overwhelming scale of the altar dwarfing the child, cold gold light, a single small figure. Heartbreaking, NO gore."

gen "$CGD/cg_gu_release.png" "$CHD/gu_calm.png" \
  "$CG $GU. At the foot of a towering heavenly altar throne, $GU kneels and finally weeps with relief, setting down a charred old sword-tassel on the steps, his face freed of a 3000-year burden. Above and behind, a faint silhouette of $MC ascending into blinding golden pillar-light to take his place. Bittersweet redemption, one man freed, one man imprisoned, cold gold and warm tears."

gen "$CGD/cg_king_dawn.png" "$CHD/soya_smile.png" \
  "$CG $SOYA. A radiant dawn panorama on a cliff (Listening-Rain Cliff): $SOYA in human form and $MC sit together, the first cooking smoke rising; in soft focus behind them a sky-canopy of countless swords arches over a peaceful human world, tiny happy figures of saved companions in the distance. Everyone alive, warm golden sunrise, hopeful, the perfect ending. Tender, luminous, no text."

echo "DONE-BOND-ENDINGS $(date '+%m-%d %H:%M')" >> "$LOG"
