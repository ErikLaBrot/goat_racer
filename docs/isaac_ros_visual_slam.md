# Isaac ROS Visual SLAM on GOAT

## Purpose

This is the supported GOAT bringup guide for Isaac ROS Visual SLAM on a fresh
Jetson. The goal is to keep the normal workflow on upstream Isaac ROS container
tooling, install Isaac ROS runtime packages as prebuilt debs, and finish with
the GOAT D435 stereo-only VSLAM demo.

## Requirements

- Jetson Orin Nano on JetPack 6.2 or another Isaac ROS 3.2-capable host
- Docker access on the host
- `git-lfs`
- `vcs`
- D435 connected before launching the container

## Fresh-Jetson Happy Path

From the repo root:

```bash
./scripts/dev/bootstrap.sh
./scripts/dev/build.sh
./scripts/ops/run_vslam_demo.sh
```

`./scripts/dev/bootstrap.sh` is the host-only setup step. It syncs
manifest-managed repositories on the host, copies the repo-root Isaac config
from `.isaac_ros_common-config` into
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config`, syncs the
repo-root upstream Docker args from `.isaac_ros_dev-dockerargs` into
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_dev-dockerargs`, launches the
Isaac container through upstream
`ros_ws/src/isaac_ros_common/scripts/run_dev.sh -d <repo-root>`, installs
dependency packages, and prepares the workspace. The synced Isaac config also
selects a repo-owned GOAT image layer so `isaac_ros_visual_slam`, `rviz2`,
`xeyes`, and `glxinfo` are available in every upstream `run_dev.sh` container
rather than only in transient bootstrap state. `./scripts/dev/build.sh` then
rebuilds the GOAT package set inside that environment. If you run it from
inside the container, it builds directly without re-triggering host container
startup logic.

## Default Demo Behavior

- `./scripts/ops/run_vslam_demo.sh` is the normal deployment and demo entrypoint.
- It is container-aware, so running it from inside the Isaac container skips
  the upstream container startup path, and running it from the host uses the
  same upstream `run_dev.sh` entrypoint as `build.sh`.
- It launches `goat_ros_launch/sensors.launch.py`, which defaults to the GOAT
  D435 Visual SLAM wrapper from `goat_ros_launch/config/sensors.yaml`.
- The default GOAT D435 profile is stereo-only:
  - infrared stereo enabled
  - color disabled
  - depth disabled
  - IMU fusion disabled unless you pass `enable_imu_fusion:=true`
- `./scripts/dev/build.sh` builds `goat_vesc` first, then `goat_vesc_ros`,
  `goat_teleop`, and `goat_ros_launch`.
- Isaac ROS runtime packages such as `isaac_ros_visual_slam` are expected to
  come from the upstream-built container image layer rather than a source build
  in this repo.

CLI overrides still work when needed:

```bash
./scripts/ops/run_vslam_demo.sh sensor_launch_arguments:="enable_imu_fusion:=true"
```

## Manual RViz Check

For the first-pass desktop debugging workflow, start from a local Jetson
desktop terminal with `DISPLAY` already set.

From the repo root on the host:

```bash
ros_ws/src/isaac_ros_common/scripts/run_dev.sh -d "$PWD"
```

Inside the first container shell:

```bash
./scripts/ops/run_vslam_demo.sh
```

From a second local desktop terminal on the host, attach again:

```bash
ros_ws/src/isaac_ros_common/scripts/run_dev.sh -d "$PWD"
```

Inside the second container shell, do a quick GUI preflight and then start
RViz manually:

```bash
xeyes
glxinfo -B
rviz2
```

This first pass intentionally uses plain `rviz2` without a GOAT-owned config so
we can confirm basic container GUI function before tuning displays.

## Optional Debug Check
If you want to confirm the preinstalled Isaac packages directly inside the
container, run:

```bash
source /opt/ros/humble/setup.bash
source /workspaces/isaac_ros-dev/ros_ws/install/setup.bash
ros2 launch isaac_ros_visual_slam isaac_ros_visual_slam_realsense.launch.py
```

Treat this as an Isaac-side debug check rather than the normal GOAT deployment
path.

## What To Check

- The D435 appears inside the Isaac ROS container.
- `/visual_slam/tracking/odometry` publishes once the camera is moving.
- The GOAT wrapper starts with no extra launch arguments.
- `ros2 pkg prefix isaac_ros_visual_slam` resolves from the installed runtime
  packages in the image rather than a source checkout.

Quick spot checks:

```bash
ros2 topic list | grep visual_slam
ros2 topic echo /visual_slam/tracking/odometry --once
ros2 pkg prefix isaac_ros_visual_slam
which rviz2
which xeyes
which glxinfo
```

## Limits

- The supported operator-facing workflow is intentionally limited to
  `bootstrap.sh`, `build.sh`, and `run_vslam_demo.sh`.
- The GOAT D435 wrapper keeps zeroed default static transforms for bench
  testing; replace them with measured transforms before robot evaluation.
