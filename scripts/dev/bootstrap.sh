#!/usr/bin/env bash
# Prepare a fresh GOAT checkout for Isaac ROS development.
#
# Purpose:
#   Sync manifest-managed repositories, ensure the Isaac ROS image config is
#   present, launch the upstream Isaac dev container, install dependencies, and
#   prepare the workspace artifact directories.
#
# Inputs:
#   Root-level `*.repos` manifests plus a host with `vcs` and Docker access.
#
# Outputs:
#   Updates nested repositories, writes the Isaac ROS config file, installs
#   container dependencies, and prepares `ros_ws/build`, `ros_ws/install`, and
#   `ros_ws/log`.
#
# Usage:
#   ./scripts/dev/bootstrap.sh
#
# Notes:
#   This is the supported fresh-checkout and fresh-robot preparation step.
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dev_script="$repo_root/ros_ws/src/isaac_ros_common/scripts/run_dev.sh"
isaac_config_file="$repo_root/ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config"
goat_ros_dir="$repo_root/ros_ws/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

if ! command -v vcs >/dev/null 2>&1; then
  echo "vcs was not found on the host." >&2
  echo "Install python3-vcstool, then rerun ./scripts/dev/bootstrap.sh." >&2
  exit 1
fi

mapfile -t manifests < <(find "$repo_root" -maxdepth 1 -type f -name '*.repos' | sort)
if [[ ${#manifests[@]} -eq 0 ]]; then
  echo "No root-level .repos manifests were found at $repo_root." >&2
  exit 1
fi

declare -A seen_repo_dirs=()
repo_dirs=()

for manifest in "${manifests[@]}"; do
  echo "Importing repositories from ${manifest##*/}..."
  vcs import "$repo_root" < "$manifest"

  while IFS= read -r repo_path; do
    [[ -n "$repo_path" ]] || continue

    repo_dir="$repo_root/$repo_path"
    if [[ -d "$repo_dir" && -z ${seen_repo_dirs["$repo_dir"]+x} ]]; then
      seen_repo_dirs["$repo_dir"]=1
      repo_dirs+=("$repo_dir")
    fi
  done < <(sed -n 's/^  \([^:][^:]*\):$/\1/p' "$manifest")
done

if [[ ${#repo_dirs[@]} -gt 0 ]]; then
  echo "Pulling manifest-managed repositories..."
  vcs pull "${repo_dirs[@]}"
fi

if [[ ! -f "$run_dev_script" ]]; then
  echo "Isaac ROS run_dev.sh was not found at $run_dev_script after manifest sync." >&2
  echo "Check isaac_ros.repos and rerun ./scripts/dev/bootstrap.sh." >&2
  exit 1
fi

mkdir -p "$(dirname "$isaac_config_file")"
cat > "$isaac_config_file" <<'EOF'
CONFIG_IMAGE_KEY=ros2_humble.realsense
EOF

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir after manifest sync." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir after manifest sync." >&2
  exit 1
fi

export TERM="${TERM:-xterm}"

exec "$run_dev_script" -d "$repo_root" -- -lc '
set -e

repo_root="/workspaces/isaac_ros-dev"
workspace_dir="$repo_root/ros_ws"
goat_ros_dir="$workspace_dir/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"

source /opt/ros/humble/setup.bash

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir after bootstrap sync." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir after bootstrap sync." >&2
  exit 1
fi

rosdep update
rosdep install --from-paths "$goat_vesc_dir" "$goat_ros_dir" --ignore-src --rosdistro humble -r -y

mkdir -p "$workspace_dir/build" "$workspace_dir/install" "$workspace_dir/log"
' bash
