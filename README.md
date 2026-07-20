
raspi5-config / homecloud
Raspberry Pi5 上で動作する家庭クラウド環境。
Podman rootless をベースに、写真管理・動画配信・オブジェクトストレージ・リバースプロキシを統合した構成。

📦 構成一覧
サービス	役割	ディレクトリ
Immich	写真・動画管理	immich/
PostgreSQL	Immich DB	immich/postgres-run.sh
Redis	Immich キャッシュ	immich/redis-run.sh
MinIO	オブジェクトストレージ	minio/
Jellyfin	動画配信	jellyfin/
Caddy	リバースプロキシ / HTTPS	caddy/
Portal	homecloud の操作 UI	portal/
Secure Browser	Pi5 用の安全ブラウザ	secure-browser/
secrets	パスワード・環境変数	secrets/（Git管理外）


🚀 起動手順（Podman rootless）
1. Immich 前提サービス起動
コード
cd immich
./postgres-run.sh
./redis-run.sh
2. Immich server 起動
コード
./podman-run.sh
3. MinIO 起動
コード
cd ../minio
./podman-run.sh
4. Jellyfin 起動
コード
cd ../jellyfin
./podman-run.sh
5. Caddy 起動
コード
cd ../caddy
./podman-run.sh
🔐 secrets ディレクトリについて
secrets/ は GitHub に公開しない。
以下のファイルが含まれる：

Immich の DB パスワード

MinIO の root user / password

Jellyfin の初期設定

Portal の API キー

🛠 ディレクトリ構成
コード
homecloud/
├── caddy/
│   ├── Caddyfile
│   └── sites/*.conf
├── immich/
│   ├── podman-run.sh
│   ├── postgres-run.sh
│   ├── redis-run.sh
│   └── ml-run.sh
├── jellyfin/
│   └── podman-run.sh
├── minio/
│   └── podman-run.sh
├── portal/
│   └── podman-run.sh
├── secure-browser/
│   └── podman-run.sh
├── secrets/   ← Git管理外
└── setup.sh
