#!/usr/bin/env bash
# Enter the GOAT development container from a terminal.
#
# Purpose:
#   Start the `goat-dev` service when needed and open an interactive shell or
#   run a command inside it without relying on the VS Code UI.
#
# Inputs:
#   Optional command arguments and an optional `GOAT_ENV_FILE` override.
#
# Outputs:
#   Starts the dev container if needed and attaches the current terminal to it.
#
# Usage:
#   ./scripts/dev/enter.sh
#   ./scripts/dev/enter.sh bash -lc 'colcon list'
#   GOAT_ENV_FILE=docker/env/amd64.env ./scripts/dev/enter.sh
#
# Notes:
#   Defaults to the Jetson-oriented environment file.
set -euo pipefail

source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/common.sh"

ensure_running

if [[ $# -eq 0 ]]; then
  print_command docker compose "${compose_args[@]}" exec "$service_name" bash
  exec docker compose "${compose_args[@]}" exec "$service_name" bash
fi

print_command docker compose "${compose_args[@]}" exec "$service_name" "$@"
exec docker compose "${compose_args[@]}" exec "$service_name" "$@"
