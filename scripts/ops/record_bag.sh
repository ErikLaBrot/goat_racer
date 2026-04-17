#!/usr/bin/env bash
# Reserve the rosbag recording entrypoint for later bringup work.
#
# Purpose:
#   Document where rosbag recording will live once topic profiles and operator
#   workflow are pinned down.
#
# Inputs:
#   Future rosbag arguments.
#
# Outputs:
#   Prints the current fallback workflow.
#
# Usage:
#   ./scripts/ops/record_bag.sh
#
# Notes:
#   This is a Stage 1 placeholder.
set -euo pipefail

cat <<'EOF'
record_bag.sh is a Stage 1 placeholder.

For now:
1. Enter the dev container with ./scripts/dev/enter.sh
2. Run ros2 bag record manually
3. Write bags under /workspace/goat_racer/ros_ws/bags
EOF

exit 1
