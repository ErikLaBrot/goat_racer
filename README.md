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

`scripts/ros bootstrap` imports every root-level `.repos` manifest, installs
ROS dependencies across the workspace roots, and builds the workspace.

The GOAT sources live in `goat_racer.repos`. NVIDIA Isaac ROS sources live in
`isaac_ros.repos` and are checked out under `ros_ws/src/isaac_ros`.
The manifest currently includes `isaac_ros_common`, `isaac_ros_visual_slam`,
and `isaac_ros_nvblox`, all on the `release-3.2` branch so the workspace stays
on the JetPack 6.2 and ROS 2 Humble support line.

`isaac_ros_visual_slam` and `isaac_ros_nvblox` also depend on additional Isaac
ROS source packages such as the GXF and NITROS stacks, so this manifest is the
initial repository set rather than the complete transitive Isaac ROS source
closure.

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
docker compose -f docker/compose.yaml run --rm ros-humble bash -lc \
  'source /opt/ros/humble/setup.bash && \
   source /workspace/goat_racer/ros_ws/install/setup.bash && \
   ros2 launch goat_ros_launch replay.launch.py \
     bag_path:=/workspace/goat_racer/ros_ws/bags/<bag_name>'
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
- The nested checkout manifests live in [goat_racer.repos](/home/erik/goat/goat_racer/goat_racer.repos) and [isaac_ros.repos](/home/erik/goat/goat_racer/isaac_ros.repos).
