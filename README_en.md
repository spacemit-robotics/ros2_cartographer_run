# Cartographer Run

## Introduction

A ROS2 SLAM launch package based on Google Cartographer, providing launch files and configurations for LiDAR mapping and localization. Used for real-time occupancy grid map construction in unknown environments.

## Features

**Supported:**
- 2D LiDAR SLAM mapping
- Real-time occupancy grid map publishing
- Configurable map resolution and publish period
- Simulation time mode support


## Quick Start

### Prerequisites

- ROS2 Humble
- cartographer_ros package
- 2D LiDAR (publishing `/scan` topic)
- Odometry data (publishing `/odom` topic)
- TF transform: `odom` -> `base_footprint`

### Build

```bash
# In workspace root directory
colcon build --packages-select cartographer_run
source install/setup.bash
```

### Run Example

```bash
ros2 launch cartographer_run cartographer_2d.launch.py
```

**Launch Parameters:**
| Parameter | Default | Description |
|-----------|---------|-------------|
| `use_sim_time` | false | Whether to use simulation time |
| `resolution` | 0.05 | Map resolution (m/cell) |
| `publish_period_sec` | 1.0 | Map publish period (seconds) |
| `configuration_directory` | config/ | Configuration file directory |
| `configuration_basename` | lds_2d.lua | Configuration file name |

**Subscribed Topics:**
| Topic | Type | Description |
|-------|------|-------------|
| `/scan` | sensor_msgs/LaserScan | 2D laser scan data |
| `/odom` | nav_msgs/Odometry | Odometry data |

**Published Topics:**
| Topic | Type | Description |
|-------|------|-------------|
| `/map` | nav_msgs/OccupancyGrid | Occupancy grid map |
| `/submap_list` | cartographer_ros_msgs/SubmapList | Submap list |

## Detailed Usage

See [Cartographer ROS Official Documentation](https://google-cartographer-ros.readthedocs.io/)

## FAQ

**Q: Severe map drift?**
A: Check odometry accuracy, ensure TF transforms are correct, adjust parameters in `lds_2d.lua`.

**Q: Slow map updates?**
A: Decrease the `publish_period_sec` parameter value.

**Q: Cannot start node?**
A: Confirm that the `cartographer_ros` package is properly installed.

## Version & Release

| Version | Date | Description |
|---------|------|-------------|
| 0.0.1 | 2026-02 | Initial version, 2D SLAM support |

## Contributing

Issues and Pull Requests are welcome.

## License

Source files in this component are declared as Apache-2.0. The `LICENSE` file in this directory shall prevail.
