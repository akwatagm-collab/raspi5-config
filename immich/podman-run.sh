#!/bin/bash
# --- Immich Server ---
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
  -e REDIS_HOST=immich-redis \
  -e REDIS_PORT=6379 \
  ghcr.io/immich-app/immich-server:v1.105.0
# --- Immich Machine Learning ---
podman run -d \
  --name immich-ml \
  --network homecloud \
  -e IMMICH_SERVER_URL=http://immich:2283 \
  ghcr.io/immich-app/immich-machine-learning:v1.105.0
