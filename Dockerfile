FROM --platform=$BUILDPLATFORM golang:1.22-bookworm AS builder

ENV GOTOOLCHAIN=auto

WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY ./ /app

ARG TARGETARCH
ARG TARGETOS
RUN CGO_ENABLED=0 GOOS=$TARGETOS GOARCH=$TARGETARCH \
    go build -trimpath -ldflags "-w -s" -o /app/bin/main .

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

COPY --from=builder /app/bin/main /usr/local/bin/mcp-auth-proxy
ENV DATA_PATH=/data

ENTRYPOINT [ "/usr/local/bin/mcp-auth-proxy" ]
