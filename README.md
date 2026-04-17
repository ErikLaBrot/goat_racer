# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT robot
workspace. It owns the project-native Isaac ROS development container, the
workspace layout under `ros_ws`, and the small helper scripts used to sync,
prepare, and build the source tree.

This repository intentionally does not use NVIDIA `run_dev.sh` as its primary
entrypoint. Instead, the project uses one Compose-backed dev container service
named `goat-dev` so GOAT packages and Isaac ROS packages live in the same
workspace and container.

## Requirements

- Docker with the `docker compose` plugin
- Permission to run Docker commands on the host

## Developer Workflow

1. Clone the repository.
2. Sync nested repositories:

   ```bash
   ./scripts/dev/sync_repos.sh
   ```

3. Open the repo in the VS Code devcontainer or attach from a terminal:

   ```bash
   ./scripts/dev/enter.sh
   ```

4. Install workspace dependencies:

   ```bash
   ./scripts/dev/rosdep_install.sh
   ```

5. Build the workspace:

   ```bash
   ./scripts/dev/build_ws.sh
   ```

The helper scripts default to the Jetson-oriented environment file at
`docker/env/jetson.env`. To try the placeholder amd64 lane instead, override
`GOAT_ENV_FILE`:

```bash
GOAT_ENV_FILE=docker/env/amd64.env ./scripts/dev/enter.sh
```

## Layout

- `ros_ws/` is the main ROS workspace root.
- `ros_ws/src/goat_ros` is reserved for GOAT ROS packages.
- `ros_ws/src/isaac_ros` is reserved for Isaac ROS source checkouts.
- `external/` is reserved for non-ROS project dependencies.
- `docker/` contains the project Dockerfile, Compose file, entrypoint, and
  environment presets.

## Additional Docs

- [Devcontainer workflow](/home/goat/goat/goat_racer/docs/devcontainer_workflow.md)
- [Version matrix](/home/goat/goat/goat_racer/docs/version_matrix.md)
- [Isaac ROS Visual SLAM notes](/home/goat/goat/goat_racer/docs/isaac_ros_visual_slam.md)
