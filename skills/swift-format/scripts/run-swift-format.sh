#!/usr/bin/env bash
set -euo pipefail

target_path="${1:-.}"

if ! command -v swift-format >/dev/null 2>&1; then
  echo "Error: swift-format is not available on PATH." >&2
  exit 1
fi

if [[ ! -e "$target_path" ]]; then
  echo "Error: path does not exist: $target_path" >&2
  exit 1
fi

swift-format format "$target_path" --recursive --parallel -i
