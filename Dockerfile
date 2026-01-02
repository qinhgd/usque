FROM golang:1.22-alpine AS builder

WORKDIR /build
RUN apk add --no-cache git

# build usque
RUN git clone https://github.com/Diniboy1123/usque.git
WORKDIR /build/usque
RUN CGO_ENABLED=0 go build -o /out/usque ./cmd

# build masque-plus
WORKDIR /build
RUN git clone https://github.com/ircfspace/masque-plus.git
WORKDIR /build/masque-plus
RUN CGO_ENABLED=0 go build -o /out/masque-plus

FROM alpine:latest
RUN apk add --no-cache \
    ca-certificates \
    bash \
    curl \
    busybox-extras

COPY --from=builder /out/usque /usr/local/bin/usque
COPY --from=builder /out/masque-plus /usr/local/bin/masque-plus

COPY entrypoint.sh /entrypoint.sh
COPY watchdog.sh /watchdog.sh
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /entrypoint.sh /watchdog.sh /healthcheck.sh

VOLUME ["/config", "/data"]

EXPOSE 1080

HEALTHCHECK --interval=30s --timeout=6s --retries=3 \
  CMD /healthcheck.sh

ENTRYPOINT ["/entrypoint.sh"]
