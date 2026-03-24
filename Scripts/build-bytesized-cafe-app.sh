#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BYTESIZED_CAFE_DIR="${ROOT_DIR}/BytesizedCafe"
OUTPUT_DIR="${ROOT_DIR}/bytesized-cafe-app"
PACKAGE_OUTPUT_DIR="${BYTESIZED_CAFE_DIR}/.build/plugins/PackageToJS/outputs/Package"
PRODUCT_NAME="BytesizedCafe"
SDK_LIST="$(swift sdk list)"
SWIFT_WASM_SDK_ID="${SWIFT_WASM_SDK_ID:-${SWIFT_SDK_ID:-}}"

if [[ -z "${SWIFT_WASM_SDK_ID}" ]]; then
    if grep -Fxq "wasm32-unknown-wasi" <<< "${SDK_LIST}"; then
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
