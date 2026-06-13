/* 角色注册表：具名角色必有立绘映射；旁白与主角无立绘。 */
window.CHARS = {
  narr: { narrator: true },
  mc:   { player: true },
  soya: {
    name: '向向', cls: 'soya', actor: 'xiang', pos: 'right', defaultExpr: 'smile',
    sprites: {
      smile: 'assets/characters/soya_smile.png',
      joy:   'assets/characters/soya_joy.png',
      pout:  'assets/characters/soya_pout.png',
      tear:  'assets/characters/soya_tear.png',
      blush: 'assets/characters/soya_blush.png',
      shock: 'assets/characters/soya_shock.png',
      calm:  'assets/characters/soya_calm.png',
      fade:  'assets/characters/soya_fade.png'
    }
  },
  cat: {
    name: '猫', cls: 'soya', actor: 'xiang', pos: 'left', small: true, defaultExpr: 'normal',
    /* 猫形态只有3张图，情绪用就近映射 */
    sprites: {
      normal: 'assets/characters/cat_normal.png',
      alert:  'assets/characters/cat_alert.png',
      sad:    'assets/characters/cat_sad.png',
      joy:    'assets/characters/cat_alert.png',
      shock:  'assets/characters/cat_alert.png',
      pout:   'assets/characters/cat_sad.png',
      tear:   'assets/characters/cat_sad.png',
      calm:   'assets/characters/cat_normal.png',
      smile:  'assets/characters/cat_normal.png',
      blush:  'assets/characters/cat_normal.png'
    }
  },
  shen: {
    name: '沈青澜', pos: 'left', defaultExpr: 'proud',
    sprites: {
      proud:   'assets/characters/shen_proud.png',
      shock:   'assets/characters/shen_shock.png',
      resolve: 'assets/characters/shen_resolve.png'
    }
  },
  liu: {
    name: '柳长青', pos: 'left', defaultExpr: 'stern',
    sprites: {
      stern: 'assets/characters/liu_stern.png',
      shock: 'assets/characters/liu_shock.png',
      warm:  'assets/characters/liu_warm.png'
    }
  },
  zhao: {
    name: '赵虎', pos: 'left', defaultExpr: 'smug',
    sprites: {
      smug:   'assets/characters/zhao_smug.png',
      beaten: 'assets/characters/zhao_beaten.png'
    }
  },
  xuanyi: {
    name: '玄一', pos: 'left', defaultExpr: 'polite',
    sprites: {
      polite: 'assets/characters/xuanyi_polite.png',
      cruel:  'assets/characters/xuanyi_cruel.png'
    }
  },
  gu: {
    name: '顾长生', pos: 'center', defaultExpr: 'calm',
    sprites: {
      calm: 'assets/characters/gu_calm.png',
      mad:  'assets/characters/gu_mad.png'
    }
  },
  zhou: {
    name: '老周头', pos: 'left', defaultExpr: 'smile',
    sprites: {
      smile: 'assets/characters/zhou_smile.png',
      worry: 'assets/characters/zhou_worry.png'
    }
  },
  qian: {
    name: '钱通', pos: 'left', defaultExpr: 'fawn',
    sprites: {
      fawn:    'assets/characters/qian_fawn.png',
      fear:    'assets/characters/qian_fear.png',
      resolve: 'assets/characters/qian_resolve.png'
    }
  },
  luo: {
    name: '阿萝', pos: 'center', defaultExpr: 'joy',
    sprites: {
      joy: 'assets/characters/luo_joy.png',
      cry: 'assets/characters/luo_cry.png'
    }
  }
};

window.MUSIC = {
  daily:  'assets/music/goldberg_aria.ogg',
  tender: 'assets/music/gymnopedie_no1.ogg',
  battle: 'assets/music/toccata_bwv565.ogg'
};

/* 环境音（循环）与一次性音效；与音乐共用右上角声音开关 */
window.AMB = {
  rain: 'assets/sfx/amb_rain.ogg'
};
window.SFX = {
  knock: 'assets/sfx/sfx_knock.ogg',
  brick: 'assets/sfx/sfx_brick.ogg',
  step:  'assets/sfx/sfx_step.ogg'
};

window.BGS = {
  bg_zayuan:   'assets/backgrounds/bg_zayuan.png',
  bg_room:     'assets/backgrounds/bg_room.png',
  bg_yanwu:    'assets/backgrounds/bg_yanwu.png',
  bg_dadian:   'assets/backgrounds/bg_dadian.png',
  bg_houshan:  'assets/backgrounds/bg_houshan.png',
  bg_fangshi:  'assets/backgrounds/bg_fangshi.png',
  bg_jianzhong:'assets/backgrounds/bg_jianzhong.png',
  bg_banquet:  'assets/backgrounds/bg_banquet.png',
  bg_feisheng: 'assets/backgrounds/bg_feisheng.png',
  bg_dawn:     'assets/backgrounds/bg_dawn.png',
  bg_town:     'assets/backgrounds/bg_town.png',
  bg_throne:   'assets/backgrounds/bg_throne.png',
  bg_room_day: 'assets/backgrounds/bg_room_day.png',
  bg_room_dusk:'assets/backgrounds/bg_room_dusk.png'
};

window.CG_TITLES = {
  cg_cat_window: '窗台上的猫', cg_bone_reforge: '剑骨重铸', cg_betrayal: '飞升台旧事', cg_stump_cut: '一剑断桩',
  cg_insight_lake: '秋水', cg_moon_reveal: '月下现形', cg_hidden_win: '不动声色',
  cg_blaze: '两指夹剑', cg_auction: '故剑', cg_sword_tomb: '万剑朝宗',
  cg_liu_kneel: '三千年之约', cg_collapse: '铃响', cg_panel_truth: '面板的真相',
  cg_envoy_strike: '圣使之威', cg_core_burn: '燃丹', cg_rooftop: '屋顶与鱼干',
  cg_gather: '集结', cg_confront: '飞升台对峙', cg_wanjian: '万剑归宗',
  cg_end_true: '天下剑鸣', cg_end_ash: '白首剑帝', cg_end_sleep: '剑冢长眠',
  cg_end_demon: '魔染', cg_end_leave: '平凡之路', cg_end_refuse: '猫的报恩',
  cg_end_arena: '断剑台',
  cg_spring: '灵泉', cg_first_kiss: '猫的规矩', cg_dawn_kiss: '晨光之约',
  cg_duel_clash: '试剑', cg_tomb_bow: '老臣叩首', cg_arm_cut: '一寸',
  cg_stairs: '归位', cg_sword_sea: '剑海蔽空',
  cg_reforge_close: '渡气', cg_bed_morning: '赖床', cg_ear_closeup: '耳尖',
  cg_lake_wet: '月下', cg_sword_sleep: '抱剑而眠', cg_borrow_robe: '借衣',
  cg_tail_groom: '梳尾', cg_banquet_gown: '盛装', cg_lap_feed: '投喂',
  cg_fever_care: '侍疾', cg_cling_cry: '别走', cg_morning_after: '翌日',
  cg_first_form: '初现', cg_morning_dress: '织衣', cg_check_bone: '听骨',
  cg_true_bath: '灵泉赐浴', cg_true_dress: '红妆', cg_true_veil: '却扇',
  cg_true_carry: '入怀', cg_true_night: '烛影摇红',
  cg_ally_feast: '喜宴', cg_ally_morning: '崖上晨光',
  cg_ash_dream: '雪夜幻',
  cg_sleep_lap: '梦·膝枕', cg_sleep_warm: '梦·同氅', cg_sleep_kiss: '梦·吻雪',
  cg_demon_shadow: '殿中白影', cg_demon_embrace: '黑与白', cg_demon_kiss: '幻灭之吻',
  cg_leave_bath: '浴桶', cg_leave_drunk: '桂花酿', cg_leave_quilt: '同衾', cg_leave_dawn: '晨炊',
  cg_refuse_dream: '梦·窗边', cg_refuse_warm: '梦·依偎',
  cg_arena_moon: '月华复形', cg_arena_tend: '敷药', cg_arena_warm: '偎暖', cg_arena_dawn: '黎明之约',
  cg_steady_hand: '稳住的手',
  cg_guard_death: '守一世',
  cg_qian_inform: '金眼之下', cg_qian_roster: '册上有名', cg_qian_last: '真心一次',
  cg_luo_flower: '大红花', cg_gu_seed: '师弟的犹豫',
  cg_lap_ear: '掏耳朵', cg_hair_dry: '绞发', cg_tipsy_cling: '微醺', cg_share_quilt: '同衾',
  cg_kowtow: '跪雨', cg_kick: '一脚',
  cg_burn_out: '燃丹·焚身', cg_burn_ash: '燃丹·余烬',
  cg_peek_splash: '泼水'
};
