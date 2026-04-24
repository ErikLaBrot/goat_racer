# Devcontainer Workflow

This document is secondary to the Stage 2A Isaac ROS workflow.

The supported Stage 2A path is:

1. `./scripts/dev/bootstrap.sh`
2. `./scripts/dev/build.sh`
3. `./scripts/ops/run_vslam_demo.sh`

Those repo helpers call Isaac ROS tooling directly. They do not rely on Docker
Compose as the primary container workflow.

`./scripts/dev/bootstrap.sh` and `./scripts/dev/build.sh` invoke the vendored
upstream `ros_ws/src/isaac_ros_common/scripts/run_dev.sh` directly.
`./scripts/dev/bootstrap.sh` also ensures the standard Isaac ROS config file
exists at `ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config` with
`CONFIG_IMAGE_KEY=ros2_humble.realsense`.

## Current Status

- `.devcontainer/` and `docker/compose.dev.yaml` are leftover Stage 1 assets.
- They may still be useful for experiments or future editor integration work.
- They are not the source of truth for container launch, image selection, or
  day-to-day bringup in Stage 2A.

## If You Still Use It

If you open the repo in VS Code and choose "Reopen in Container", treat that as
a secondary workflow. The supported command-line flow still uses
the three repo-owned scripts above, which delegate to Isaac ROS `run_dev.sh`.

## Workspace Layout

- `ros_ws/src/isaac_ros_common` for the upstream Isaac ROS tooling checkout
- `ros_ws/src/goat_ros` for project ROS packages
- `external/` for non-ROS dependencies
