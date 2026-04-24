# Isaac ROS Visual SLAM on GOAT

## Purpose

This is the supported GOAT bringup guide for Isaac ROS Visual SLAM on a fresh
Jetson. The goal is to keep the normal workflow on repo-owned container
orchestration, install Isaac ROS runtime packages as prebuilt debs, and finish
with the GOAT D435 stereo-only VSLAM demo.

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
`ros_ws/src/isaac_ros_common/scripts/.isaac_ros_common-config`, launches the
Isaac container through repo-owned container orchestration, installs dependency
packages, and prepares the workspace. That named container is then reused by
`./scripts/dev/build.sh` and `./scripts/ops/run_vslam_demo.sh` so the installed
runtime packages persist across commands. `./scripts/dev/build.sh` then
rebuilds the GOAT package set inside that container-managed environment. If you
run it from inside the container, it builds directly without re-triggering host
Docker logic.

## Default Demo Behavior

- `./scripts/ops/run_vslam_demo.sh` is the normal deployment and demo entrypoint.
- It is container-aware, so running it from inside the Isaac container skips
  host-side Docker/user/group checks, and running it from the host uses the
  same repo-owned container orchestration as `build.sh`.
- It launches `goat_ros_launch/sensors.launch.py`, which defaults to the GOAT
  D435 Visual SLAM wrapper from `goat_ros_launch/config/sensors.yaml`.
- The default GOAT D435 profile is stereo-only:
  - infrared stereo enabled
  - color disabled
  - depth disabled
  - IMU fusion disabled unless you pass `enable_imu_fusion:=true`
- `./scripts/dev/build.sh` builds `goat_vesc` first, then `goat_vesc_ros`,
  `goat_teleop`, and `goat_ros_launch`.
- Isaac ROS runtime packages such as `isaac_ros_visual_slam` are still expected
  to come from the container image and `rosdep` rather than a source build in
  this repo.

CLI overrides still work when needed:

```bash
./scripts/ops/run_vslam_demo.sh sensor_launch_arguments:="enable_imu_fusion:=true"
```

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
```

## Limits

- The supported operator-facing workflow is intentionally limited to
  `bootstrap.sh`, `build.sh`, and `run_vslam_demo.sh`.
- The GOAT D435 wrapper keeps zeroed default static transforms for bench
  testing; replace them with measured transforms before robot evaluation.
