#!/usr/bin/env bash
# Reserve the NVBlox launch entrypoint for later bringup work.
#
# Purpose:
#   Hold the future operator-facing command for NVBlox integration once the
#   mapping workflow is ready.
#
# Inputs:
#   Future launch arguments.
#
# Outputs:
#   Prints the current placeholder guidance.
#
# Usage:
#   ./scripts/ops/run_nvblox.sh
#
# Notes:
#   This is a Stage 1 placeholder.
set -euo pipefail

cat <<'EOF'
run_nvblox.sh is a Stage 1 placeholder.

Stage 2A only establishes the Isaac ROS Visual SLAM baseline.
NVBlox launch automation will be added in a later task.
EOF

exit 1
