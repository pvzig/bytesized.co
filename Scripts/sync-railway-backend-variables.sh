#!/usr/bin/env bash

set -euo pipefail

required_environment_variables=(
    AWS_ACCESS_KEY_ID
    AWS_REGION
    AWS_SECRET_ACCESS_KEY
    GENERATED_IMAGES_BUCKET
    IMAGE_GEN_PREFIX
    OPENAI_API_KEY
    OPENAI_IMAGE_MODEL
    RAILWAY_ENVIRONMENT_NAME
    RAILWAY_PROJECT_ID
    RAILWAY_SERVICE_NAME
    RAILWAY_TOKEN
)

for variable_name in "${required_environment_variables[@]}"; do
    if [[ -z "${!variable_name:-}" ]]; then
        echo "Missing required environment variable '${variable_name}'." >&2
        exit 1
    fi
done

backendHost="${RAILWAY_RUNTIME_HOST:-0.0.0.0}"
backendPort="${RAILWAY_RUNTIME_PORT:-8080}"

set_railway_variable() {
    npx -y @railway/cli variable set \
        --service "${RAILWAY_SERVICE_NAME}" \
        --environment "${RAILWAY_ENVIRONMENT_NAME}" \
        --skip-deploys \
        "$@"
}

set_railway_secret_from_stdin() {
    local variable_name="$1"
    local variable_value="$2"

    printf '%s' "${variable_value}" | npx -y @railway/cli variable set \
        --stdin \
        --service "${RAILWAY_SERVICE_NAME}" \
        --environment "${RAILWAY_ENVIRONMENT_NAME}" \
        --skip-deploys \
        "${variable_name}"
}

set_railway_variable \
    "HOST=${backendHost}" \
    "PORT=${backendPort}" \
    "GENERATED_IMAGES_BUCKET=${GENERATED_IMAGES_BUCKET}" \
    "OPENAI_IMAGE_MODEL=${OPENAI_IMAGE_MODEL}" \
    "IMAGE_GEN_PREFIX=${IMAGE_GEN_PREFIX}" \
    "AWS_REGION=${AWS_REGION}"

set_railway_secret_from_stdin "OPENAI_API_KEY" "${OPENAI_API_KEY}"
set_railway_secret_from_stdin "AWS_ACCESS_KEY_ID" "${AWS_ACCESS_KEY_ID}"
set_railway_secret_from_stdin "AWS_SECRET_ACCESS_KEY" "${AWS_SECRET_ACCESS_KEY}"
