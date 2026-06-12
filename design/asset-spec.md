# 《剑神三千年》资产规格书

生成方式：本机 `codex exec` 调用 gpt-image-2。所有输出 PNG，放入 `/Users/b1lli/Documents/soya_galgame3/web/assets/` 对应子目录。

## 调用配方（每个图像代理照此执行）

```bash
codex exec --dangerously-bypass-approvals-and-sandbox --skip-git-repo-check \
  -i <参考图1> -i <参考图2> \
  "用 gpt-image-2 生成一张图片，保存到 <绝对路径输出文件>。尺寸 <SIZE>。<透明背景要求>。提示词：<PROMPT>"
```

- 立绘（characters/）：尺寸 1024x1536，**背景必须完全透明（alpha通道）**。
- 背景（backgrounds/）与 CG（cg/）与标题图（ui/）：尺寸 1536x1024，不透明。
- 每生成一张，必须用 `sips -g hasAlpha -g pixelWidth <file>` 验证文件存在且参数正确，再用读图工具目视检查：手指数量、肢体重复、构图、与提示词动作一致。不合格立即重生成（最多3次，仍不合格记入状态文件并继续下一张）。
- 状态记录：每完成/失败一张，向 `/Users/b1lli/Documents/soya_galgame3/design/asset-status-<agent>.md` 追加一行：`<文件名> OK/RETRY/FAIL <一句话备注>`。
- 先做 P0，全部 P0 完成后再做 P1。

## Soya 一致性（所有含向向的图必须附参考图）

参考图（用 -i 附带，最多2张）：
- `/Users/b1lli/Documents/向向皮套素材assets/微信图片_20260611014516_8_3702.png`（全身正面）
- `/Users/b1lli/Documents/向向皮套素材assets/微信图片_20260611014547_12_3702.png`（全身斜角+尾巴）

角色描述（嵌入每条相关提示词）【v2 仙侠风换装版，2026-06-12 起生效；v1 洛丽塔版已废弃，旧图备份于 design/old_outfit/】：
> Soya (向向): cute petite cat-girl, long wavy cream-blonde hair with two small side buns, fluffy cat ears (cream fur, pink inner), big round blue eyes, small pink ribbon bow on her hair, black choker with a small golden bell, fluffy cream-brown cat tail. OUTFIT (Chinese xianxia hanfu, NOT lolita): white cross-collar top with wide flowing sleeves, high-waisted pastel-pink ruqun skirt with layered white gauze, long floating pink silk ribbons (piaodai) drifting around her arms, light-blue sash and ribbon accents, subtle cat-paw embroidery, delicate embroidered shoes. Cute, petite, gentle, immortal-fairy aesthetic.
> 附皮套参考图时提示词必须写明：match ONLY the face, hair, ears, eyes, bow, bell and tail from the reference; REPLACE the outfit with the hanfu described。换装锚图（characters/soya_smile.png v2）确定后，后续含Soya图一律附锚图保持一致。

猫形态描述【v2 真猫化；不许人脸】：
> a real small cream-colored fluffy cat with proper feline head and anatomy: protruding short muzzle, pink nose, almond-shaped blue cat eyes set apart (NOT huge round forward-facing human-like anime eyes, NOT flat anthropomorphic face), small pink ribbon bow near one ear, black collar with a small golden bell. Cute kitten proportions but unmistakably a real cat.

其他角色一致性描述（不附参考图，靠文字锁定）：
- 主角（玩家，CG中出现）：tall young man, long black hair tied in a high ponytail, sharp dark eyes, plain grey-blue Chinese xianxia sect disciple robes（终章场景改 white robes）, carries a slender Chinese straight sword (jian)
- 沈青澜：handsome arrogant young swordsman, azure-blue brocade xianxia robes, silver hairpin, light-blue eyes
- 柳长青：stern old man, grey law-keeper robes, white beard tied with cord, iron token at waist
- 赵虎：burly smug young man, dark-green outer-disciple robes, shaved temples
- 玄一（圣使）：slender courteous man, black-and-gold ornate robes, half-closed smiling eyes, cold aura
- 顾长生（圣主）：ethereal man with long silver-white hair, flowing white holy robes with gold trim, gentle sorrowful face
- 老周头：hunched kindly old janitor, patched brown work clothes, broom

## 风格锚（按图类前缀进提示词）

- SPRITE_STYLE: high-quality anime visual novel character sprite, full body standing, facing viewer, clean lineart, soft cel shading, pastel colors, TRANSPARENT background, full figure with feet visible, no text, no watermark, correct anatomy, exactly two arms, each hand five fingers
- BG_STYLE: high-quality anime visual novel background art, NO characters, painterly detailed scenery, cinematic light, Chinese xianxia fantasy aesthetic, no text
- CG_STYLE: high-quality anime visual novel event CG, cinematic composition, emotional lighting, Chinese xianxia fantasy, detailed, no text, no watermark, correct anatomy, exactly two arms per person, each visible hand five fingers

---

## A组：向向立绘 + 标题图（agent-soya，全部附参考图）

| # | 文件 | P | 提示词要点（接在 SPRITE_STYLE + Soya描述后） |
| --- | --- | --- | --- |
| A1 | characters/soya_smile.png | P0 | gentle warm smile, relaxed ears, tail curled up happily, hands behind back |
| A2 | characters/soya_joy.png | P0 | beaming open-mouth grin, sparkling eyes, ears perked, tail straight up, one fist raised in cheer |
| A3 | characters/soya_pout.png | P0 | puffed cheeks pouting, ears half down, tail lashing, arms crossed |
| A4 | characters/soya_tear.png | P0 | big teary eyes about to cry, ears flat down, tail drooping, hands clutched in front of chest |
| A5 | characters/soya_blush.png | P0 | deep blush, flustered, looking aside, ears twitching, hands pressed to own cheeks |
| A6 | characters/soya_shock.png | P0 | wide eyes, small open mouth, ears straight up, tail puffed, hands half raised |
| A7 | characters/soya_calm.png | P1 | quiet melancholy gentle look, soft sad smile, ears slightly lowered, hands folded |
| A8 | characters/soya_fade.png | P1 | weakened, translucent pale glow on edges, tired eyes half open, faint smile, leaning slightly |
| A9 | characters/cat_normal.png | P0 | （不是人形）a small cream-colored fluffy cat with pink ribbon bow and golden bell choker, blue eyes, sitting, tail wrapped, sprite, transparent background |
| A10 | characters/cat_alert.png | P1 | same cream cat, ears perked, standing alert, tail raised |
| A11 | characters/cat_sad.png | P1 | same cream cat, lying down, ears flat, eyes sad |
| A12 | ui/title_keyvisual.png | P0 | 1536x1024 不透明：Soya in moonlight sitting on a rooftop beside a slender Chinese sword stuck upright, huge full moon, falling petals, night-blue palette with pink accents, anime key visual composition, copy space at left third（左侧留空给标题字） |

## B组：配角立绘 + 背景（agent-world）

| # | 文件 | P | 提示词要点 |
| --- | --- | --- | --- |
| B1 | characters/shen_proud.png | P0 | 沈青澜描述 + chin up, contemptuous smirk, one hand on sword hilt |
| B2 | characters/shen_shock.png | P0 | 沈青澜 + wide-eyed disbelief, gritted teeth, sword half drawn |
| B3 | characters/shen_resolve.png | P1 | 沈青澜 + calm serious resolve, sword held in both hands, ready stance |
| B4 | characters/liu_stern.png | P0 | 柳长青 + arms behind back, severe judging stare |
| B5 | characters/liu_shock.png | P0 | 柳长青 + stunned wide eyes, beard trembling, hand reaching out |
| B6 | characters/liu_warm.png | P1 | 柳长青 + faint proud smile, moist eyes, fist clasped in salute |
| B7 | characters/zhao_smug.png | P0 | 赵虎 + arms crossed, sneering grin |
| B8 | characters/zhao_beaten.png | P0 | 赵虎 + pale face, cold sweat, knees weak, hands raised apologetically |
| B9 | characters/xuanyi_polite.png | P0 | 玄一 + courteous bow gesture, folding fan half open, smiling closed eyes |
| B10 | characters/xuanyi_cruel.png | P0 | 玄一 + eyes open cold as a snake, smile gone sharp, dark aura |
| B11 | characters/gu_calm.png | P0 | 顾长生 + serene merciful expression, hands clasped behind, faint golden halo |
| B12 | characters/gu_mad.png | P1 | 顾长生 + grief-stricken fury, hair flowing, white robes whipping, golden cracks of light |
| B13 | characters/zhou_smile.png | P0 | 老周头 + leaning on broom, warm wrinkled grin |
| B14 | characters/zhou_worry.png | P1 | 老周头 + worried frown, hand outstretched |
| B15 | backgrounds/bg_zayuan.png | P0 | rainy night shabby sect courtyard, wet stone, stacked bricks, single lantern, cold blue |
| B16 | backgrounds/bg_room.png | P0 | tiny wooden disciple room at night, candle, hard bed, cracked window with windowsill, rain outside |
| B17 | backgrounds/bg_yanwu.png | P0 | sect training ground at morning, stone pillars and old wooden stumps, mountain mist |
| B18 | backgrounds/bg_dadian.png | P0 | grand sect hall, tall pillars, hanging swords emblem, solemn |
| B19 | backgrounds/bg_houshan.png | P0 | moonlit bamboo grove beside a mirror lake, fireflies, huge moon |
| B20 | backgrounds/bg_fangshi.png | P1 | bustling xianxia market street auction house interior, red lanterns, jade counter, treasure pedestal |
| B21 | backgrounds/bg_jianzhong.png | P0 | vast underground sword tomb cavern, thousands of ancient swords stuck in stone ground reaching into dark, cold green-blue ghost light |
| B22 | backgrounds/bg_banquet.png | P1 | luxurious night banquet hall, long tables, golden candles, silk curtains |
| B23 | backgrounds/bg_feisheng.png | P0 | colossal ascension altar platform above sea of clouds, storm sky, golden ritual circles, ominous |
| B24 | backgrounds/bg_dawn.png | P0 | mountain peaks at dawn, first sunlight breaking, warm gold and rose sky |
| B25 | backgrounds/bg_town.png | P1 | cozy lower-town street at dusk, noodle stall, steam, warm lights |
| B26 | backgrounds/bg_throne.png | P1 | cold celestial throne hall, white jade and gold, empty vast, single throne, god-rays |

## C组：CG（agent-cg，含向向的图附参考图）

| # | 文件 | P | 提示词要点（接 CG_STYLE） |
| --- | --- | --- | --- |
| C1 | cg/cg_cat_window.png | P0 | 含猫：rainy night, a small cream cat with pink bow and golden bell sitting on a cracked windowsill, looking straight at viewer, glowing blue eyes, rain dripping, candle light from inside |
| C2 | cg/cg_bone_reforge.png | P0 | young black-ponytail man sitting cross-legged at midnight, golden sword-shaped light veins glowing through his body and spine, small cream cat watching beside, dark room |
| C3 | cg/cg_stump_cut.png | P0 | training ground, an old thick wooden stump sliced clean in half sliding apart, young man in grey-blue robes lowering a plain sword, shocked crowd blurred in background |
| C4 | cg/cg_insight_lake.png | P1 | night lake like a mirror, young man mid sword-dance, water rising in a spiral ribbon around him, moonlight |
| C5 | cg/cg_moon_reveal.png | P0 | 含Soya：full moon over bamboo grove, Soya cat-girl appearing in a swirl of pale-pink light petals, barefoot above water, shy smile, reaching one hand toward viewer |
| C6 | cg/cg_hidden_win.png | P1 | arena, azure-robed arrogant swordsman's sword flying out of his grip, protagonist standing casually having barely moved, dust drifting |
| C7 | cg/cg_blaze.png | P1 | arena, protagonist catching an incoming sword blade between two fingers, sparks frozen, azure-robed opponent's shocked face |
| C8 | cg/cg_auction.png | P1 | auction hall, a broken rusty sword tip displayed on red silk pedestal, protagonist's eyes reflecting golden light from it, bidders silhouetted |
| C9 | cg/cg_sword_tomb.png | P0 | 含Soya：vast sword tomb cavern, ten thousand ancient swords all half-risen from stone bowing their blades toward the protagonist walking center, Soya cat-girl holding his sleeve, green-blue ghost light, epic wide shot |
| C10 | cg/cg_liu_kneel.png | P1 | rainy night before a law hall, stern old grey-robed elder kneeling on one knee on wet stone, fist to ground, head bowed, before a calm young man, lantern light |
| C11 | cg/cg_collapse.png | P0 | 含Soya：night corridor, Soya fainting limp in protagonist's arms, her golden bell dim and cracked faintly, his eyes wide in fear, cold moonlight |
| C12 | cg/cg_panel_truth.png | P1 | 含Soya：dark room, translucent golden contract threads flowing from sleeping Soya's chest into sword-shaped light in young man's hands, his face stricken, blue night |
| C13 | cg/cg_envoy_strike.png | P1 | black-gold robed envoy releasing a colossal palm of dark light down a mountain gate, stone shattering, robes whipping |
| C14 | cg/cg_core_burn.png | P0 | 含Soya：Soya standing between wounded protagonist and enemy, arms spread wide, her body igniting into blue-white flame from the edges, golden bell blazing, tearful determined smile, devastating beautiful |
| C15 | cg/cg_rooftop.png | P0 | 含猫：night rooftop under stars, young man sitting holding a small packet of dried fish toward a small cream cat keeping wary distance, both lit by moon, lonely tender |
| C16 | cg/cg_gather.png | P1 | dawn before mountain gate, small group setting out: black-ponytail man in white robes front, azure-robed swordsman, grey-robed elder, banners torn but raised |
| C17 | cg/cg_confront.png | P0 | ascension altar above clouds, white-robed silver-haired holy lord standing atop golden ritual circles, young white-robed swordsman below pointing a broken sword up at him, storm |
| C18 | cg/cg_wanjian.png | P0 | the sky itself filled with thousands of swords flying from every horizon toward one point above a young white-robed man with arms spread, clouds parting, blinding dawn light, ultimate epic moment |
| C19 | cg/cg_end_true.png | P0 | 含Soya：morning windowsill in warm sunrise, Soya waking up blinking, golden bell ringing with light, protagonist's hand offering dried fish, both smiling, tears of joy |
| C20 | cg/cg_end_ash.png | P1 | white-haired man in imperial white-gold robes alone on a cold vast celestial throne, holding a tiny golden bell in his palm, single shaft of light, desolate |
| C21 | cg/cg_end_sleep.png | P1 | 含Soya：snowy cliff, Soya in white mourning-style dress sitting beside a rusted sword stuck in stone, waiting, falling snow, far lonely shot |
| C22 | cg/cg_end_demon.png | P1 | black-robed young man seated on the holy throne in shadow, eyes cold, outside the great door a small cat-shaped silhouette turning away, contrast of gold and black |
| C23 | cg/cg_end_leave.png | P1 | 含Soya：dusk noodle stall in small town, Soya in hood with ears hidden poking out slightly, happily eating noodles beside protagonist, rusted wrapped sword leaning on bench, warm |
| C24 | cg/cg_end_refuse.png | P1 | 含猫：dusk rooftops, a small cream cat with pink bow watching from a roof ridge a distant ordinary man walking home below, melancholic warm light |
| C25 | cg/cg_end_arena.png | P1 | rain on an empty arena, a shattered plain sword lying on wet stone, blood thinning in rainwater, no people, cold grey |
| C26 | cg/cg_betrayal.png | P0 | memory flashback: on a colossal white-jade ascension platform above golden clouds, a white-robed long-haired swordsman seen from front with a sword blade piercing out of his chest from behind, golden light shattering like glass around him, a blurred silver-haired figure behind, tragic, dramatic |
| C27 | cg/cg_spring.png | P0(v2) | 含Soya(锚图)：hot spring in bamboo forest at night, thick white steam, Soya in the water up to her shoulders half turned away looking back surprised and shy, wet cream-blonde hair, cat ears with water droplets, golden bell resting on a rock at the edge, steam tastefully covering everything below shoulders, no nudity visible, comedic flustered mood |
| C28 | cg/cg_first_kiss.png | P0(v2) | 含Soya(锚图)：moonlit small wooden room, Soya in a faintly glowing translucent form leaning down to softly kiss the lying protagonist (black ponytail), foreheads close, golden light particles rising from her hair like embers, her edges slightly fading, bittersweet tender, dark blue night palette |
| C29 | cg/cg_dawn_kiss.png | P0(v2) | 含Soya(锚图)：warm sunrise flooding a windowsill, Soya in her xianxia hanfu tiptoeing up to kiss the protagonist in white robes, his hands catching her shoulders, golden bell shining, pink petals in morning light, joyful tears, celebratory and warm |
| C30 | cg/cg_duel_clash.png | P0(v3爽点轰炸) | tournament arena, two sword lights colliding frozen mid-air — one moonlight-white slash from an azure-robed prodigy versus a plain dull iron sword held casually by a black-ponytail young man in grey-blue robes, shockwave rippling dust outward in a ring, crowd silhouettes leaning back, ultra dynamic |
| C31 | cg/cg_tomb_bow.png | P0(v3) | close shot inside the sword tomb: a rusted ancient sword half-risen from a stone crack, blade bowed like an old kneeling minister, a young man's hand gently touching its spine, green-blue ghost light, thousands of blurred swords bowing in the dark background, reverent emotional |
| C32 | cg/cg_arm_cut.png | P0(v3) | rain frozen in mid-air sliced in half, extreme slow-motion: a broken half-sword sliding along a black-gold sleeve from below, raindrops bisected along the blade path, the envoy's shocked face half-lit, dramatic low angle, decisive single instant |
| C33 | cg/cg_stairs.png | P0(v3) | colossal white-jade stairway to an ascension altar, a white-robed black-ponytail young man climbing step by step against crushing golden pressure, each step behind him cracked and glowing with a ring of breakthrough light, robes and hair blasted upward, kneeling priests blurred on both sides, epic vertical composition |
| C34 | cg/cg_sword_sea.png | P0(v3) | god's-eye aerial view: the entire sky turned into a sea of flying swords above an ocean of clouds, ten thousand blades all pointing toward one tiny white figure on an altar far below, sword lights plowing glowing furrows through the clouds, overwhelming scale, dusk gold and steel blue |

### v4 福利向（fanservice，含Soya全部附锚图 soya_smile.png）— suggestive/ecchi 不露骨；alluring expression + tasteful covering（steam/hair/fabric）；no explicit nudity；每张媚态吸睛
| C35 | cg/cg_reforge_close.png | P0(v4) | 含Soya：dark room midnight, Soya in xianxia hanfu kneeling close in front of the protagonist (black ponytail), both palms pressed to his chest channeling golden energy, her collar slightly loosened showing collarbone, cream hair cascading, flushed cheeks and parted lips, shy averted eyes, warm gold glow, intimate but tasteful |
| C36 | cg/cg_bed_morning.png | P0(v4) | 含Soya：morning sunlight in a small wooden room, Soya curled up asleep hugging a pillow beside the viewer, her hanfu loosened off one shoulder, cat ears flopped, fluffy tail draped over the blanket, peaceful sleepy face, soft warm light, cozy waking-up fanservice, tasteful |
| C37 | cg/cg_ear_closeup.png | P0(v4) | 含Soya：extreme close-up of Soya's blushing face, eyes half-closed in pleasure, lips slightly parted, one of the protagonist's hands gently rubbing her fluffy cat ear, her own hand pressing on his hand, deep blush, alluring shy expression, night palette, intimate |
| C38 | cg/cg_lake_wet.png | P0(v4) | 含Soya：moonlit lake, Soya standing on the water having just transformed, soaked thin gauze hanfu clinging to her body showing her silhouette, wet hair on collarbone, water droplets, turning back over her shoulder caught staring, deep blush hugging herself, alluring but covered by clinging fabric and hair, no explicit nudity |
| C39 | cg/cg_sword_sleep.png | P0(v4) | 含Soya：Soya asleep curled on a bed at night hugging a broken sword tip, hanfu slightly disheveled revealing a glimpse of waistline, long hair and skirt spread out in moonlight, tail draped across her own cheek, faint tear tracks, serene vulnerable beauty, tasteful |
| C40 | cg/cg_borrow_robe.png | P0(v4) | 含Soya：night bamboo forest by a spring, Soya wearing the protagonist's oversized outer robe, the wide collar sliding off one bare shoulder, wet hair, hem reaching only mid-thigh showing bare legs, clutching the collar, looking up shyly with watery eyes, steam, alluring tasteful |
| C41 | cg/cg_tail_groom.png | P0(v4) | 含Soya：Soya sitting with her back turned, arching her spine reacting sensitively as the protagonist's hand combs the base of her fluffy tail, tail puffed up, ears trembling, looking back over shoulder with flushed face and teary half-lidded eyes mouth open in a gasp, suggestive but clothed, night room |
| C42 | cg/cg_banquet_gown.png | P1(v4) | 含Soya：Soya dressed up for a banquet in an elegant moon-white silk gown with gold embroidery and a high thigh-slit, hair in an updo with two strands at her neck, slim waist, glancing back shyly tugging her skirt, dazzling elegant fanservice, lantern-lit hall |
| C43 | cg/cg_lap_feed.png | P1(v4) | 含Soya：Soya lying on her back with her head on the protagonist's lap (lap pillow), looking up at viewer, mouth open waiting to be fed a dried fish, banquet gown slightly loosened at the collar, skirt spread, playful flirtatious smirk, warm room, cute alluring |
| C44 | cg/cg_fever_care.png | P1(v4) | 含Soya：Soya lying feverish on a bed, face flushed with fever, collar damp with sweat slightly open showing collarbone with a sheen of sweat, wet hair stuck to her cheek, weakly gripping the protagonist's wrist, a damp cloth on her forehead, tender vulnerable, dim candlelight |
| C45 | cg/cg_cling_cry.png | P1(v4) | 含Soya：Soya throwing herself into the protagonist's arms at night, clinging tightly, looking up with tear-filled eyes, lashes wet, nose red, face very close to his, trembling, emotional and intimate, dim warm room |
| C46 | cg/cg_morning_after.png | P0(v4) | 含Soya：late morning sunlight, Soya lazily lying on her front wrapped in a thin blanket on a bed, blanket slipping off one shoulder showing bare back and collarbone, tousled hair, cat ears relaxed, languid satisfied expression with rosy cheeks, beckoning with one finger, warm tender afterglow, tasteful suggestive |

## 数量自检

- 立绘：Soya 8 + 猫 3 + 配角 14 = 25
- 背景 12 + 标题 1 + CG 25 = 38
- 合计 63 张。P0 共 31 张（立绘15/背景9/CG7+标题... 以表为准）。
