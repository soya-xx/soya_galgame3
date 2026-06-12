#!/usr/bin/env python3
"""合成游戏音效（纯标准库，无需numpy），输出16bit单声道WAV到 /tmp/sfx_wav/。
随后由 enhance/转码脚本用 ffmpeg 转 ogg 放入 web/assets/sfx/。
音效：雨声环境(可循环)、敲窗"咚"、搬砖石响、雨中脚步。"""
import wave, struct, math, random, os

SR = 22050
OUT = "/tmp/sfx_wav"
os.makedirs(OUT, exist_ok=True)
random.seed(20260612)

def write_wav(name, samples):
    path = os.path.join(OUT, name + ".wav")
    # 限幅并转16bit
    data = b"".join(struct.pack("<h", max(-32767, min(32767, int(s * 32767)))) for s in samples)
    with wave.open(path, "wb") as w:
        w.setnchannels(1); w.setsampwidth(2); w.setframerate(SR)
        w.writeframes(data)
    print(name, f"{len(samples)/SR:.1f}s")

def lowpass(seq, alpha):
    out = []; prev = 0.0
    for x in seq:
        prev = prev + alpha * (x - prev); out.append(prev)
    return out

def highpass(seq, alpha):
    out = []; prev_in = 0.0; prev_out = 0.0
    for x in seq:
        po = alpha * (prev_out + x - prev_in); out.append(po)
        prev_in = x; prev_out = po
    return out

# ---------- 雨声环境（6秒，首尾交叉淡化可无缝循环） ----------
def rain(dur=6.0):
    n = int(SR * dur)
    noise = [random.uniform(-1, 1) for _ in range(n)]
    body = lowpass(noise, 0.25)          # 低通=远处雨幕的"沙沙"
    body = highpass(body, 0.6)           # 去掉过低的隆隆
    # 叠加细密高频"滴答"
    hiss = lowpass([random.uniform(-1, 1) for _ in range(n)], 0.85)
    out = []
    for i in range(n):
        # 缓慢起伏让雨听起来有层次
        swell = 0.78 + 0.22 * math.sin(2 * math.pi * 0.07 * i / SR)
        s = (body[i] * 0.9 + hiss[i] * 0.18) * swell * 0.32
        out.append(s)
    # 首尾交叉淡化 0.4s 实现无缝循环
    xf = int(SR * 0.4)
    for i in range(xf):
        a = i / xf
        out[i] = out[i] * a + out[n - xf + i] * (1 - a)
    return out[:n - xf]

# ---------- 敲窗"咚"（低沉木质叩击，0.35s） ----------
def knock():
    n = int(SR * 0.35); out = []
    for i in range(n):
        t = i / SR
        env = math.exp(-t * 22)
        tone = 0.6 * math.sin(2 * math.pi * 95 * t) + 0.3 * math.sin(2 * math.pi * 150 * t)
        click = random.uniform(-1, 1) * math.exp(-t * 120) * 0.5  # 起始木头脆响
        out.append((tone * env + click) * 0.8)
    return out

# ---------- 搬砖/石响（两块石头磕碰，0.4s） ----------
def brick():
    n = int(SR * 0.4); out = []
    for i in range(n):
        t = i / SR
        env = math.exp(-t * 16)
        body = (0.5 * math.sin(2 * math.pi * 220 * t) + 0.4 * math.sin(2 * math.pi * 410 * t))
        grit = random.uniform(-1, 1) * math.exp(-t * 40) * 0.7   # 砂砾摩擦
        out.append((body * env * 0.5 + grit) * 0.75)
    return out

# ---------- 雨中脚步（踩水"啪嗒"，0.3s） ----------
def step():
    n = int(SR * 0.3); out = []
    for i in range(n):
        t = i / SR
        thud = math.sin(2 * math.pi * 70 * t) * math.exp(-t * 30) * 0.5
        splash = random.uniform(-1, 1) * math.exp(-t * 26) * 0.45
        out.append((thud + splash) * 0.7)
    return lowpass(out, 0.7)

write_wav("amb_rain", rain())
write_wav("sfx_knock", knock())
write_wav("sfx_brick", brick())
write_wav("sfx_step", step())
print("DONE ->", OUT)
