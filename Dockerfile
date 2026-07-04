FROM golang:1.25 AS builder
WORKDIR /src

COPY go.mod go.sum ./
RUN go mod download

COPY . .
ARG TARGETOS TARGETARCH
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} \
    go build -trimpath -ldflags="-s -w" -o /out/events-api cmd/main.go

FROM ubuntu:24.04
WORKDIR /app

RUN apt-get update && apt-get install -y --no-install-recommends ca-certificates && \
    rm -rf /var/lib/apt/lists/* && \
    groupadd -r appuser && \
    useradd -r -g appuser appuser && \
    chown -R appuser:appuser /app

COPY --from=builder /out/events-api /app/events-api

USER appuser
EXPOSE 8000

CMD ["./events-api"]
