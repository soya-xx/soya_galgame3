#!/bin/bash
# 串行补齐缺失CG（macOS bash 3.2 兼容版）：跳过已存在文件，逐张验证，全程留痕
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
CG_DIR="$ROOT/web/assets/cg"
LOG="$ROOT/design/asset-status-cgfinal.md"
REF1="$HOME/Documents/向向皮套素材assets/微信图片_20260611014516_8_3702.png"
REF2="$HOME/Documents/向向皮套素材assets/微信图片_20260611014547_12_3702.png"
CATREF="$ROOT/web/assets/characters/cat_normal.png"
STYLE="high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers."
SOYA="Soya: cute petite cat-girl, long wavy cream-blonde hair with two small side buns, fluffy cat ears with pink inner, big round blue eyes, small pink ribbon bow on head with white frilled lolita headband, black choker with a small golden bell, pink off-shoulder blouse with white frilled apron dress, cocoa-brown layered frill skirt with light-blue ribbons, white knee socks, fluffy cream-brown cat tail, exactly match the reference character design."

gen() {
  name="$1"; refs="$2"; prompt="$3"
  out="$CG_DIR/$name.png"
  if [ -f "$out" ]; then echo "$name SKIP 已存在" >> "$LOG"; return 0; fi
  attempt=1
  while [ $attempt -le 3 ]; do
    if [ "$refs" = "soya" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$REF1" -i "$REF2" "用 gpt-image-2 生成一张图片，保存到 $out 。尺寸1536x1024。提示词：$prompt" >/dev/null 2>&1
    elif [ "$refs" = "cat" ]; then
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check -i "$CATREF" "用 gpt-image-2 生成一张图片，保存到 $out 。尺寸1536x1024。提示词：$prompt" >/dev/null 2>&1
    else
      codex exec -m gpt-5.5 --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check "用 gpt-image-2 生成一张图片，保存到 $out 。尺寸1536x1024。提示词：$prompt" >/dev/null 2>&1
    fi
    if [ -f "$out" ]; then
      w=$(sips -g pixelWidth "$out" 2>/dev/null | awk '/pixelWidth/{print $2}')
      if [ "${w:-0}" -ge 1024 ] 2>/dev/null; then echo "$name OK attempt$attempt width=$w" >> "$LOG"; return 0; fi
      rm -f "$out"
    fi
    echo "$name RETRY attempt$attempt" >> "$LOG"
    attempt=$((attempt+1))
    sleep 20
  done
  echo "$name FAIL 3次未成" >> "$LOG"
  return 0
}

echo "# 最终CG补齐(v2) $(date '+%H:%M')" >> "$LOG"
gen cg_panel_truth soya "$STYLE $SOYA Scene: dark wooden room at blue night, Soya sleeping peacefully on a bed, translucent golden contract threads of light flowing out from her chest into a sword-shaped glow held in the hands of a young man with long black ponytail sitting beside, his face stricken with grief and shock, moonlight through window"
gen cg_envoy_strike none "$STYLE Scene: a slender courteous man in ornate black-and-gold robes releasing a colossal palm-shaped wave of dark light down upon a stone mountain gate, the stone archway shattering into flying debris, his robes whipping in the shockwave, terrifying power, low angle"
gen cg_gather none "$STYLE Scene: dawn light before a Chinese sect mountain gate, a small determined group setting out: in front a tall young man with long black high-ponytail in white robes carrying a slender sword, beside him an azure-robed handsome young swordsman and a stern grey-robed old man with white beard carrying a long wooden case, torn banners raised behind them, hopeful epic mood"
gen cg_end_ash none "$STYLE Scene: a white-haired young man in imperial white-gold robes sitting alone on a cold vast celestial jade throne in an empty colossal hall, holding a tiny golden bell gently in his open palm, looking down at it, one single shaft of light from above, desolate lonely atmosphere, wide shot emphasizing emptiness"
gen cg_end_sleep soya "$STYLE $SOYA but wearing a plain white mourning-style hanfu dress instead, sitting quietly on a snowy cliff edge beside a rusted broken sword stuck upright in stone, cracked golden bell at her neck, waiting patiently, falling snow, far lonely wide shot, blue-white palette, melancholic beautiful"
gen cg_end_demon none "$STYLE Scene: a black-robed young man with long black hair seated on a golden holy throne half in shadow, cold empty eyes, dark imposing hall, and far away outside the great golden door a small cat-shaped silhouette turning away to leave, strong contrast of warm gold light and cold black shadow, tragic"
gen cg_end_leave soya "$STYLE $SOYA wearing a hooded cloak over her dress with cat ears poking the hood up slightly, happily slurping a bowl of noodles at a small dusk-lit street noodle stall, steam rising, beside her a young black-ponytail man in plain clothes cooking noodles smiling faintly, a sword wrapped in seven layers of cloth leaning against the bench, warm amber lanterns, cozy peaceful"
gen cg_end_refuse cat "$STYLE Scene: dusk over old town rooftops, a small cream-colored fluffy cat with pink ribbon bow and golden bell choker sitting on a roof ridge, watching from afar a distant ordinary man in plain clothes walking home on the street below, melancholic warm orange light, lonely tender mood, the cat matches the reference cat design"
gen cg_end_arena none "$STYLE Scene: heavy rain falling on an empty stone martial arena at grey dusk, a shattered plain iron sword lying on wet flagstones, thin traces of blood dissolving in rainwater puddles, no people anywhere, cold grey-blue palette, quiet devastating stillness"
echo "DONE $(date '+%H:%M')" >> "$LOG"
