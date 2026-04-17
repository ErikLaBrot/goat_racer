#!/usr/bin/env bash
# Install ROS package dependencies from the workspace source tree.
#
# Purpose:
#   Refresh rosdep metadata and install dependency packages required by the ROS
#   packages under `ros_ws/src`.
#
# Inputs:
#   Docker with `docker compose` and a synced workspace source tree.
#
# Outputs:
#   Installs missing system dependencies inside the development container.
#
# Usage:
#   ./scripts/dev/rosdep_install.sh
#   GOAT_ENV_FILE=docker/env/amd64.env ./scripts/dev/rosdep_install.sh
#
# Notes:
#   Requires at least one ROS package under `ros_ws/src`.
set -eo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_running

container_script=$(cat <<'EOF'
set -eo pipefail

ros_setup="/opt/ros/${ROS_DISTRO:-humble}/setup.bash"
workspace_src="/workspace/goat_racer/ros_ws/src"

if [[ -f "$ros_setup" ]]; then
  # shellcheck disable=SC1090
  source "$ros_setup"
fi

if ! find "$workspace_src" -name package.xml -print -quit | grep -q .; then
  echo "No ROS packages found under $workspace_src. Run ./scripts/dev/sync_repos.sh first." >&2
  exit 1
fi

rosdep update
rosdep install --from-paths "$workspace_src" --ignore-src --rosdistro "${ROS_DISTRO:-humble}" -r -y
EOF
)

run_in_container "$container_script"
