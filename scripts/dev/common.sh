#!/usr/bin/env bash
# Shared helpers for GOAT development-container scripts.

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
compose_file="$repo_root/docker/compose.dev.yaml"
default_env_file="$repo_root/docker/env/jetson.env"
env_file="${GOAT_ENV_FILE:-$default_env_file}"
service_name="goat-dev"
workspace_root="/workspace/goat_racer"
workspace_dir="$workspace_root/ros_ws"

if [[ "$env_file" != /* ]]; then
  env_file="$repo_root/$env_file"
fi

if [[ ! -f "$compose_file" ]]; then
  echo "Compose file '$compose_file' does not exist." >&2
  exit 1
fi

if [[ ! -f "$env_file" ]]; then
  echo "Environment file '$env_file' does not exist." >&2
  exit 1
fi

compose_args=(
  --env-file "$env_file"
  -f "$compose_file"
)

print_command() {
  printf 'Running:'
  printf ' %q' "$@"
  printf '\n'
}

run_compose() {
  print_command docker compose "${compose_args[@]}" "$@"
  docker compose "${compose_args[@]}" "$@"
}

is_running() {
  local services

  services="$(docker compose "${compose_args[@]}" ps --status running --services 2>/dev/null || true)"
  [[ "$services" == *"$service_name"* ]]
}

ensure_running() {
  if is_running; then
    return
  fi

  echo "Starting development container '$service_name'..."
  run_compose up -d "$service_name"
}

run_in_container() {
  local script="$1"
  shift

  print_command docker compose "${compose_args[@]}" exec -T "$service_name" bash -lc "$script" bash "$@"
  docker compose "${compose_args[@]}" exec -T "$service_name" bash -lc "$script" bash "$@"
}
