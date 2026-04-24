#!/usr/bin/env bash
# Enter the Isaac ROS development container from the repo root.
#
# Purpose:
#   Hand off directly to NVIDIA's `run_dev.sh` from the vendored
#   `isaac_ros_common` checkout for container build, launch, and attach
#   behavior.
#
# Inputs:
#   Optional `/bin/bash` arguments passed through to the upstream Isaac ROS
#   dev-container entrypoint.
#
# Outputs:
#   Reuses or launches the Isaac ROS dev container for this repository.
#
# Usage:
#   ./scripts/dev/enter.sh
#   ./scripts/dev/enter.sh -lc 'colcon list'
#
# Notes:
#   This is the primary Stage 2A terminal entrypoint.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dev_script="$repo_root/ros_ws/src/isaac_ros_common/scripts/run_dev.sh"

if [[ ! -f "$run_dev_script" ]]; then
  echo "Isaac ROS run_dev.sh was not found at $run_dev_script." >&2
  echo "Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

export TERM="${TERM:-xterm}"

if [[ $# -eq 0 ]]; then
  exec "$run_dev_script" -d "$repo_root"
fi

exec "$run_dev_script" -d "$repo_root" -- "$@"
