#!/usr/bin/env bash
# Internal GOAT build helper for use inside the Isaac ROS container only.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
workspace_dir="$repo_root/ros_ws"
goat_ros_dir="$workspace_dir/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"
workspace_setup="$workspace_dir/install/setup.bash"

source /opt/ros/humble/setup.bash

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir." >&2
  echo "Run ./scripts/dev/bootstrap.sh first." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir." >&2
  echo "Run ./scripts/dev/bootstrap.sh first." >&2
  exit 1
fi

mkdir -p "$workspace_dir/build" "$workspace_dir/install" "$workspace_dir/log"

colcon build \
  --base-paths "$goat_vesc_dir" \
  --build-base "$workspace_dir/build" \
  --install-base "$workspace_dir/install" \
  --log-base "$workspace_dir/log" \
  --symlink-install \
  --packages-select goat_vesc \
  "$@"

if [[ ! -f "$workspace_setup" ]]; then
  echo "Workspace setup file not found at $workspace_setup after building goat_vesc." >&2
  exit 1
fi

source "$workspace_setup"

colcon build \
  --base-paths "$goat_vesc_dir" "$goat_ros_dir" \
  --build-base "$workspace_dir/build" \
  --install-base "$workspace_dir/install" \
  --log-base "$workspace_dir/log" \
  --symlink-install \
  --packages-select goat_vesc_ros goat_teleop goat_ros_launch \
  "$@"
