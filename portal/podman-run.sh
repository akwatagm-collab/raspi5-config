#!/bin/bash
podman run -d \
  --name portal \
  --network homecloud \
  -p 5000:5000 \
  -v $(pwd):/app \
  -v /srv/portal/data:/data \
  python:3.11-slim bash -c "pip install flask && python /app/app.py"
