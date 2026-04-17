#!/usr/bin/env bash
# Build the GOAT ROS workspace inside the development container.
#
# Purpose:
#   Run a standard `colcon build --symlink-install` from `ros_ws` using the
#   project dev container.
#
# Inputs:
#   Optional extra `colcon build` arguments.
#
# Outputs:
#   Writes build, install, and log artifacts under `ros_ws/`.
#
# Usage:
#   ./scripts/dev/build_ws.sh
#   ./scripts/dev/build_ws.sh --packages-up-to goat_ros_launch
#
# Notes:
#   Requires a synced workspace with at least one ROS package under `ros_ws/src`.
set -eo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_running

container_script=$(cat <<'EOF'
set -eo pipefail

ros_setup="/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
workspace_dir="/workspace/goat_racer/ros_ws"

if [[ -f "$ros_setup" ]]; then
  # shellcheck disable=SC1090
  source "$ros_setup"
fi

if ! find "$workspace_dir/src" -name package.xml -print -quit | grep -q .; then
  echo "No ROS packages found under $workspace_dir/src. Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

cd "$workspace_dir"
if [[ -d /usr/local/cuda ]]; then
  echo "CUDA toolkit detected at ${CUDA_TOOLKIT_ROOT_DIR:-/usr/local/cuda}"
else
  echo "CUDA toolkit not found at /usr/local/cuda"
fi
colcon build --symlink-install "$@"
EOF
)

run_in_container "$container_script" "$@"
