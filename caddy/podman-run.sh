#!/bin/bash
sudo podman run \
  --name caddy \
  --network homecloud \
  -p 80:80 \
  -p 443:443 \
  -v /srv/caddy:/config \
  -d docker.io/caddy:latest
