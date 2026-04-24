# goat_racer

`goat_racer` is the top-level orchestration repository for the GOAT robot
workspace. It keeps GOAT-owned ROS packages separate from the vendored
`isaac_ros_common` checkout and uses prebuilt Isaac ROS packages inside the
development container to simplify setup.

## Requirements

- Docker with NVIDIA runtime support on the target host
- `git-lfs`
- `vcs`
- Permission to run Docker commands on the host

## Deployment Workflow

1. Clone the repository.
2. Sync nested repositories:

   ```bash
   ./scripts/dev/sync_repos.sh
   ```

3. Enter the Isaac ROS development container:

   ```bash
   ./scripts/dev/enter.sh
   ```

4. Install package dependencies:

   ```bash
   ./scripts/dev/rosdep_install.sh
   ```

5. Build the GOAT workspace packages:

   ```bash
   ./scripts/dev/build_ws.sh
   ```

6. Launch the default GOAT D435 Visual SLAM demo:

   ```bash
   ./scripts/ops/run_vslam.sh
   ```

`./scripts/dev/enter.sh` is the primary way to enter the dev environment. It
execs upstream `ros_ws/src/isaac_ros_common/scripts/run_dev.sh -d <repo-root>`.
`./scripts/dev/sync_repos.sh` ensures the standard Isaac ROS config file exists
at `ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config` with the
upstream `ros2_humble.realsense` image key.

`./scripts/dev/build_ws.sh` builds GOAT-owned packages only from
`ros_ws/src/goat_ros` and `external/goat_vesc`. `./scripts/dev/rosdep_install.sh`
installs missing host dependencies and pulls Isaac ROS runtime packages such as
`isaac_ros_visual_slam` as prebuilt Debian packages instead of relying on a
source checkout.

## Layout

- `ros_ws/` is the main ROS workspace root.
- `ros_ws/src/goat_ros` is reserved for GOAT ROS packages.
- `ros_ws/src/isaac_ros_common` is the vendored upstream Isaac ROS tooling
  checkout used by `run_dev.sh`.
- `external/` is reserved for non-ROS project dependencies.
- `.devcontainer/` remains a secondary workflow and is not the source of truth
  for the supported Jetson deployment path.

## Additional Docs

- [Devcontainer workflow](/home/goat/goat/goat_racer/docs/devcontainer_workflow.md)
- [Version matrix](/home/goat/goat/goat_racer/docs/version_matrix.md)
- [Isaac ROS Visual SLAM notes](/home/goat/goat/goat_racer/docs/isaac_ros_visual_slam.md)
