#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOCAL_ENV_FILE="${LOCAL_ENV_FILE:-${ROOT_DIR}/.ENV}"
BACKEND_STARTUP_TIMEOUT=30
SITE_STARTUP_TIMEOUT=10

backend_pid=""
site_server_pid=""

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Required command '${command_name}' is not installed or not on PATH." >&2
        exit 1
    fi
}

load_local_env() {
    if [[ ! -f "${LOCAL_ENV_FILE}" ]]; then
        echo "No local env file found at ${LOCAL_ENV_FILE}; using the current shell environment."
        return
    fi

    echo "Loading ${LOCAL_ENV_FILE}"
    set -a
    # shellcheck disable=SC1090
    source "${LOCAL_ENV_FILE}"
    set +a
}

require_value() {
    local variable_name="$1"
    local value="$2"

    if [[ -n "${value}" ]]; then
        return
    fi

    echo "Required value '${variable_name}' is missing." >&2
    exit 1
}

cleanup() {
    local exit_code=$?

    if [[ -n "${site_server_pid}" ]] && kill -0 "${site_server_pid}" >/dev/null 2>&1; then
        kill "${site_server_pid}" >/dev/null 2>&1 || true
        wait "${site_server_pid}" 2>/dev/null || true
    fi

    if [[ -n "${backend_pid}" ]] && kill -0 "${backend_pid}" >/dev/null 2>&1; then
        kill "${backend_pid}" >/dev/null 2>&1 || true
        wait "${backend_pid}" 2>/dev/null || true
    fi

    return "${exit_code}"
}

build_backend() {
    echo "Building the backend"
    (
        cd "${ROOT_DIR}"
        env "${backend_environment[@]}" swift build --package-path Backend --product Server
    )
}

wait_for_backend() {
    local attempt=1

    while (( attempt <= BACKEND_STARTUP_TIMEOUT )); do
        if curl -fsS "${health_url}" >/dev/null 2>&1; then
            echo "Backend is healthy at ${health_url}"
            return
        fi

        if [[ -n "${backend_pid}" ]] && ! kill -0 "${backend_pid}" >/dev/null 2>&1; then
            wait "${backend_pid}"
        fi

        sleep 1
        ((attempt++))
    done

    echo "Backend did not become healthy at ${health_url} within ${BACKEND_STARTUP_TIMEOUT} seconds." >&2
    exit 1
}

wait_for_site() {
    local attempt=1

    while (( attempt <= SITE_STARTUP_TIMEOUT )); do
        if curl -fsS "${site_url}" >/dev/null 2>&1; then
            echo "Site is ready at ${site_url}"
            return
        fi

        if [[ -n "${site_server_pid}" ]] && ! kill -0 "${site_server_pid}" >/dev/null 2>&1; then
            wait "${site_server_pid}"
        fi

        sleep 1
        ((attempt++))
    done

    echo "Site did not become ready at ${site_url} within ${SITE_STARTUP_TIMEOUT} seconds." >&2
    exit 1
}

open_site_in_browser() {
    if command -v open >/dev/null 2>&1; then
        open "${site_url}"
        return
    fi

    if command -v xdg-open >/dev/null 2>&1; then
        xdg-open "${site_url}" >/dev/null 2>&1 &
        return
    fi

    echo "No browser launcher command found; open ${site_url} manually."
}

trap cleanup EXIT

require_command curl
require_command swift
require_command python3

load_local_env

site_host="${SITE_HOST:-}"
site_port="${SITE_PORT:-}"
backend_host="${BACKEND_HOST:-}"
backend_port="${BACKEND_PORT:-}"
generated_images_bucket="${GENERATED_IMAGES_BUCKET:-}"
openai_model="${OPENAI_IMAGE_MODEL:-}"
image_gen_prefix="${IMAGE_GEN_PREFIX:-}"
aws_region="${AWS_REGION:-}"
aws_access_key_id="${AWS_ACCESS_KEY_ID:-}"
aws_secret_access_key="${AWS_SECRET_ACCESS_KEY:-}"

require_value "OPENAI_API_KEY" "${OPENAI_API_KEY:-}"
require_value "SITE_HOST" "${site_host}"
require_value "SITE_PORT" "${site_port}"
require_value "BACKEND_HOST" "${backend_host}"
require_value "BACKEND_PORT" "${backend_port}"
require_value "GENERATED_IMAGES_BUCKET" "${generated_images_bucket}"
require_value "OPENAI_IMAGE_MODEL" "${openai_model}"
require_value "IMAGE_GEN_PREFIX" "${image_gen_prefix}"
require_value "AWS_REGION" "${aws_region}"
require_value "AWS_ACCESS_KEY_ID" "${aws_access_key_id}"
require_value "AWS_SECRET_ACCESS_KEY" "${aws_secret_access_key}"

health_url="http://${backend_host}:${backend_port}/health"
api_url="http://${backend_host}:${backend_port}/api/cafe/generate"
site_url="http://${site_host}:${site_port}"

echo "Building the SwiftWASM app"
"${ROOT_DIR}/Scripts/build-bytesized-cafe-app.sh"

echo "Publishing the site with API URL ${api_url}"
(
    cd "${ROOT_DIR}"
    env BYTESIZED_CAFE_API_URL="${api_url}" swift run bytesized
)

backend_environment=(
    "HOST=${backend_host}"
    "PORT=${backend_port}"
    "GENERATED_IMAGES_BUCKET=${generated_images_bucket}"
    "OPENAI_API_KEY=${OPENAI_API_KEY}"
    "OPENAI_IMAGE_MODEL=${openai_model}"
    "IMAGE_GEN_PREFIX=${image_gen_prefix}"
    "AWS_REGION=${aws_region}"
    "AWS_ACCESS_KEY_ID=${aws_access_key_id}"
    "AWS_SECRET_ACCESS_KEY=${aws_secret_access_key}"
)

build_backend

echo "Starting the backend on http://${backend_host}:${backend_port}"
(
    cd "${ROOT_DIR}"
    env "${backend_environment[@]}" swift run --skip-build --package-path Backend Server
) &
backend_pid=$!

wait_for_backend

echo "Serving Output at ${site_url}"
python3 -m http.server "${site_port}" --bind "${site_host}" --directory "${ROOT_DIR}/Output" &
site_server_pid=$!

wait_for_site
echo "Opening ${site_url} in the default browser"
open_site_in_browser

wait "${site_server_pid}"
