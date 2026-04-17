# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT robot
workspace. It keeps GOAT-owned ROS packages separate from the vendored Isaac
ROS source tree and provides a small set of helper scripts that call Isaac
ROS tooling directly.

## Requirements

- Docker with NVIDIA runtime support on the target host
- `git-lfs`
- `vcs`
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

6. Launch Visual SLAM:

   Upstream Isaac ROS RealSense example:

   ```bash
   ros2 launch isaac_ros_visual_slam isaac_ros_visual_slam_realsense.launch.py
   ```

   GOAT sensor wrapper path:

   ```bash
   ./scripts/ops/run_vslam.sh
   ```

`./scripts/dev/enter.sh` is the primary way to enter the dev environment. It
sources the repo-owned [.isaac_ros_common-config](/home/goat/goat/goat_racer/.isaac_ros_common-config)
and then execs upstream `isaac_ros_common/scripts/run_dev.sh -d <repo-root>`.
Compose and devcontainer assets may remain in the repo for later work, but they
are not the Stage 2A primary workflow.

## Layout

- `ros_ws/` is the main ROS workspace root.
- `ros_ws/src/goat_ros` is reserved for GOAT ROS packages.
- `ros_ws/src/isaac_ros` is reserved for Isaac ROS source checkouts.
- `external/` is reserved for non-ROS project dependencies.
- `docker/` and `.devcontainer/` contain secondary Stage 1 assets that are not
  the primary Stage 2A workflow.

## Additional Docs

- [Devcontainer workflow](/home/goat/goat/goat_racer/docs/devcontainer_workflow.md)
- [Version matrix](/home/goat/goat/goat_racer/docs/version_matrix.md)
- [Isaac ROS Visual SLAM notes](/home/goat/goat/goat_racer/docs/isaac_ros_visual_slam.md)
