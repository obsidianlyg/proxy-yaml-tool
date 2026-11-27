# syntax=docker/dockerfile:1

FROM golang:1.24-alpine AS builder

WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY *.go ./
COPY static ./static

ARG TARGETOS=linux
ARG TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/proxy-yaml-web .

FROM alpine:3.21

RUN apk add --no-cache ca-certificates tzdata \
    && adduser -D -H -u 10001 -s /sbin/nologin appuser

WORKDIR /app

COPY --from=builder /out/proxy-yaml-web /app/proxy-yaml-web
COPY template.yaml /app/template.yaml

USER appuser

EXPOSE 8732

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD wget -qO- http://127.0.0.1:8732/api/session >/dev/null || exit 1

ENTRYPOINT ["/app/proxy-yaml-web"]
CMD ["-listen", "0.0.0.0:8732", "-template", "/app/template.yaml"]
