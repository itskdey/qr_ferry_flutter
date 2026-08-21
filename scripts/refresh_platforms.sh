#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

echo "Refreshing Flutter platform scaffolding while preserving lib/ and pubspec.yaml..."
cp pubspec.yaml /tmp/qr_ferry_pubspec.yaml
cp -R lib /tmp/qr_ferry_lib

flutter create \
  --platforms=android,ios \
  --org app.itskdey \
  --project-name qr_ferry_flutter \
  .

cp /tmp/qr_ferry_pubspec.yaml pubspec.yaml
rm -rf lib
cp -R /tmp/qr_ferry_lib lib

flutter pub get

echo "Done. Re-apply camera permission/Info.plist changes if Flutter replaced them."
