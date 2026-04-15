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

## Workflow

From the `goat_racer` repo root:

```bash
scripts/ros up
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
