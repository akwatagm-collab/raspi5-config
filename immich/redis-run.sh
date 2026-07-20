#!/bin/bash
podman run -d \
  --name immich-redis \
  --network homecloud \
  -v /srv/immich/redis:/data \
  docker.io/library/redis:7 \
  redis-server --save 20 1 --loglevel warning
