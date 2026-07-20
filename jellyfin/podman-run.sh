#!/bin/bash
sudo podman run \
  --name jellyfin \
  --network homecloud \
  -p 8096:8096 \
  --device /dev/dri:/dev/dri \
  -v /etc/machine-id:/etc/machine-id:ro \
  -v /srv/jellyfin:/media \
  -d docker.io/jellyfin/jellyfin:latest
