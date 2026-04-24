#!/usr/bin/env bash
# Shared Isaac ROS container helpers for the supported GOAT workflow.

GOAT_REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
GOAT_CONTAINER_WORKSPACE="/workspaces/isaac_ros-dev"
GOAT_ROOT_ISAAC_CONFIG_FILE="$GOAT_REPO_ROOT/.isaac_ros_common-config"
GOAT_ISAAC_REPO_DIR="$GOAT_REPO_ROOT/ros_ws/src/isaac_ros_common"
GOAT_ISAAC_SCRIPTS_DIR="$GOAT_ISAAC_REPO_DIR/scripts"
GOAT_ISAAC_CONFIG_FILE="$GOAT_ISAAC_SCRIPTS_DIR/.isaac_ros_common-config"

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

goat_require_host_docker_access() {
  local host_user="${USER:-$(id -un)}"

  if [[ $(id -u) -eq 0 ]]; then
    echo "This workflow cannot be executed with root privileges." >&2
    echo "Re-run without sudo and configure Docker for non-root access first." >&2
    exit 1
  fi

  if ! command -v docker >/dev/null 2>&1; then
    echo "docker was not found on the host." >&2
    exit 1
  fi

  if ! id -nG "$host_user" | grep -qw docker; then
    echo "User |$host_user| is not a member of the 'docker' group." >&2
    echo "Run 'sudo usermod -aG docker \$USER && newgrp docker', then retry." >&2
    exit 1
  fi

  if ! docker ps >/dev/null 2>&1; then
    echo "Unable to run docker commands on the host." >&2
    echo "Check the Docker installation and group membership, then retry." >&2
    exit 1
  fi

  if ! git lfs version >/dev/null 2>&1; then
    echo "git-lfs is not installed." >&2
    echo "Install git-lfs before using the supported GOAT workflow." >&2
    exit 1
  fi
}

goat_load_isaac_config() {
  if [[ -f "$GOAT_ROOT_ISAAC_CONFIG_FILE" ]]; then
    goat_safe_source "$GOAT_ROOT_ISAAC_CONFIG_FILE"
  fi

  if [[ -f "$HOME/.isaac_ros_common-config" ]]; then
    goat_safe_source "$HOME/.isaac_ros_common-config"
  fi

  GOAT_PLATFORM="$(uname -m)"
  GOAT_IMAGE_KEY="${CONFIG_IMAGE_KEY:-ros2_humble}"
  GOAT_BASE_IMAGE_KEY="$GOAT_PLATFORM"
  if [[ -n "$GOAT_IMAGE_KEY" ]]; then
    GOAT_BASE_IMAGE_KEY="$GOAT_PLATFORM.$GOAT_IMAGE_KEY"
  fi

  GOAT_BASE_NAME="isaac_ros_dev-$GOAT_PLATFORM"
  if [[ -n "${CONFIG_CONTAINER_NAME_SUFFIX:-}" ]]; then
    GOAT_BASE_NAME="$GOAT_BASE_NAME-$CONFIG_CONTAINER_NAME_SUFFIX"
  fi
  GOAT_CONTAINER_NAME="$GOAT_BASE_NAME-container"

  GOAT_SKIP_IMAGE_BUILD=0
  if [[ -n "${SKIP_DOCKER_BUILD:-}" || -n "${CONFIG_SKIP_IMAGE_BUILD:-}" ]]; then
    GOAT_SKIP_IMAGE_BUILD=1
  fi
}

goat_remove_exited_container() {
  if [[ -n "$(docker ps -a --quiet --filter status=exited --filter "name=^/${GOAT_CONTAINER_NAME}$")" ]]; then
    docker rm "$GOAT_CONTAINER_NAME" >/dev/null
  fi
}

goat_container_is_running() {
  [[ -n "$(docker ps --quiet --filter "name=^/${GOAT_CONTAINER_NAME}$")" ]]
}

goat_exec_running_container() {
  docker exec -i -t -u admin \
    --workdir "$GOAT_CONTAINER_WORKSPACE" \
    "$GOAT_CONTAINER_NAME" \
    /bin/bash "$@"
}

goat_wait_for_running_container() {
  local attempt=0

  until goat_exec_running_container -lc "true" >/dev/null 2>&1; do
    attempt=$((attempt + 1))
    if (( attempt >= 30 )); then
      echo "Timed out waiting for Isaac container $GOAT_CONTAINER_NAME to become ready." >&2
      exit 1
    fi
    sleep 1
  done
}

goat_build_image_if_needed() {
  local build_image_layers_script="$GOAT_ISAAC_SCRIPTS_DIR/build_image_layers.sh"

  if [[ ! -x "$build_image_layers_script" ]]; then
    echo "Isaac ROS build_image_layers.sh was not found at $build_image_layers_script." >&2
    echo "Run ./scripts/dev/bootstrap.sh first." >&2
    exit 1
  fi

  if (( GOAT_SKIP_IMAGE_BUILD == 0 )); then
    if ! "$build_image_layers_script" --image_key "$GOAT_BASE_IMAGE_KEY" --image_name "$GOAT_BASE_NAME"; then
      if [[ -z "$(docker image ls --quiet "$GOAT_BASE_NAME")" ]]; then
        echo "Building Isaac image $GOAT_BASE_NAME failed and no cached image was found." >&2
        exit 1
      fi
    fi
  fi

  if [[ -z "$(docker image ls --quiet "$GOAT_BASE_NAME")" ]]; then
    echo "No built Isaac image was found for $GOAT_BASE_NAME." >&2
    exit 1
  fi
}

goat_append_configured_docker_args() {
  local docker_args_file="${DOCKER_ARGS_FILE:-.isaac_ros_dev-dockerargs}"
  local docker_args_filepath=""
  local arg=""

  if [[ -f "$HOME/$docker_args_file" ]]; then
    docker_args_filepath="$(realpath "$HOME/$docker_args_file")"
  elif [[ -f "$GOAT_ISAAC_SCRIPTS_DIR/$docker_args_file" ]]; then
    docker_args_filepath="$GOAT_ISAAC_SCRIPTS_DIR/$docker_args_file"
  fi

  if [[ -z "$docker_args_filepath" ]]; then
    return 0
  fi

  while IFS= read -r arg; do
    [[ -n "$arg" ]] || continue
    GOAT_DOCKER_ARGS+=($(eval "echo $arg | envsubst"))
  done < "$docker_args_filepath"
}

goat_build_default_docker_args() {
  GOAT_DOCKER_ARGS=()

  GOAT_DOCKER_ARGS+=("-v" "/tmp/.X11-unix:/tmp/.X11-unix")
  GOAT_DOCKER_ARGS+=("-v" "$HOME/.Xauthority:/home/admin/.Xauthority:rw")
  GOAT_DOCKER_ARGS+=("-e" "DISPLAY")
  GOAT_DOCKER_ARGS+=("-e" "NVIDIA_VISIBLE_DEVICES=all")
  GOAT_DOCKER_ARGS+=("-e" "NVIDIA_DRIVER_CAPABILITIES=all")
  GOAT_DOCKER_ARGS+=("-e" "ROS_DOMAIN_ID")
  GOAT_DOCKER_ARGS+=("-e" "USER=${USER:-$(id -un)}")
  GOAT_DOCKER_ARGS+=("-e" "ISAAC_ROS_WS=$GOAT_CONTAINER_WORKSPACE")
  GOAT_DOCKER_ARGS+=("-e" "HOST_USER_UID=$(id -u)")
  GOAT_DOCKER_ARGS+=("-e" "HOST_USER_GID=$(id -g)")

  if [[ -n "${SSH_AUTH_SOCK:-}" ]]; then
    GOAT_DOCKER_ARGS+=("-v" "$SSH_AUTH_SOCK:/ssh-agent")
    GOAT_DOCKER_ARGS+=("-e" "SSH_AUTH_SOCK=/ssh-agent")
  fi

  if [[ "$GOAT_PLATFORM" == "aarch64" ]]; then
    GOAT_DOCKER_ARGS+=("-e" "NVIDIA_VISIBLE_DEVICES=nvidia.com/gpu=all,nvidia.com/pva=all")
    GOAT_DOCKER_ARGS+=("-v" "/usr/bin/tegrastats:/usr/bin/tegrastats")
    GOAT_DOCKER_ARGS+=("-v" "/tmp/:/tmp/")
    GOAT_DOCKER_ARGS+=("-v" "/usr/lib/aarch64-linux-gnu/tegra:/usr/lib/aarch64-linux-gnu/tegra")
    GOAT_DOCKER_ARGS+=("-v" "/usr/src/jetson_multimedia_api:/usr/src/jetson_multimedia_api")
    GOAT_DOCKER_ARGS+=("--pid=host")
    GOAT_DOCKER_ARGS+=("-v" "/usr/share/vpi3:/usr/share/vpi3")
    GOAT_DOCKER_ARGS+=("-v" "/dev/input:/dev/input")

    if getent group jtop >/dev/null 2>&1; then
      GOAT_DOCKER_ARGS+=("-v" "/run/jtop.sock:/run/jtop.sock:ro")
    fi
  fi

  goat_append_configured_docker_args
}

goat_exec_in_isaac_container() {
  local container_script="$1"
  shift

  goat_require_host_docker_access
  goat_sync_repo_isaac_config
  goat_load_isaac_config
  goat_remove_exited_container

  if ! goat_container_is_running; then
    goat_build_image_if_needed
    goat_build_default_docker_args

    docker run -d \
      --privileged \
      --network host \
      --ipc=host \
      "${GOAT_DOCKER_ARGS[@]}" \
      -v "$GOAT_REPO_ROOT:$GOAT_CONTAINER_WORKSPACE" \
      -v /etc/localtime:/etc/localtime:ro \
      --name "$GOAT_CONTAINER_NAME" \
      --runtime nvidia \
      --entrypoint /usr/local/bin/scripts/workspace-entrypoint.sh \
      --workdir "$GOAT_CONTAINER_WORKSPACE" \
      "$GOAT_BASE_NAME" \
      /bin/bash -lc 'trap "exit 0" TERM INT; while true; do sleep 3600; done' >/dev/null

    goat_wait_for_running_container
  fi

  goat_exec_running_container "$container_script" "$@"
  exit $?
}
