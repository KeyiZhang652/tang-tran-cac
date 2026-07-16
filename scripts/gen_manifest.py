#!/usr/bin/env python3
"""扫描 photos/ 下各文件夹，生成 photos/manifest.json（网页据此显示照片，文件名任意）。"""
import json, os, re, sys, unicodedata

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
os.chdir(REPO)

FOLDERS = ["clocks", "moto", "bike", "wood", "audio", "porcelain", "portrait", "feature", "gallery"]
EXTS = {".jpg", ".jpeg", ".png", ".webp"}
MAX_PER_FOLDER = 24


def natural_key(name):
    return [int(t) if t.isdigit() else t.lower() for t in re.split(r"(\d+)", name)]


manifest = {}
for folder in FOLDERS:
    d = os.path.join("photos", folder)
    items = []
    if os.path.isdir(d):
        for name in sorted(os.listdir(d), key=natural_key):
            if name.startswith("."):
                continue
            if os.path.splitext(name)[1].lower() not in EXTS:
                continue
            items.append(unicodedata.normalize("NFC", f"photos/{folder}/{name}"))
    manifest[folder] = items[:MAX_PER_FOLDER]

with open("photos/manifest.json", "w", encoding="utf-8") as f:
    json.dump(manifest, f, ensure_ascii=False, indent=1)

print("✔ 照片清单已更新:", "  ".join(f"{k}:{len(v)}张" for k, v in manifest.items()))
