# User-Facing Script Documentation Template

Use this pattern for scripts intended to be run by users or operators.

## Python Script Header Template
```python
"""Short script summary.

Purpose:
    One short paragraph describing what the script is for.

Inputs:
    Key files, devices, arguments, or environment assumptions.

Outputs:
    Files created, topics affected, or side effects produced.

Usage:
    python3 script_name.py --example value

Notes:
    Operational caveats, destructive behavior, hardware assumptions, or order of
    operations when relevant.
"""
```

## Shell Script Header Template
```bash
#!/usr/bin/env bash
# Short script summary.
#
# Purpose:
#   One short paragraph describing what the script is for.
#
# Inputs:
#   Key arguments, files, devices, or environment assumptions.
#
# Outputs:
#   Files created, state changed, or side effects produced.
#
# Usage:
#   ./script_name.sh --example value
#
# Notes:
#   Operational caveats, destructive behavior, or ordering requirements.
```

## Rules
- Keep the header short and useful.
- Focus on purpose, invocation, inputs, outputs, and operator-facing caveats.
- Do not narrate implementation details.
- Throwaway local helper scripts do not need a polished header unless they are intended for reuse.
