#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENV_FILE="${ROOT_DIR}/.ENV"
TARGET_REPOSITORY=""

repository_variable_names=(
    AWS_REGION
    GENERATED_IMAGES_BUCKET
    OPENAI_IMAGE_MODEL
    IMAGE_GEN_PREFIX
)

repository_secret_names=(
    AWS_S3_BUCKET
    OPENAI_API_KEY
    AWS_ACCESS_KEY_ID
    AWS_SECRET_ACCESS_KEY
)

usage() {
    cat <<'USAGE'
Usage: ./Scripts/sync-github-actions-config.sh [--env-file PATH] [--repo OWNER/REPO]

Sync the GitHub Actions repository variables and secrets that overlap with the local .ENV file.
Values are streamed to `gh` over stdin so secrets do not appear in command arguments.
USAGE
}

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Required command '${command_name}' is not installed or not on PATH." >&2
        exit 1
    fi
}

load_env_file() {
    if [[ ! -f "${ENV_FILE}" ]]; then
        echo "Local env file not found at ${ENV_FILE}." >&2
        exit 1
    fi

    set -a
    # shellcheck disable=SC1090
    source "${ENV_FILE}"
    set +a
}

require_value() {
    local variable_name="$1"

    if [[ -n "${!variable_name:-}" ]]; then
        return
    fi

    echo "Required value '${variable_name}' is missing from ${ENV_FILE}." >&2
    exit 1
}

sync_repository_variable() {
    local variable_name="$1"

    require_value "${variable_name}"
    printf '%s' "${!variable_name}" | run_gh variable set "${variable_name}"
}

sync_repository_secret() {
    local secret_name="$1"

    require_value "${secret_name}"
    printf '%s' "${!secret_name}" | run_gh secret set "${secret_name}"
}

run_gh() {
    if [[ -n "${TARGET_REPOSITORY}" ]]; then
        gh "$@" --repo "${TARGET_REPOSITORY}"
        return
    fi

    gh "$@"
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --env-file)
            ENV_FILE="$2"
            shift 2
            ;;
        --repo)
            TARGET_REPOSITORY="$2"
            shift 2
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "Unknown argument: $1" >&2
            usage >&2
            exit 1
            ;;
    esac
done

require_command gh

if ! gh auth status >/dev/null 2>&1; then
    echo "GitHub CLI is not authenticated. Run 'gh auth login' first." >&2
    exit 1
fi

if ! run_gh repo view >/dev/null 2>&1; then
    echo "GitHub CLI could not resolve the target repository. Run from a cloned repo or pass --repo OWNER/REPO." >&2
    exit 1
fi

load_env_file

echo "Syncing GitHub Actions repository variables:"
for variable_name in "${repository_variable_names[@]}"; do
    echo "  - ${variable_name}"
    sync_repository_variable "${variable_name}"
done

echo "Syncing GitHub Actions repository secrets:"
for secret_name in "${repository_secret_names[@]}"; do
    echo "  - ${secret_name}"
    sync_repository_secret "${secret_name}"
done

cat <<'EOF'
Synchronized the overlapping GitHub Actions repository configuration from the local env file.
These deployment-only values still need to be managed separately because they are not part of the local .ENV:
  - RAILWAY_PROJECT_ID
  - RAILWAY_ENVIRONMENT_NAME
  - RAILWAY_SERVICE_NAME
  - RAILWAY_TOKEN
  - BYTESIZED_CAFE_API_URL
EOF
