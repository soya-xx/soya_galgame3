#!/bin/bash
# 二次增强：对暧昧CG用 grsai nano-banana-pro + 锚图(锁一致) + AMP1(渐进减布料)
# 生成到 /tmp/cg_horny/，不自动装载，人工复核后再装。失败/被拒则跳过保留原版。
set -u
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ANCHOR="$ROOT/web/assets/characters/soya_smile.png"
OUT=/tmp/cg_horny
LOG="$OUT/log.txt"
mkdir -p "$OUT"; echo "# horny_pass $(date '+%H:%M')" > "$LOG"

KEYS="cg_reforge_close cg_bed_morning cg_morning_dress cg_check_bone cg_tail_groom cg_sword_sleep cg_peek_splash cg_cling_cry cg_spring cg_arena_tend"

for k in $KEYS; do
  src="$ROOT/web/assets/cg/$k.png"
  [ -f "$src" ] || { echo "$k NO_SRC" >> "$LOG"; continue; }
  ok=0
  for try in 1 2 3; do
    if ANCHOR="$ANCHOR" AMP=1 python3 "$ROOT/tools/enhance_cg.py" "$src" "$OUT/$k.png" "$k" >>"$LOG" 2>&1; then
      echo "$k ENHANCED try$try" >> "$LOG"; ok=1; break
    fi
    echo "$k retry$try refused" >> "$LOG"; sleep 2
  done
  [ $ok -eq 0 ] && echo "$k KEEP_ORIGINAL(3次被拒)" >> "$LOG"
done
echo "DONE $(date '+%H:%M')" >> "$LOG"
echo "成功: $(grep -c ENHANCED "$LOG") / 保留原版: $(grep -c KEEP_ORIGINAL "$LOG")"
