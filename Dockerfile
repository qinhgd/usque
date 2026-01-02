# 使用 TARGETARCH 自动识别架构
FROM golang:alpine AS builder
ARG TARGETARCH
WORKDIR /build
RUN apk add --no-cache git

# 同时编译两个项目
RUN git clone https://github.com/Diniboy1123/usque.git usque_src && \
    cd usque_src && CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -ldflags="-s -w" -o /build/usque .

RUN git clone https://github.com/ircfspace/masque-plus.git masque_src && \
    cd masque_src && CGO_ENABLED=0 GOOS=linux GOARCH=$TARGETARCH go build -ldflags="-s -w" -o /build/masque-plus .

# 运行镜像
FROM alpine:latest
WORKDIR /app
RUN apk add --no-cache ca-certificates tzdata
COPY --from=builder /build/usque /app/usque
COPY --from=builder /build/masque-plus /app/masque-plus
RUN chmod +x /app/usque /app/masque-plus

EXPOSE 1080
ENTRYPOINT ["/app/masque-plus"]
CMD ["--scan", "--bind", "0.0.0.0:1080", "--scan-max", "10", "-4"]
