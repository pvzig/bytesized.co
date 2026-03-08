---
name: swift-format
description: Format Swift code in place with `swift-format format PATH --recursive --parallel -i`. Use when asked to format Swift projects or Swift source trees before review, testing, or commit.
---

# Swift Format

## Overview

Run the repository's Swift formatter command in a consistent way.
Use the bundled script to apply formatting recursively and in place.

## Run Formatter

1. Run the helper script from the target repository root:
   `./skills/swift-format/scripts/run-swift-format.sh`
2. Pass a path to scope formatting when needed:
   `./skills/swift-format/scripts/run-swift-format.sh Sources`

## Script Behavior

- Execute:
  `swift-format format <path> --recursive --parallel -i`
- Default `<path>` to `.` when omitted.
- Exit with a clear error if `swift-format` is unavailable.

## Validate

Run:
`python3 /Users/pvzig/.codex/skills/.system/skill-creator/scripts/quick_validate.py skills/swift-format`
