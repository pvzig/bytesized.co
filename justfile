set dotenv-load := true
set dotenv-filename := ".ENV"

help:
    @just --list --unsorted

wasm:
    ./Scripts/build-bytesized-cafe-app.sh

site:
    swift run bytesized

site-release:
    swift run -c release bytesized

site-local:
    test -n "${BYTESIZED_CAFE_API_URL:-}" || (echo "Missing BYTESIZED_CAFE_API_URL. Set it in .ENV or your shell." >&2; exit 1)
    BYTESIZED_CAFE_API_URL="${BYTESIZED_CAFE_API_URL}" swift run bytesized

backend:
    test -n "${OPENAI_API_KEY:-}" || (echo "Missing OPENAI_API_KEY. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${GENERATED_IMAGES_BUCKET:-}" || (echo "Missing GENERATED_IMAGES_BUCKET. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${OPENAI_IMAGE_MODEL:-}" || (echo "Missing OPENAI_IMAGE_MODEL. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${IMAGE_GEN_PREFIX:-}" || (echo "Missing IMAGE_GEN_PREFIX. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${AWS_REGION:-}" || (echo "Missing AWS_REGION. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${AWS_ACCESS_KEY_ID:-}" || (echo "Missing AWS_ACCESS_KEY_ID. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${AWS_SECRET_ACCESS_KEY:-}" || (echo "Missing AWS_SECRET_ACCESS_KEY. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${HOST:-${BACKEND_HOST:-}}" || (echo "Missing HOST or BACKEND_HOST. Set it in .ENV or your shell." >&2; exit 1)
    test -n "${PORT:-${BACKEND_PORT:-}}" || (echo "Missing PORT or BACKEND_PORT. Set it in .ENV or your shell." >&2; exit 1)
    swift run --package-path Backend Server

site-deploy:
    test -n "${AWS_S3_BUCKET:-}" || (echo "Missing AWS_S3_BUCKET. Set it in .ENV or your shell." >&2; exit 1)
    aws s3 sync Output/ "s3://${AWS_S3_BUCKET}" --delete --exclude ".DS_Store"

local:
    ./Scripts/run-local.sh

validate-deployment:
    ./Scripts/validate-deployment-config.sh
