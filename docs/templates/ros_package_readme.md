# ROS Package README Template

Use this exact section order for ROS package READMEs.

```md
# <package_name>

## Purpose
Short description of what the package provides and where it fits in the system.

## Nodes
### `<node_name>`
- Purpose: What the node does.
- Executable: Launch or run target if relevant.
- Notes: Lifecycle, assumptions, or behavior that matters to operators.

## Topics
### Subscribed Topics
- `/example/input` (`example_msgs/msg/Input`): What the node consumes and why.

### Published Topics
- `/example/output` (`example_msgs/msg/Output`): What the node publishes and why.

## Parameters
- `example_parameter` (`double`, default: `1.0`): Meaning, units, and effect.
- `device_path` (`string`): Stable path or interface expected by the node.

## Launch Entry Points
- `example.launch.py`: When to use it and major launch arguments.

## Dependencies
- ROS packages
- External libraries
- Hardware or runtime assumptions when relevant

## Example Usage
```bash
ros2 launch <package_name> example.launch.py
ros2 run <package_name> <node_name>
```

## Rules
- Keep the README operator-facing.
- Topic names, parameter names, launch files, and examples must match the code.
- Document user-facing scripts or launch files here or in clearly linked package docs.
- Prefer concise bullets over long narrative prose.
