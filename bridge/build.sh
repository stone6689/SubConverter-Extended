#!/bin/bash
# Build Go static library for mihomo parser bridge

set -e

cd "$(dirname "$0")"

echo "==> Downloading Go dependencies..."
go mod download

echo "==> Building static library..."
go build \
    -buildmode=c-archive \
    -ldflags="-s -w" \
    -o libmihomo.a \
    converter.go

echo "==> Build完成！"
echo "Generated files:"
ls -lh libmihomo.a libmihomo.h

echo ""
echo "==> Library info:"
file libmihomo.a
size libmihomo.a 2>/dev/null || stat -c%s libmihomo.a
