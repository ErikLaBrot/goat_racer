#!/usr/bin/env bash
# Reserve the control launch entrypoint for later bringup work.
#
# Purpose:
#   Hold the future operator-facing command for the GOAT control stack.
#
# Inputs:
#   Future launch arguments.
#
# Outputs:
#   Prints the current placeholder guidance.
#
# Usage:
#   ./scripts/ops/run_control.sh
#
# Notes:
#   This is a Stage 1 placeholder.
set -euo pipefail

cat <<'EOF'
run_control.sh is a Stage 1 placeholder.

The control launch path has not been wired in this repo yet.
Use ./scripts/dev/enter.sh to work inside the shared container while bringup
entrypoints are finalized.
EOF

exit 1
