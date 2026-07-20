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
