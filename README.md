[200~### raspi5-config / homecloud

Raspberry Pi 5（Debian Trixie）上で動作する、Podman 6 (Rootful) + Quadletベースの軽量・高再現性プライベートクラウド。 

### 💡 アーキテクチャの特徴

* **完全Rootful運用**: ネットワーク特権や外部ストレージ権限を確保。
* **リソース最適化**: 4GBメモリ上限に対応し、ImmichのML処理を外部化。JellyfinはFLAC専用機化。
* **オブジェクトストレージ**: MinIOを核としたS3互換ストレージ基盤。
* **AI連携**: Open WebUIを常駐。

### 📦 サービス構成

サービス 

役割 

****Caddy****
HTTPS/リバースプロキシ
****Open WebUI****
AIフロントエンド
****Immich + DB****
写真管理 (S3連携)
****MinIO****
ストレージ基盤
****Jellyfin****
FLAC音楽サーバー
****Netdata****
リソース監視

### 🛠️ 運用・自動起動（Quadlet）

quadlets/ ディレクトリ配下の .container, .network, .volume ファイル（Quadlet）を使用し、systemd とネイティブ連携。OS再起動時の自動起動と環境再現性を担保。 

### 🚀 環境復元手順

以下のスクリプトで、リポジトリのQuadlet設定を実環境へデプロイします。 

bash

cd /home/akwata/homecloud
./setup-rootful-homecloud.sh

コードは注意してご使用ください。~
