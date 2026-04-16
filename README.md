# goat_racer

## Description

`goat_racer` is the top-level orchestration repository for the GOAT racer
workspace. It owns the shared Docker-based ROS workflow, the nested checkout
bootstrap, and the top-level helper scripts used to build, test, and run the
canonical robot bringup demo.

Detailed package and implementation docs live in the nested repositories, not
in this README.

## Requirements

- Docker with `docker compose`
- Permission to run Docker commands on the host

The shared container provides ROS tooling, `vcstool`, and `rosdep`, so a host
ROS install is not required.

## Install

Clone the repo and bootstrap the workspace:

```bash
git clone https://github.com/ErikLaBrot/goat_racer.git
cd goat_racer
./scripts/ros bootstrap
```

`scripts/ros bootstrap` imports the nested repositories defined in
`goat_racer.repos`, installs ROS dependencies, and builds the workspace.

Before running the demo, update
`ros_ws/src/goat_ros/goat_ros_drivers/goat_vesc_ros/config/goat_vesc.yaml` so
`device_path` points at the correct VESC interface.

## Demo

Run the canonical robot bringup demo with:

```bash
./scripts/demo
```

Launch overrides are forwarded to `goat_ros_launch robot.launch.py`:

```bash
./scripts/demo joy_dev:=/dev/input/js1 deadzone:=0.02
```

Record an MCAP rosbag using one of the installed topic profiles:

```bash
./scripts/demo record:=true record_profile:=slam
```

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
