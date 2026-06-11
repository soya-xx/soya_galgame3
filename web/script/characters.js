/* 角色注册表：具名角色必有立绘映射；旁白与主角无立绘。 */
window.CHARS = {
  narr: { narrator: true },
  mc:   { player: true },
  soya: {
    name: '向向', cls: 'soya', pos: 'right', defaultExpr: 'smile',
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
    name: '猫', cls: 'soya', pos: 'left', small: true, defaultExpr: 'normal',
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
  }
};

window.MUSIC = {
  daily:  'assets/music/goldberg_aria.ogg',
  tender: 'assets/music/gymnopedie_no1.ogg',
  battle: 'assets/music/toccata_bwv565.ogg'
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
  bg_throne:   'assets/backgrounds/bg_throne.png'
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
  cg_stairs: '归位', cg_sword_sea: '剑海蔽空'
};
