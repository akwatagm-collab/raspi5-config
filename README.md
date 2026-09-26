Raspberry Pi 5 Home Cloud Configuration (raspi5-config)Raspberry Pi 5 上で稼働するセルフホスト型「おうちクラウド」環境の構成管理リポジトリです。
コンテナエンジンには Podman を採用し、サービス管理は systemd (Quadlet) およびシェルスクリプトで宣言的に管理しています。
🏠 提供サービス一覧（おうちクラウド 総合ポータル）ポータルより死活状態連動で運用・管理を実施。
サービス用途稼働形態バックエンド依存
📄 Paperless-ngx電子書類管理（OCR・全文検索）常時稼働PostgreSQL, Redis
🖼️ Immich写真・動画クラウド（バックアップ・閲覧）常時稼働PostgreSQL (pgvector), MinIO
🎬 Jellyfinメディアサーバー（ストリーミング配信）常時稼働MinIO / ローカルストレージ
📓 Joplin Serverノート同期サーバー常時稼働MinIO
🤖 n8nワークフロー自動化・RPAコントロール常時稼働-
🤖 Open WebUIローカルLLM・生成AIインターフェース稼働制御（夜間停止対応）/ 外部API
📦 MinIOS3互換オブジェクトストレージ（本番環境）常時稼働Btrfs ストレージ
🛠️ MinIO-DevS3互換オブジェクトストレージ（開発・検証環境）稼働制御（夜間停止対応）
📈 NetdataRaspberry Pi 5 システムリアルタイム監視常時稼働ホストメトリクス

📦 MinIO バケット依存関係本環境では、ステートレス化およびデータ統合管理のため、各サービスのバックエンドストレージとして MinIO（本番用）を活用しています。
 immich-dataImmich のアップロード済み写真・動画アセット、サムネイル等のオブジェクト保存領域。
 jellyfin-mediaJellyfin で配信するメディアライブラリの保存・参照領域。
 joplin-bucketJoplin クライアント間の暗号化同期データ保存領域。
 ※新規環境デプロイ時は、各サービスコンテナ起動前に MinIO 上で上記バケットの事前作成が必要です。
 
 📁 ディレクトリ構成
├── caddy/                   # Caddyfile・リバースプロキシ設定
├── containers/systemd/      # Quadlet 定義ファイル (*.container, *.volume, *.network)
├── immich/                  # Immich 関連設定・個別スクリプト
├── paperless/               # Paperless-ngx 構成定義
├── jellyfin/                # Jellyfin 構成定義
├── minio/                   # MinIO（本番環境）構成スクリプト
├── minio-dev/               # MinIO（開発環境）構成スクリプト
├── setup.sh                 # 初期ディレクトリ構築・プロビジョニング
├── secrets/                 # 【Git管理外】認証情報・環境変数定義
│   ├── immich.env
│   ├── paperless.env
│   ├── minio.env
│   ├── n8n.env
│   └── openwebui.env
└── README.md

🔐 シークレット・環境変数の管理方針
セキュリティ担保のため、パスワード・暗号化キー・トークン類はGit管理から完全に除外しています。
すべての認証情報はホスト上の secrets/ ディレクトリ配下に配置し、コンテナ起動時に EnvironmentFile または環境変数ファイルとして注入します。
必須シークレットファイル一覧新規構築または再展開時には、secrets/ ディレクトリを作成し、以下の定義ファイルを準備する必要があります。
1. secrets/immich.envコード スニペットDB_PASSWORD=your_secure_immich_db_pass
POSTGRES_PASSWORD=your_secure_immich_db_pass
DB_DATABASE_NAME=immich
DB_USERNAME=immich
# MinIO S3連携設定
AWS_ACCESS_KEY_ID=your_minio_access_key
AWS_SECRET_ACCESS_KEY=your_minio_secret_key
2. secrets/paperless.envコード スニペットPAPERLESS_DBPASS=your_secure_paperless_db_pass
PAPERLESS_ADMIN_PASSWORD=your_secure_admin_pass
PAPERLESS_SECRET_KEY=your_generate_secret_key_32_chars
PAPERLESS_URL=http://paperless.local
3. secrets/minio.envコード スニペットMINIO_ROOT_USER=admin
MINIO_ROOT_PASSWORD=your_secure_minio_root_password
4. secrets/n8n.envコード スニペットN8N_ENCRYPTION_KEY=your_secure_n8n_encryption_key
N8N_USER_MANAGEMENT_JWT_SECRET=your_secure_jwt_secret
5. secrets/openwebui.envコード スニペットWEBUI_SECRET_KEY=your_webui_secret_key
OPENAI_API_BASE_URL=http://localhost:11434

🚀 セットアップ・再構築手順
本リポジトリから別環境または初期化環境へ復元・デプロイする際の手順です。
1. リポジトリの取得と初期化Bashgit clone https://github.com/akwatagm-collab/raspi5-config.git /home/akwata/homecloud
cd /home/akwata/homecloud
./setup.sh
2. シークレットファイルの配置（手動）
3. secrets/ ディレクトリを作成し、必要な環境変数ファイルを定義します。Bashmkdir -p secrets
chmod 700 secrets
# secrets/*.env を作成
3. MinIO バケットの準備（必須）
  MinIO コンソール（または mc コマンド）にアクセスし、以下のバケットを事前作成します。immich-datajellyfin-mediajoplin-bucket4. Quadlet 定義の適用リポジトリ内の Quadlet ファイルを systemd の管理パスへ反映します。Bash#
rootful 構成の場合
sudo ln -sf /home/akwata/homecloud/containers/systemd/* /etc/containers/systemd/

# systemd のリロード（コンテナユニットの自動生成）
sudo systemctl daemon-reload

5. サービスの起動・確認Bash# サービスの起動
sudo systemctl start minio
sudo systemctl start immich-server paperless-webserver jellyfin caddy

# 起動状態の確認
sudo systemctl status immich-server
🔄 バックアップ・BCP運用スナップショット: Btrfs の読み取り専用スナップショット（/.snapshots/）を定期取得。
 オフサイト同期: rclone をバックグラウンド実行し、Google Drive への非同期バックアップを自動同期。更新コマンド（端末への流し込み用）エディタ（nano README.md）で上記を直接貼り付けて保存するか、以下のコマンドを実行してコミット＆プッシュしてください。Bashgit add README.md
git commit -m "docs: add minio bucket dependencies (immich, jellyfin, joplin) and update deployment steps"
git push origin main
