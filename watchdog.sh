#!/bin/bash

INTERVAL=30
SOCKS="127.0.0.1:1080"
URL="https://www.cloudflare.com/cdn-cgi/trace"

while true; do
  sleep $INTERVAL

  if ! curl -s --socks5-hostname $SOCKS --max-time 5 $URL >/dev/null; then
    echo "[!] SOCKS unhealthy, restarting usque..."

    pkill usque || true
    sleep 2

    usque enroll --config /config/usque.yaml || true

    usque socks \
      --config /config/usque.yaml \
      --bind 0.0.0.0:1080 &
  else
    echo "[✓] SOCKS healthy"
  fi
done
