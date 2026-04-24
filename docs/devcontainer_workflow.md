# Devcontainer Workflow

This document is secondary to the Stage 2A Isaac ROS workflow.

The supported Stage 2A path is:

1. `./scripts/dev/bootstrap.sh`
2. `./scripts/dev/build.sh`
3. `./scripts/ops/run_vslam_demo.sh`

Those repo helpers use repo-owned container orchestration plus vendored Isaac
image build tooling. They do not rely on Docker Compose as the primary
container workflow.

`./scripts/dev/bootstrap.sh` is the host-only entrypoint. It syncs repos on the
host, then copies the repo-root Isaac config file
`.isaac_ros_common-config` into
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config`.

`./scripts/dev/build.sh` and `./scripts/ops/run_vslam_demo.sh` are
container-aware. From the host they use repo-owned container orchestration to
start or reuse the Isaac container; from inside the container they run
repo-owned internal helper scripts directly instead of re-running host Docker
setup logic.

## Current Status

- `.devcontainer/` and `docker/compose.dev.yaml` are leftover Stage 1 assets.
- They may still be useful for experiments or future editor integration work.
- They are not the source of truth for container launch, image selection, or
  day-to-day bringup in Stage 2A.

## If You Still Use It

If you open the repo in VS Code and choose "Reopen in Container", treat that as
a secondary workflow. The supported command-line flow still uses
the three repo-owned scripts above.

## Workspace Layout

- `ros_ws/src/isaac_ros_common` for the upstream Isaac ROS tooling checkout
- `ros_ws/src/goat_ros` for project ROS packages
- `external/` for non-ROS dependencies
