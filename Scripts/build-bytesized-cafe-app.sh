#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BYTESIZED_CAFE_DIR="${ROOT_DIR}/BytesizedCafe"
OUTPUT_DIR="${ROOT_DIR}/bytesized-cafe-app"
PACKAGE_OUTPUT_DIR="${BYTESIZED_CAFE_DIR}/.build/plugins/PackageToJS/outputs/Package"
PRODUCT_NAME="BytesizedCafe"
SDK_LIST="$(swift sdk list)"
SWIFT_WASM_SDK_ID="${SWIFT_WASM_SDK_ID:-${SWIFT_SDK_ID:-}}"
SWIFT_VERSION="$(swift --version | sed -n '1s/.*Swift version \([0-9][0-9.]*\).*/\1/p')"
PREFERRED_SWIFT_WASM_SDK_ID=""
WASM_OUTPUT_PATH="${OUTPUT_DIR}/${PRODUCT_NAME}.wasm"

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Required command '${command_name}' is not installed or not on PATH." >&2
        exit 1
    fi
}

format_bytes() {
    local path="$1"
    wc -c < "${path}" | tr -d ' '
}

require_command wasm-opt

if [[ -n "${SWIFT_VERSION}" ]]; then
    PREFERRED_SWIFT_WASM_SDK_ID="swift-${SWIFT_VERSION}-RELEASE_wasm"
fi

if [[ -z "${SWIFT_WASM_SDK_ID}" ]]; then
    if [[ -n "${PREFERRED_SWIFT_WASM_SDK_ID}" ]] && grep -Fxq "${PREFERRED_SWIFT_WASM_SDK_ID}" <<< "${SDK_LIST}"; then
        SWIFT_WASM_SDK_ID="${PREFERRED_SWIFT_WASM_SDK_ID}"
    elif grep -Fxq "wasm32-unknown-wasi" <<< "${SDK_LIST}"; then
        SWIFT_WASM_SDK_ID="wasm32-unknown-wasi"
    else
        SWIFT_WASM_SDK_ID="$(grep 'wasm' <<< "${SDK_LIST}" | grep -v 'embedded' | head -n 1 || true)"
    fi
fi

if [[ -z "${SWIFT_WASM_SDK_ID}" ]] || ! grep -Fxq "${SWIFT_WASM_SDK_ID}" <<< "${SDK_LIST}"; then
    echo "Swift SDK '${SWIFT_WASM_SDK_ID}' is not installed." >&2
    echo "Install a WebAssembly Swift SDK first: https://www.swift.org/documentation/articles/wasm-getting-started.html" >&2
    exit 1
fi

rm -rf "${OUTPUT_DIR}"
mkdir -p "${OUTPUT_DIR}"

pushd "${BYTESIZED_CAFE_DIR}" >/dev/null
swift package --swift-sdk "${SWIFT_WASM_SDK_ID}" js --product "${PRODUCT_NAME}" -c release --use-cdn

if [[ ! -d "${PACKAGE_OUTPUT_DIR}" ]]; then
    echo "PackageToJS did not produce ${PRODUCT_NAME} artifacts." >&2
    exit 1
fi

cp -R "${PACKAGE_OUTPUT_DIR}/." "${OUTPUT_DIR}"
popd >/dev/null

if [[ ! -f "${WASM_OUTPUT_PATH}" ]]; then
    echo "Expected wasm artifact at ${WASM_OUTPUT_PATH}." >&2
    exit 1
fi

ORIGINAL_WASM_SIZE="$(format_bytes "${WASM_OUTPUT_PATH}")"
OPTIMIZED_WASM_PATH="$(mktemp "${OUTPUT_DIR}/${PRODUCT_NAME}.wasm.XXXXXX")"
trap 'rm -f "${OPTIMIZED_WASM_PATH}"' EXIT

wasm-opt \
    -Oz \
    --strip-debug \
    --strip-producers \
    "${WASM_OUTPUT_PATH}" \
    -o "${OPTIMIZED_WASM_PATH}"

mv "${OPTIMIZED_WASM_PATH}" "${WASM_OUTPUT_PATH}"
OPTIMIZED_WASM_SIZE="$(format_bytes "${WASM_OUTPUT_PATH}")"

echo "Optimized ${PRODUCT_NAME}.wasm with Binaryen: ${ORIGINAL_WASM_SIZE} -> ${OPTIMIZED_WASM_SIZE} bytes"
