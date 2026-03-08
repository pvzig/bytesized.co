#!/usr/bin/env bash
set -euo pipefail

if ! command -v swift >/dev/null 2>&1; then
  echo "Error: swift is not available on PATH." >&2
  exit 1
fi

swift test --parallel "$@"
