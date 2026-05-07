#!/usr/bin/env bash
# Open an interactive shell in the Isaac ROS development container.
#
# Purpose:
#   Attach to the upstream-managed Isaac ROS development container for manual
#   ROS operations such as topic inspection, RViz, and debug commands.
#
# Inputs:
#   A bootstrapped checkout with `ros_ws/src/isaac_ros_common/scripts/run_dev.sh`.
#
# Outputs:
#   Opens an interactive shell in the Isaac ROS development environment.
#
# Usage:
#   ./scripts/dev/enter.sh
#
# Notes:
#   This command is shell-only; it does not forward one-off command arguments.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "$repo_root/scripts/_lib/isaac_container.sh"

if [[ $# -gt 0 ]]; then
  echo "./scripts/dev/enter.sh does not accept command arguments." >&2
  echo "Open a shell, then run ROS operations such as 'ros2 topic list' inside it." >&2
  exit 1
fi

if goat_is_inside_isaac_container; then
  exec bash -i
fi

export TERM="${TERM:-xterm}"
goat_enter_isaac_dev
