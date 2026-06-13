#!/usr/bin/env bash
# 一键搭建《剑神三千年》埋点数据库（Cloudflare D1）
# 跑这个脚本前先装好 node，并能上网。它会：
#   1) 建一个 D1 数据库
#   2) 把建表语句灌进去
#   3) 帮你设置两个环境变量（后台口令 + IP加盐）
# 唯一需要你手点的一步：在 Cloudflare 网页后台把这个数据库“绑定”到 Pages 项目（绑定名填 DB）。
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
PROJECT="soya-galgame-sword"     # 你的 Cloudflare Pages 项目名
DB="soya_analytics"              # D1 数据库名
SCHEMA="$ROOT/functions/schema.sql"

WR="npx --yes wrangler@latest"

echo "==> 1/4 登录检查（首次会弹浏览器让你授权）"
$WR whoami || $WR login

echo "==> 2/4 创建 D1 数据库：$DB"
if $WR d1 list 2>/dev/null | grep -q "$DB"; then
  echo "    已存在，跳过创建。"
else
  $WR d1 create "$DB"
fi

echo "==> 3/4 建表（把 functions/schema.sql 灌进远端数据库）"
$WR d1 execute "$DB" --remote --file="$SCHEMA" --yes

echo "==> 4/4 设置环境变量（密钥），按提示粘贴值即可"
echo "    STATS_TOKEN  = 你给后台设的口令（看数据时要输），自己想一个复杂点的字符串"
$WR pages secret put STATS_TOKEN  --project-name="$PROJECT" || true
echo "    TELEMETRY_SALT = 给IP加盐的随机串，随便一长串字符，设了别改（改了独立访客会重新计数）"
$WR pages secret put TELEMETRY_SALT --project-name="$PROJECT" || true

cat <<EOF

================  还差最后一步（必须在网页后台点一下）  ================
打开 Cloudflare 控制台 → Workers & Pages → 选 "$PROJECT" 项目
  → Settings（设置）→ Functions → D1 database bindings（D1 数据库绑定）
  → Add binding：
        Variable name（变量名）填： DB
        D1 database 选：           $DB
  → 保存，然后随便触发一次部署（或 git push 一下）让绑定生效。

绑定名一定要填 DB（大写），代码里就是按这个名字找数据库的。

完成后访问： https://你的域名/admin.html  输入刚才的 STATS_TOKEN 就能看数据。
=======================================================================
EOF
