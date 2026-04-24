#!/usr/bin/env bash
# Shared Isaac ROS container helpers for the supported GOAT workflow.

GOAT_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GOAT_CONTAINER_WORKSPACE="/workspaces/isaac_ros-dev"
GOAT_ROOT_ISAAC_CONFIG_FILE="$GOAT_REPO_ROOT/.isaac_ros_common-config"
GOAT_ISAAC_REPO_DIR="$GOAT_REPO_ROOT/ros_ws/src/isaac_ros_common"
GOAT_ISAAC_SCRIPTS_DIR="$GOAT_ISAAC_REPO_DIR/scripts"
GOAT_ISAAC_CONFIG_FILE="$GOAT_ISAAC_SCRIPTS_DIR/.isaac_ros_common-config"
GOAT_RUN_DEV_SCRIPT="$GOAT_ISAAC_SCRIPTS_DIR/run_dev.sh"

goat_is_inside_isaac_container() {
  [[ -f /.dockerenv || "${ISAAC_ROS_WS:-}" == "$GOAT_CONTAINER_WORKSPACE" ]]
}

goat_safe_source() {
  local had_nounset=0

  case $- in
    *u*)
      had_nounset=1
      set +u
      ;;
  esac

  # shellcheck disable=SC1090
  source "$1"
  local status=$?

  if (( had_nounset )); then
    set -u
  fi

  return "$status"
}

goat_sync_repo_isaac_config() {
  if [[ ! -f "$GOAT_ROOT_ISAAC_CONFIG_FILE" ]]; then
    echo "Repo Isaac ROS config was not found at $GOAT_ROOT_ISAAC_CONFIG_FILE." >&2
    exit 1
  fi

  if [[ ! -d "$GOAT_ISAAC_SCRIPTS_DIR" ]]; then
    echo "Isaac ROS scripts were not found at $GOAT_ISAAC_SCRIPTS_DIR." >&2
    echo "Run ./scripts/dev/bootstrap.sh first." >&2
    exit 1
  fi

  cp "$GOAT_ROOT_ISAAC_CONFIG_FILE" "$GOAT_ISAAC_CONFIG_FILE"
}

goat_run_in_isaac_dev() {
  local container_script="$1"
  shift

  goat_sync_repo_isaac_config

  if [[ ! -x "$GOAT_RUN_DEV_SCRIPT" ]]; then
    echo "Isaac ROS run_dev.sh was not found at $GOAT_RUN_DEV_SCRIPT." >&2
    echo "Run ./scripts/dev/bootstrap.sh first." >&2
    exit 1
  fi

  exec "$GOAT_RUN_DEV_SCRIPT" -d "$GOAT_REPO_ROOT" -- "$container_script" "$@"
}
