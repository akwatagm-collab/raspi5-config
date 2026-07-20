#!/bin/bash
podman run -d \
  --name jellyfin \
  --network homecloud \
  -p 8096:8096 \
  -v /srv/jellyfin/config:/config \
  -v /srv/minio/data:/media \
  docker.io/jellyfin/jellyfin:latest
