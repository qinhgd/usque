FROM golang:1.24-alpine AS builder

WORKDIR /build
RUN apk add --no-cache git

# ================= usque =================
RUN git clone https://github.com/Diniboy1123/usque.git
WORKDIR /build/usque
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
    go build -o usque ./cmd/usque

# ================= masque-plus =================
WORKDIR /build
RUN git clone https://github.com/ircfspace/masque-plus.git
WORKDIR /build/masque-plus
RUN CGO_ENABLED=0 GOOS=linux GOARCH=arm64 \
    go build -o masque-plus .

# ================= runtime =================
FROM alpine:latest
RUN apk add --no-cache \
    ca-certificates \
    bash \
    curl \
    busybox-extras

COPY --from=builder /build/usque/usque /usr/local/bin/usque
COPY --from=builder /build/masque-plus/masque-plus /usr/local/bin/masque-plus

# 🔴 必须显式 chmod
RUN chmod +x /usr/local/bin/usque /usr/local/bin/masque-plus

COPY entrypoint.sh /entrypoint.sh
COPY watchdog.sh /watchdog.sh
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /entrypoint.sh /watchdog.sh /healthcheck.sh

EXPOSE 1080
VOLUME ["/config", "/data"]

HEALTHCHECK --interval=30s --timeout=6s --retries=3 \
  CMD /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
