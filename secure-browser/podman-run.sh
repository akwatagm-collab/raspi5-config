#!/bin/bash
podman run -d \
  --name secure-browser \
  --network homecloud \
  -e DISPLAY=:0 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  jlesage/firefox
