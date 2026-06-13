#!/usr/bin/env python3
"""
FLUX.2 [pro] 图生图编辑增强（Black Forest Labs 官方 API）
文档: https://docs.bfl.ml

用法:
  python3 tools/flux_enhance.py <input.png> <output.png> "<edit prompt>"

流程: POST /v1/flux-2-pro (input_image=base64 + prompt) → 轮询 polling_url → 下载 result.sample
输入图应来自 gpt-image-2 底图，以保持一致性。
"""
import sys, os, base64, json, time, ssl, subprocess, tempfile, shutil, datetime, urllib.request

# 持久化 key（也可用环境变量 BFL_API_KEY 覆盖）
BFL_API_KEY = os.environ.get("BFL_API_KEY") or "bfl_9vJS6iSg42TlY9uxIMAoYFTiC1la9yNd"
BFL_URL     = "https://api.bfl.ai/v1/flux-2-pro"
CTX         = ssl._create_unverified_context()
MODEL       = "flux-2-pro"

# ── 归档/模型留痕：与 tools/lib/archive_img.sh 同格式（开发准则见 design/archive/README.md）──
_ROOT         = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
_ARCHIVE_DIR  = os.path.join(_ROOT, "design", "archive")
_ARCHIVE_LOG  = os.path.join(_ARCHIVE_DIR, "ARCHIVE_LOG.tsv")
_ASSET_MODELS = os.path.join(_ROOT, "design", "asset-models.tsv")


def _in_repo(path):
    """仅对仓库内的现役资产归档/记账；/tmp 等暂存输出不入档不入清单。"""
    return not os.path.relpath(path, _ROOT).startswith("..")


def _lookup_model(path):
    if not os.path.isfile(_ASSET_MODELS):
        return "unknown"
    rel = os.path.relpath(path, _ROOT)
    with open(_ASSET_MODELS) as f:
        for ln in f:
            p = ln.rstrip("\n").split("\t")
            if p and p[0] == rel:
                return p[1] if len(p) > 1 else "unknown"
    return "unknown"


def _archive(path, reason, model="unknown", note=""):
    """覆盖前把旧图永久归档进 design/archive/，绝不直接覆盖丢失。"""
    if not os.path.isfile(path):
        return
    name, ext = os.path.splitext(os.path.basename(path))
    ext = ext.lstrip(".") or "png"
    stamp = datetime.datetime.now(datetime.timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    dest_dir = os.path.join(_ARCHIVE_DIR, reason)
    os.makedirs(dest_dir, exist_ok=True)
    suffix = f"{name}__{reason}__{model}__{stamp}" + (f"__{note}" if note else "")
    dest = os.path.join(dest_dir, f"{suffix}.{ext}")
    i = 1
    while os.path.exists(dest):
        dest = os.path.join(dest_dir, f"{suffix}-{i}.{ext}"); i += 1
    shutil.copy2(path, dest)
    is_new = not os.path.isfile(_ARCHIVE_LOG)
    with open(_ARCHIVE_LOG, "a") as f:
        if is_new:
            f.write("utc_iso\treason\tmodel\tasset_key\toriginal_path\tarchived_relpath\tnote\n")
        f.write(f"{stamp}\t{reason}\t{model}\t{name}\t"
                f"{os.path.relpath(path, _ROOT)}\t{os.path.relpath(dest, _ROOT)}\t{note}\n")


def _record_model(path, model=MODEL, note=""):
    """登记现役素材由哪个模型生成（一图一行，同路径覆盖旧记录）。"""
    rel = os.path.relpath(path, _ROOT)
    body = []
    if os.path.isfile(_ASSET_MODELS):
        with open(_ASSET_MODELS) as f:
            for ln in f:
                p = ln.rstrip("\n").split("\t")
                if p and p[0] not in ("relpath", rel):
                    body.append(p)
    body.append([rel, model, note])
    with open(_ASSET_MODELS, "w") as f:
        f.write("relpath\tmodel\tnote\n")
        for r in body:
            f.write("\t".join((r + ["", ""])[:3]) + "\n")


def _b64(path, max_px=2048):
    tmp = tempfile.mktemp(suffix=".png")
    subprocess.run(["sips", "-Z", str(max_px), path, "--out", tmp], capture_output=True, check=True)
    with open(tmp, "rb") as f:
        b = base64.b64encode(f.read()).decode()
    os.unlink(tmp)
    return b


def edit(input_path, output_path, prompt):
    payload = {
        "prompt": prompt,
        "input_image": _b64(input_path),
        "width": int(os.environ.get("FLUX_W", "2400")),
        "height": int(os.environ.get("FLUX_H", "1600")),
        "output_format": "png",
        # 0=最严 2=默认 5=最宽松
        "safety_tolerance": int(os.environ.get("FLUX_SAFETY", "5")),
    }
    req = urllib.request.Request(
        BFL_URL, data=json.dumps(payload).encode(),
        headers={"x-key": BFL_API_KEY, "Content-Type": "application/json", "accept": "application/json"},
    )
    with urllib.request.urlopen(req, timeout=60, context=CTX) as r:
        sub = json.loads(r.read())
    polling_url = sub.get("polling_url")
    if not polling_url:
        raise RuntimeError(f"no polling_url: {sub}")
    print(f"[flux] submitted id={sub.get('id')}")

    # 轮询
    for i in range(60):
        time.sleep(2)
        preq = urllib.request.Request(polling_url, headers={"x-key": BFL_API_KEY, "accept": "application/json"})
        with urllib.request.urlopen(preq, timeout=30, context=CTX) as r:
            res = json.loads(r.read())
        st = res.get("status")
        if st == "Ready":
            url = res["result"]["sample"]
            if _in_repo(output_path):                                       # 暂存到/tmp则跳过
                _archive(output_path, "original", _lookup_model(output_path))   # 覆盖前留底旧图
            with urllib.request.urlopen(url, timeout=60, context=CTX) as ir:
                open(output_path, "wb").write(ir.read())
            if _in_repo(output_path):
                _record_model(output_path, MODEL, "img2img增强")            # 标注生成模型
            print(f"[flux] Ready -> {output_path}")
            return url
        if st in ("Error", "Failed", "Content Moderated", "Request Moderated"):
            raise RuntimeError(f"flux status={st}: {res}")
        print(f"[flux] {st}... ({i})")
    raise RuntimeError("flux timeout")


if __name__ == "__main__":
    if len(sys.argv) != 4:
        print('Usage: python3 tools/flux_enhance.py <input.png> <output.png> "<prompt>"')
        sys.exit(1)
    edit(sys.argv[1], sys.argv[2], sys.argv[3])
