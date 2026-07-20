#!/bin/bash
podman run -d \
  --name minio \
  --network homecloud \
  -p 9000:9000 \
  -p 9001:9001 \
  -v /srv/minio/data:/data \
  -v /home/akwata/homecloud/minio/config:/root/.minio \
  --env-file /home/akwata/homecloud/secrets/.env \
  quay.io/minio/minio server /data --console-address ":9001"
