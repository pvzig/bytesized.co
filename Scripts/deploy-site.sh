#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUTPUT_DIR="${ROOT_DIR}/Output"
WASM_KEY="bytesized-cafe-app/BytesizedCafe.wasm"
WASM_PATH="${OUTPUT_DIR}/${WASM_KEY}"

if [[ -z "${AWS_S3_BUCKET:-}" ]]; then
    echo "Missing AWS_S3_BUCKET. Set it in .ENV or your shell." >&2
    exit 1
fi

if [[ ! -f "${WASM_PATH}" ]]; then
    echo "Expected wasm artifact at ${WASM_PATH}. Run the site build before deploying." >&2
    exit 1
fi

GZIPPED_WASM_PATH="$(mktemp "${TMPDIR:-/tmp}/BytesizedCafe.wasm.XXXXXX.gz")"
trap 'rm -f "${GZIPPED_WASM_PATH}"' EXIT

gzip -9 -c "${WASM_PATH}" > "${GZIPPED_WASM_PATH}"

aws s3 sync "${OUTPUT_DIR}/" "s3://${AWS_S3_BUCKET}" \
    --delete \
    --exclude ".DS_Store" \
    --exclude "${WASM_KEY}"

aws s3 cp "${GZIPPED_WASM_PATH}" "s3://${AWS_S3_BUCKET}/${WASM_KEY}" \
    --content-type "application/wasm" \
    --content-encoding "gzip" \
    --cache-control "public, max-age=31536000, immutable"
