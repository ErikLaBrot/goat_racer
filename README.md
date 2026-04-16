# goat_racer

## Description

`goat_racer` is the top-level orchestration repository for the GOAT racer
workspace. It owns the shared Docker-based ROS workflow, the nested checkout
bootstrap, and the top-level helper scripts used to build, test, and run the
canonical robot bringup demo across Ubuntu workstation and Jetson deployment
targets.

Detailed package and implementation docs live in the nested repositories, not
in this README.

## Requirements

- Docker with `docker compose`
- Permission to run Docker commands on the host

The shared container provides ROS tooling, `vcstool`, and `rosdep`, so a host
ROS install is not required.

The Docker setup uses a shared base compose file plus one target overlay:

- `docker/compose.yaml`
  Shared service settings used by every host.
- `docker/compose.workstation.yaml`
  Native Ubuntu workstation target (`amd64`).
- `docker/compose.jetson.yaml`
  Native Jetson target (`arm64`).

Helper scripts default to the Jetson target. Use `GOAT_TARGET=workstation`
when running the secondary Ubuntu workstation dev/debug flow.

The Jetson Dockerfile uses an `arm64` ROS Humble base image so the container
builds natively on Jetson hosts.

## Install

Clone the repo and bootstrap the workspace:

```bash
git clone https://github.com/ErikLaBrot/goat_racer.git
cd goat_racer
./scripts/ros bootstrap
```

`scripts/ros bootstrap` imports the nested repositories defined in
`goat_racer.repos`, installs ROS dependencies, and builds the workspace.

On an Ubuntu workstation, select the secondary dev/debug target explicitly:

```bash
GOAT_TARGET=workstation ./scripts/ros bootstrap
```

Before running the demo, update
`ros_ws/src/goat_ros/goat_ros_drivers/goat_vesc_ros/config/goat_vesc.yaml` so
`device_path` points at the correct VESC interface.

## Demo

Run the canonical robot bringup demo with:

```bash
./scripts/demo
```

On an Ubuntu workstation, select the workstation overlay explicitly:

```bash
GOAT_TARGET=workstation ./scripts/demo
```

Launch overrides are forwarded to `goat_ros_launch robot.launch.py`:

```bash
./scripts/demo joy_dev:=/dev/input/js1 deadzone:=0.02
```

Record an MCAP rosbag using one of the installed topic profiles:

```bash
./scripts/demo record:=true record_profile:=slam
```

Demo recordings default to `ros_ws/bags` on the host, which is mounted inside
the ROS container as `/workspace/goat_racer/ros_ws/bags`. Use a launch override
when a single run needs another container-visible directory:

```bash
./scripts/demo record:=true bag_dir:=/workspace/goat_racer/ros_ws/bags/demo
```

Use `GOAT_ROSBAG_DIR` when you want to change the top-level default without
typing `bag_dir` each time. Relative values are resolved from the repo root and
passed into the container through the workspace mount:

```bash
GOAT_ROSBAG_DIR=ros_ws/bags/demo ./scripts/demo record:=true
```

Replay a saved bag from the same mounted location:

```bash
docker compose -f docker/compose.yaml -f docker/compose.jetson.yaml run --rm ros-humble bash -lc \
  'source /opt/ros/humble/setup.bash && \
   source /workspace/goat_racer/ros_ws/install/setup.bash && \
   ros2 launch goat_ros_launch replay.launch.py \
     bag_path:=/workspace/goat_racer/ros_ws/bags/<bag_name>'
```

Swap in `docker/compose.workstation.yaml` or set `GOAT_TARGET=workstation` in
the helper scripts when running on the Ubuntu workstation dev/debug host.

This change only separates workstation and Jetson host targets. It does not yet
add Jetson-specific NVIDIA runtime flags, GUI/display forwarding, or additional
hardware mounts beyond the shared base container configuration.

Full demo behavior depends on the target hardware being connected and reachable
from the host.

## Scripts

- `scripts/ros bootstrap`
  Populate nested repos, install ROS dependencies, and build the workspace.
- `scripts/ros build --packages-up-to goat_ros_launch`
  Build the main GOAT workspace packages inside the shared container.
- `scripts/ros test --packages-select goat_ros_launch`
  Build, test, and print test results for the main GOAT workspace packages.
- `scripts/ros down`
  Stop and remove the shared ROS container.
- `scripts/demo`
  Launch `goat_ros_launch robot.launch.py` from the built workspace.

## Notes

- Detailed ROS package docs live in [ros_ws/src/goat_ros/README.md](/home/erik/goat/goat_racer/ros_ws/src/goat_ros/README.md).
- Detailed `goat_vesc` docs live in [external/goat_vesc/README.md](/home/erik/goat/goat_racer/external/goat_vesc/README.md).
- The nested checkout manifest lives in [goat_racer.repos](/home/erik/goat/goat_racer/goat_racer.repos).
