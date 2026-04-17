# Devcontainer Workflow

`goat_racer` uses a project-owned Isaac ROS development container so the repo
controls Docker, Compose, entrypoint behavior, and the mounted workspace
layout.

## Why This Layout Exists

- `ros_ws` stays the single workspace root.
- GOAT packages and Isaac ROS packages live in the same container and
  filesystem view.
- VS Code and terminal users enter the same `goat-dev` service.
- NVIDIA `run_dev.sh` is no longer the primary entry mechanism for this repo.

## Main Entry Points

- VS Code: open the repository and choose "Reopen in Container".
- Terminal: run `./scripts/dev/enter.sh`.

Both paths enter the same Compose service defined in
[docker/compose.dev.yaml](/home/goat/goat/goat_racer/docker/compose.dev.yaml).

## Typical Flow

1. Sync nested repositories with `./scripts/dev/sync_repos.sh`.
2. Open the devcontainer or attach with `./scripts/dev/enter.sh`.
3. Install dependencies with `./scripts/dev/rosdep_install.sh`.
4. Build the workspace with `./scripts/dev/build_ws.sh`.

The helper scripts default to
[docker/env/jetson.env](/home/goat/goat/goat_racer/docker/env/jetson.env).
Use `GOAT_ENV_FILE=docker/env/amd64.env` when you want to try the placeholder
amd64 lane.

## Workspace Layout

- `ros_ws/src/goat_ros` for project ROS packages
- `ros_ws/src/isaac_ros` for Isaac ROS source repositories
- `external/` for non-ROS dependencies
- `ros_ws/bags` for host-mounted bag output
