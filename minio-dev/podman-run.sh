#!/bin/bash
podman run -d \
  --name minio-dev \
  --network homecloud \
  -p 9100:9000 \
  -p 9101:9001 \
  -v /srv/minio-dev/data:/data \
  -v /home/akwata/homecloud/minio-dev/config:/root/.minio \
  --env MINIO_ROOT_USER=minio_dev \
  --env MINIO_ROOT_PASSWORD=minio_dev_pass \
  quay.io/minio/minio server /data --console-address ":9001"
