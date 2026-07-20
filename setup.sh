#!/bin/bash

BASE=~/homecloud

echo "Creating directory structure..."
mkdir -p $BASE/{minio,minio-dev,immich,jellyfin,pihole,portal,secure-browser,caddy/sites,secrets}
mkdir -p /srv/{minio/data,minio-dev/data,immich/library,immich/postgres,jellyfin/config,portal/data}

echo "Setting permissions..."
sudo chown -R akwata:akwata /srv

echo "Creating Podman network..."
podman network create homecloud || true

echo "Generating MinIO (prod) script..."
cat << 'EOF' > $BASE/minio/podman-run.sh
#!/bin/bash
podman run -d \
  --name minio \
  --network homecloud \
  -p 9000:9000 \
  -p 9001:9001 \
  -v /srv/minio/data:/data \
  -v $(pwd)/config:/root/.minio \
  --env-file ../secrets/.env \
  quay.io/minio/minio server /data --console-address ":9001"
EOF
chmod +x $BASE/minio/podman-run.sh

echo "Generating MinIO (dev) script..."
cat << 'EOF' > $BASE/minio-dev/podman-run.sh
#!/bin/bash
podman run -d \
  --name minio-dev \
  --network homecloud \
  -p 9100:9000 \
  -p 9101:9001 \
  -v /srv/minio-dev/data:/data \
  -v $(pwd)/config:/root/.minio \
  --env MINIO_ROOT_USER=minio_dev \
  --env MINIO_ROOT_PASSWORD=minio_dev_pass \
  quay.io/minio/minio server /data --console-address ":9001"
EOF
chmod +x $BASE/minio-dev/podman-run.sh

echo "Generating Immich PostgreSQL script..."
cat << 'EOF' > $BASE/immich/postgres-run.sh
#!/bin/bash
podman run -d \
  --name immich-postgres \
  --network homecloud \
  -v /srv/immich/postgres:/var/lib/postgresql/data \
  -e POSTGRES_USER=immich \
  -e POSTGRES_PASSWORD=immich_pass \
  -e POSTGRES_DB=immich \
  docker.io/postgres:14
EOF
chmod +x $BASE/immich/postgres-run.sh

echo "Generating Immich script..."
cat << 'EOF' > $BASE/immich/podman-run.sh
#!/bin/bash
podman run -d \
  --name immich \
  --network homecloud \
  -p 2283:2283 \
  -v /srv/immich/library:/usr/src/app/upload \
  -e DB_HOST=immich-postgres \
  -e DB_PORT=5432 \
  -e DB_USERNAME=immich \
  -e DB_PASSWORD=immich_pass \
  -e DB_DATABASE_NAME=immich \
  ghcr.io/immich-app/immich-server:latest
EOF
chmod +x $BASE/immich/podman-run.sh

echo "Generating Jellyfin script..."
cat << 'EOF' > $BASE/jellyfin/podman-run.sh
#!/bin/bash
podman run -d \
  --name jellyfin \
  --network homecloud \
  -p 8096:8096 \
  -v /srv/jellyfin/config:/config \
  -v /srv/minio/data:/media \
  docker.io/jellyfin/jellyfin:latest
EOF
chmod +x $BASE/jellyfin/podman-run.sh

echo "Generating Flask portal script..."
cat << 'EOF' > $BASE/portal/podman-run.sh
#!/bin/bash
podman run -d \
  --name portal \
  --network homecloud \
  -p 5000:5000 \
  -v $(pwd):/app \
  -v /srv/portal/data:/data \
  python:3.11-slim bash -c "pip install flask && python /app/app.py"
EOF
chmod +x $BASE/portal/podman-run.sh

echo "Generating Secure Browser script..."
cat << 'EOF' > $BASE/secure-browser/podman-run.sh
#!/bin/bash
podman run -d \
  --name secure-browser \
  --network homecloud \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  jlesage/firefox
EOF
chmod +x $BASE/secure-browser/podman-run.sh

echo "Generating Caddyfile..."
cat << 'EOF' > $BASE/caddy/Caddyfile
import sites/*.conf
EOF

echo "Generating Caddy site configs..."

cat << 'EOF' > $BASE/caddy/sites/minio.conf
minio.local {
    reverse_proxy minio:9001
}
EOF

cat << 'EOF' > $BASE/caddy/sites/minio-dev.conf
minio-dev.local {
    reverse_proxy minio-dev:9001
}
EOF

cat << 'EOF' > $BASE/caddy/sites/immich.conf
immich.local {
    reverse_proxy immich:2283
}
EOF

cat << 'EOF' > $BASE/caddy/sites/jellyfin.conf
jellyfin.local {
    reverse_proxy jellyfin:8096
}
EOF

cat << 'EOF' > $BASE/caddy/sites/pihole.conf
pihole.local {
    reverse_proxy 192.168.0.144:8080
}
EOF

cat << 'EOF' > $BASE/caddy/sites/portal.conf
portal.local {
    reverse_proxy portal:5000
}
EOF

echo "Setup complete!"
