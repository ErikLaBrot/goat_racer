# goat_racer

`goat_racer` is the workspace-orchestration repository for the GOAT racer
stack. It owns the Docker-based ROS development flow, workspace-level docs and
notes, and the canonical checkout layout for the nested code repositories.

## Purpose

Use this repo to:

- bootstrap the expected local checkout layout
- run the shared ROS container workflow
- build and test the nested GOAT packages together
- document how the workspace is assembled

This repo does not own the full implementation of every package in the
workspace. The ROS packages and the VESC transport library live in nested git
repositories under the paths described below.

## Workspace Layout

- `docker/`
  Container and compose files for the ROS development environment.
- `docs/`
  Shared documentation templates and workspace-level references.
- `external/`
  Nested external dependencies that are consumed by the ROS workspace.
- `notes/`
  Local notes and planning material for the workspace.
- `ros_ws/`
  Workspace root used for nested ROS repositories plus generated build,
  install, and log artifacts.
- `scripts/`
  Operator-facing helpers for common workspace tasks.
- `goat_racer.repos`
  Canonical manifest for populating the expected checkout structure.

## Repository Ownership

The current intended checkout layout is:

- `external/goat_vesc`
  Nested `goat_vesc` repository. Owns the reusable VESC transport library,
  examples, tests, and generated API docs.
- `ros_ws/src/goat_ros`
  Nested `goat_ros` repository. Owns the ROS-facing packages, including
  `goat_vesc_ros` and `goat_teleop`.

Generated ROS workspace artifacts remain under `ros_ws/build`, `ros_ws/install`,
and `ros_ws/log`, but those outputs are not the source of truth for the code.

## Prerequisites

Before running the workspace:

- Install Docker with `docker compose` support on the host.
- Ensure the target VESC serial device is reachable from the host and visible
  under `/dev`.
- Ensure the joystick device is reachable from the host, typically
  `/dev/input/js0`.
- Use a host account that can run Docker commands.

The shared container already includes `vcstool`, `rosdep`, and the ROS build
tooling needed for the bootstrap path. The host does not need a native ROS
installation.

## Fresh Clone To Demo

From a fresh `goat_racer` checkout:

```bash
git clone https://github.com/ErikLaBrot/goat_racer.git
cd goat_racer
scripts/ros bootstrap
```

`scripts/ros bootstrap` starts the shared ROS container, imports the nested
repositories defined in `goat_racer.repos`, installs non-source ROS
dependencies with `rosdep`, and builds the workspace under `ros_ws/`.

Before running the demo, update
`ros_ws/src/goat_ros/goat_ros_drivers/goat_vesc_ros/config/goat_vesc.yaml` so
`device_path` points at the correct VESC serial device.

Start the end-to-end controller demo with:

```bash
scripts/demo
```

Launch overrides are forwarded directly to the combined ROS launch entrypoint:

```bash
scripts/demo joy_dev:=/dev/input/js1 deadzone:=0.02
```

## Demo Success Criteria

The controller demo is considered up when:

- `goat_vesc_ros`, `joy_node`, and `goat_joy` start without launch errors
- `goat_joy` publishes `goat_vesc_ros/msg/VescControlCommand` on `cmd/vesc`
- the configured VESC device connects and telemetry topics begin publishing
- holding the enable button on the joystick causes non-zero commands to reach
  `cmd/vesc`

If the launch starts but hardware is disconnected, ROS process startup is still
useful for bringup validation, but the demo is not functionally complete.

## Build And Test Helpers

From the `goat_racer` repo root:

```bash
scripts/ros build --packages-select goat_vesc goat_vesc_ros goat_teleop
scripts/ros test --packages-select goat_vesc goat_vesc_ros goat_teleop
scripts/ros down
```

The helper script runs `colcon` inside the shared ROS container and targets the
nested repositories through explicit `--base-paths`. Workspace build artifacts
are written under `goat_racer/ros_ws/`.

## `.repos` Manifest

`goat_racer.repos` defines the expected checkout paths so the nested repositories
land in the locations assumed by the Docker workflow and `scripts/ros`.
