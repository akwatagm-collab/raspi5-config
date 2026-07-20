#!/bin/bash
podman run -d \
  --name immich-postgres \
  --network homecloud \
  -v /srv/immich/postgres:/var/lib/postgresql/data \
  -e POSTGRES_USER=immich \
  -e POSTGRES_PASSWORD=immich_pass \
  -e POSTGRES_DB=immich \
  docker.io/postgres:14
