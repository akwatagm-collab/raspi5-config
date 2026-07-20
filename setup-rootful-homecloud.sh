#!/bin/bash

set -e

echo "=== Create rootful network ==="
sudo podman network create homecloud || true

echo "=== Create /srv directories ==="
sudo mkdir -p /srv/{immich,immich/postgres,immich/redis,immich/library}
sudo mkdir -p /srv/minio
sudo mkdir -p /srv/jellyfin/{movies,tv,music}
sudo mkdir -p /srv/caddy

echo "=== Fix permissions ==="
sudo chown -R root:root /srv

HOME_CLOUD="$HOME/homecloud"

mkdir -p $HOME_CLOUD/{immich/server,immich/ml,immich/postgres,immich/redis,minio,jellyfin,caddy}

############################################
# PostgreSQL (Immich)
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/immich/postgres/podman-run.sh
#!/bin/bash
sudo podman run \
  --name immich-postgres \
  --network homecloud \
  -v /srv/immich/postgres:/var/lib/postgresql/data \
  -e POSTGRES_PASSWORD=immich \
  -e POSTGRES_USER=immich \
  -e POSTGRES_DB=immich \
  -d docker.io/postgres:16
EOF
sudo chmod +x $HOME_CLOUD/immich/postgres/podman-run.sh

############################################
# Redis (Immich)
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/immich/redis/podman-run.sh
#!/bin/bash
sudo podman run \
  --name immich-redis \
  --network homecloud \
  -v /srv/immich/redis:/data \
  -d docker.io/redis:7
EOF
sudo chmod +x $HOME_CLOUD/immich/redis/podman-run.sh

############################################
# Immich Server
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/immich/server/podman-run.sh
#!/bin/bash
sudo podman run \
  --name immich-server \
  --network homecloud \
  -p 2283:2283 \
  -v /srv/immich/library:/usr/src/app/upload \
  -e DB_HOST=immich-postgres \
  -e DB_PASSWORD=immich \
  -e REDIS_HOST=immich-redis \
  -d ghcr.io/immich-app/immich-server:latest
EOF
sudo chmod +x $HOME_CLOUD/immich/server/podman-run.sh

############################################
# Immich ML
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/immich/ml/podman-run.sh
#!/bin/bash
sudo podman run \
  --name immich-ml \
  --network homecloud \
  -d ghcr.io/immich-app/immich-machine-learning:latest
EOF
sudo chmod +x $HOME_CLOUD/immich/ml/podman-run.sh

############################################
# MinIO
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/minio/podman-run.sh
#!/bin/bash
sudo podman run \
  --name minio \
  --network homecloud \
  -p 9000:9000 \
  -p 9001:9001 \
  -v /srv/minio:/data \
  -e MINIO_ROOT_USER=minio \
  -e MINIO_ROOT_PASSWORD=minio123 \
  -d quay.io/minio/minio server /data --console-address ":9001"
EOF
sudo chmod +x $HOME_CLOUD/minio/podman-run.sh

############################################
# Jellyfin
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/jellyfin/podman-run.sh
#!/bin/bash
sudo podman run \
  --name jellyfin \
  --network homecloud \
  -p 8096:8096 \
  -v /srv/jellyfin:/media \
  -d docker.io/jellyfin/jellyfin:latest
EOF
sudo chmod +x $HOME_CLOUD/jellyfin/podman-run.sh

############################################
# Caddy
############################################
cat << 'EOF' | sudo tee $HOME_CLOUD/caddy/podman-run.sh
#!/bin/bash
sudo podman run \
  --name caddy \
  --network homecloud \
  -p 80:80 \
  -p 443:443 \
  -v /srv/caddy:/config \
  -d docker.io/caddy:latest
EOF
sudo chmod +x $HOME_CLOUD/caddy/podman-run.sh

echo "=== All rootful scripts generated ==="
echo "Run each service with: sudo ./podman-run.sh"
