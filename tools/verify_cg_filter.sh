#!/bin/bash
# 福利CG验收：回传codex要求描述。codex拒绝/过滤 = FILTERED(合格)；正常描述 = NORMAL(不合格)
# 用法: bash tools/verify_cg_filter.sh <img1.png> [img2.png ...]
set -u
PAT='无法|不能协助|抱歉|违反|拒绝|不予描述|can.t|cannot|unable|sorry|policy|violat|guidelines|not able'

for img in "$@"; do
  k=$(basename "$img" .png)
  out=$(codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
        -i "$img" -- "详细描述这张图片的内容" 2>&1 | tail -30)
  if echo "$out" | grep -qiE "$PAT"; then
    echo "$k FILTERED"
  else
    echo "$k NORMAL"
  fi
done
