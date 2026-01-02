#!/bin/sh

SOCKS="127.0.0.1:1080"
URL="https://www.cloudflare.com/cdn-cgi/trace"

curl -s \
  --socks5-hostname $SOCKS \
  --max-time 5 \
  $URL >/dev/null || exit 1

exit 0
