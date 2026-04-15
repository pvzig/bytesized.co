---
name: swift-test
description: Run Swift package tests with `swift test --parallel`. Use when asked to execute project tests, verify implementation changes, or run the Swift test suite before commit.
---

# Swift Test

## Overview

Run the repository test suite with the project's parallel test command.
Use the bundled script for consistent test execution and optional extra flags.

## Run Tests

1. Run the helper script from the target repository root:
   `./skills/swift-test/scripts/run-swift-tests.sh`
2. Pass optional extra `swift test` flags when needed:
   `./skills/swift-test/scripts/run-swift-tests.sh --filter narutoTests`

## Script Behavior

- Execute:
  `swift test --parallel "$@"`
- Always include `--parallel`.
- Forward any additional CLI flags to `swift test`.
- Exit with a clear error if `swift` is unavailable.

## Validate

Run:
`mise x python@3.12 -- python /Users/pvzig/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/swift-test`
