#!/usr/bin/env bash
# Prepare a fresh GOAT checkout for Isaac ROS development.
#
# Purpose:
#   Sync manifest-managed repositories, ensure the Isaac ROS image config is
#   present, launch the upstream Isaac dev container, install dependencies, and
#   prepare the workspace artifact directories from the host.
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
source "$repo_root/scripts/_lib/isaac_container.sh"

root_isaac_config_file="$repo_root/.isaac_ros_common-config"
isaac_repo_dir="$repo_root/ros_ws/src/isaac_ros_common"
goat_ros_dir="$repo_root/ros_ws/src/goat_ros"
goat_vesc_dir="$repo_root/external/goat_vesc"
container_script="$repo_root/scripts/dev/_bootstrap_in_container.sh"
container_script_in_workspace="$GOAT_CONTAINER_WORKSPACE/scripts/dev/_bootstrap_in_container.sh"

if goat_is_inside_isaac_container; then
  echo "./scripts/dev/bootstrap.sh must be run on the host, not from inside the Isaac ROS container." >&2
  exit 1
fi

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

if [[ ! -f "$root_isaac_config_file" ]]; then
  echo "Repo Isaac ROS config was not found at $root_isaac_config_file." >&2
  exit 1
fi

if [[ ! -d "$isaac_repo_dir" ]]; then
  echo "Isaac ROS source tree not found at $isaac_repo_dir after manifest sync." >&2
  echo "Check isaac_ros.repos and rerun ./scripts/dev/bootstrap.sh." >&2
  exit 1
fi

if [[ ! -f "$container_script" ]]; then
  echo "Internal bootstrap helper not found at $container_script." >&2
  exit 1
fi

if [[ ! -d "$goat_ros_dir" ]]; then
  echo "GOAT ROS source tree not found at $goat_ros_dir after manifest sync." >&2
  exit 1
fi

if [[ ! -d "$goat_vesc_dir" ]]; then
  echo "GOAT VESC source tree not found at $goat_vesc_dir after manifest sync." >&2
  exit 1
fi

goat_sync_repo_isaac_config

export TERM="${TERM:-xterm}"
goat_exec_in_isaac_container "$container_script_in_workspace"
