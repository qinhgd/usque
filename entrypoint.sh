#!/bin/bash
set -e

CONFIG=/config/usque.yaml
mkdir -p /config /data

echo "[+] masque-socks starting..."

if [ ! -f "$CONFIG" ]; then
  echo "[*] No config found, registering..."
  usque register --config "$CONFIG"
fi

echo "[*] Enrolling..."
usque enroll --config "$CONFIG" || true

echo "[*] Starting SOCKS5 on :1080"
usque socks \
  --config "$CONFIG" \
  --bind 0.0.0.0:1080 &

SOCKS_PID=$!

/watchdog.sh &

wait $SOCKS_PID
