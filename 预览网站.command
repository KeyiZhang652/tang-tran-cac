#!/bin/bash
# 藏珍阁 · 本地预览：双击运行，浏览器自动打开。预览完关闭本窗口即可。
cd "$(dirname "$0")"
python3 scripts/gen_manifest.py
echo ""
echo "▶ 本地预览已启动，浏览器即将打开…"
echo "  （这只是你电脑上的预览；要让别人看到，请运行「更新网站.command」）"
echo "  预览完毕后直接关闭本窗口。"
( sleep 1; open "http://127.0.0.1:8899" ) &
python3 -m http.server 8899 --bind 127.0.0.1 >/dev/null 2>&1
