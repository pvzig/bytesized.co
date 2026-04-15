#!/usr/bin/env bash

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BACKEND_DIR="${ROOT_DIR}/Backend"
BACKEND_DOCKERFILE="${BACKEND_DIR}/Dockerfile"
WORKFLOW_DIR="${ROOT_DIR}/.github/workflows"

require_command() {
    local command_name="$1"

    if ! command -v "${command_name}" >/dev/null 2>&1; then
        echo "Required command '${command_name}' is not installed or not on PATH." >&2
        exit 1
    fi
}

require_command docker
require_command ruby

if [[ ! -f "${BACKEND_DOCKERFILE}" ]]; then
    echo "Expected backend Dockerfile at ${BACKEND_DOCKERFILE}." >&2
    exit 1
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker is installed, but the Docker daemon is not running." >&2
    exit 1
fi

echo "Validating Railway backend container build..."
docker build --file "${BACKEND_DOCKERFILE}" "${BACKEND_DIR}"

workflow_files=()
while IFS= read -r workflow_file; do
    workflow_files+=("${workflow_file}")
done < <(find "${WORKFLOW_DIR}" -maxdepth 1 -type f \( -name "*.yml" -o -name "*.yaml" \) | sort)

if [[ ${#workflow_files[@]} -eq 0 ]]; then
    echo "No GitHub Actions workflow files were found in ${WORKFLOW_DIR}." >&2
    exit 1
fi

echo "Validating GitHub Actions workflow YAML..."
ruby -e '
require "yaml"

ARGV.each do |path|
  YAML.load_file(path)
end

puts "Workflow YAML is valid."
' "${workflow_files[@]}"

if command -v actionlint >/dev/null 2>&1; then
    echo "Running actionlint..."
    actionlint
else
    echo "actionlint is not installed; skipped semantic workflow validation."
fi
