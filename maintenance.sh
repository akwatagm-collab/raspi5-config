#!/bin/bash
set -e

echo "=================================================="
echo "🚀 1. Btrfs 未圧縮ファイルの一括再圧縮 (zstd) を開始します"
echo "=================================================="
# おうちクラウドのデータ領域（/srv）と設定領域（/home/akwata/homecloud）を強力に圧縮・デフラグします
sudo btrfs filesystem defragment -r -v -czstd /srv
sudo btrfs filesystem defragment -r -v -czstd /home/akwata/homecloud

echo -e "\n=================================================="
echo "🧹 2. システムの不要なゴミ掃除 (クリーンアップ) を開始します"
echo "=================================================="
# aptのキャッシュや、これまでのトラブルシューティングで溜まったPodmanの不要な一時データを完全消去
sudo apt-get clean
sudo podman system prune -a -f

echo -e "\n=================================================="
echo "📦 3. GitHub への最終同期 (Git Push) を開始します"
echo "=================================================="
cd /home/akwata/homecloud

# ユーザー情報が未登録の場合の保険（akwata名義でサイン）
git config user.email "akwata@example.com"
git config user.name "akwata"

# 変更（自動起動サービスの登録後のクリーンな状態）をコミットしてプッシュ
git add .
git commit -m "Optimize: Compress Btrfs storage, clean up system, and finalize homecloud configuration" || echo "変更はありません"
git push origin main

echo -e "\n=================================================="
echo "🎉 すべてのメンテナンス処理が正常に完了しました！"
echo "=================================================="
