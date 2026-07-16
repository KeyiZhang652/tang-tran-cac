#!/bin/bash
# 藏珍阁 · 一键更新网站：双击运行。自动转换 iPhone HEIC 照片、压缩过大图片、更新照片清单并上传。
cd "$(dirname "$0")"

echo "═══════════════════════════════════════"
echo "        藏珍阁 · 网站照片一键更新"
echo "═══════════════════════════════════════"
echo ""

# 1) iPhone HEIC 照片自动转成 JPG（原件移入 photos/_heic原件/ 备份，不会丢失）
mkdir -p "photos/_heic原件"
converted=0
while IFS= read -r -d '' f; do
  out="${f%.*}.jpg"
  if sips -s format jpeg "$f" --out "$out" >/dev/null 2>&1; then
    mv "$f" "photos/_heic原件/" 2>/dev/null
    converted=$((converted+1))
    echo "  已转换: ${f##*/} → ${out##*/}"
  fi
done < <(find photos -type f \( -iname '*.heic' -o -iname '*.heif' \) -not -path '*/_*' -print0)
if [ "$converted" -gt 0 ]; then
  echo "✔ 已转换 $converted 张 HEIC 照片（原件备份在 photos/_heic原件/）"
else
  echo "✔ 没有需要转换的 HEIC 照片"
fi

# 2) 压缩过大的照片（最长边压到 1600px，网页加载更快）
resized=0
while IFS= read -r -d '' f; do
  w=$(sips -g pixelWidth "$f" 2>/dev/null | awk '/pixelWidth/{print $2}')
  h=$(sips -g pixelHeight "$f" 2>/dev/null | awk '/pixelHeight/{print $2}')
  if [ -n "$w" ] && [ -n "$h" ] && { [ "$w" -gt 1600 ] || [ "$h" -gt 1600 ]; }; then
    sips -Z 1600 "$f" >/dev/null 2>&1 && resized=$((resized+1))
  fi
done < <(find photos -type f \( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' \) -not -path '*/_*' -print0)
echo "✔ 压缩了 $resized 张过大的照片"

# 3) 重新生成照片清单
python3 scripts/gen_manifest.py

# 4) 上传到网站
git add -A
if git diff --cached --quiet; then
  echo ""
  echo "✔ 照片没有变化，网站无需更新。"
else
  git commit -m "更新照片" >/dev/null
  echo ""
  echo "▶ 正在上传到网站…"
  ok=0
  for i in 1 2 3 4; do
    if git push >/dev/null 2>&1; then ok=1; break; fi
    echo "  网络不稳，正在重试 $i/4 …"
    sleep 6
  done
  if [ "$ok" -eq 1 ]; then
    echo ""
    echo "✔ 上传成功！约 1 分钟后网站自动更新："
    echo "  https://keyizhang652.github.io/tang-tran-cac/"
  else
    echo ""
    echo "✘ 上传失败（网络问题）。请检查网络后，重新双击本文件即可。"
  fi
fi
echo ""
read -p "按回车键关闭本窗口…"
