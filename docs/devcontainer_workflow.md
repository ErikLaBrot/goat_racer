# Devcontainer Workflow

This document is secondary to the Stage 2A Isaac ROS workflow.

The supported Stage 2A path is:

1. `./scripts/dev/sync_repos.sh`
2. `./scripts/dev/enter.sh`
3. `./scripts/dev/rosdep_install.sh`
4. `./scripts/dev/build_ws.sh`

Those repo helpers call Isaac ROS tooling directly. They do not rely on Docker
Compose as the primary container workflow.

## Current Status

- `.devcontainer/` and `docker/compose.dev.yaml` are leftover Stage 1 assets.
- They may still be useful for experiments or future editor integration work.
- They are not the source of truth for container launch, image selection, or
  day-to-day bringup in Stage 2A.

## If You Still Use It

If you open the repo in VS Code and choose "Reopen in Container", treat that as
a secondary workflow. The supported command-line flow still uses
`./scripts/dev/enter.sh`, which delegates to Isaac ROS `run_dev.sh`.

## Workspace Layout

- `ros_ws/src/goat_ros` for project ROS packages
- `ros_ws/src/isaac_ros` for Isaac ROS source repositories
- `external/` for non-ROS dependencies
- `ros_ws/bags` for rosbag output when you choose to record manually
