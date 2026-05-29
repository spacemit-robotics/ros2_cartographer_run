# Cartographer Run

## Introduction

A ROS2 SLAM launch package based on Google Cartographer, providing launch files and configurations for LiDAR mapping and localization. Used for real-time occupancy grid map construction in unknown environments.

## Features

**Supported:**
- 2D LiDAR SLAM mapping
- Real-time occupancy grid map publishing
- Configurable map resolution and publish period
- Simulation time mode support
- Optional IMU data fusion


## Quick Start

### Prerequisites

- ROS2 Humble
- cartographer_ros package
- nav2_map_server package (for saving occupancy grid maps with `map_saver_cli`)
- 2D LiDAR (publishing `/scan` topic)
- IMU (optional, required when launching with `use_imu:=true`; publish the `/imu` topic and provide TF from `imu_link` to the robot base frame)

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

To enable IMU data fusion:

```bash
ros2 launch cartographer_run cartographer_2d.launch.py use_imu:=true
```

To specify a custom configuration file or adjust occupancy grid publishing parameters:

```bash
ros2 launch cartographer_run cartographer_2d.launch.py \
  use_imu:=true \
  imu_configuration_basename:=lds_2d_imu.lua \
  resolution:=0.05 \
  publish_period_sec:=1.0
```

### Save Map

After mapping is complete, finish the current trajectory first, then save the Cartographer state file (`.pbstream`):

```bash
ros2 service call /finish_trajectory cartographer_ros_msgs/srv/FinishTrajectory "{trajectory_id: 0}"
ros2 service call /write_state cartographer_ros_msgs/srv/WriteState "{filename: '${HOME}/map.pbstream', include_unfinished_submaps: true}"
```

To save a 2D occupancy grid map (`.pgm` + `.yaml`) for the navigation stack, run the following after `/map` is published properly:

```bash
ros2 run nav2_map_server map_saver_cli -f ${HOME}/map
```

### Localization Run Example

`cartographer_2d_localization_launch.py` loads a saved `.pbstream` map and runs Cartographer in pure localization mode. The `load_state_filename` parameter must be specified when launching:

```bash
ros2 launch cartographer_run cartographer_2d_localization_launch.py load_state_filename:=${HOME}/map.pbstream
```

To specify a custom configuration file or adjust occupancy grid publishing parameters:

```bash
ros2 launch cartographer_run cartographer_2d_localization_launch.py \
  load_state_filename:=${HOME}/map.pbstream \
  configuration_basename:=lds_2d_localization.lua \
  resolution:=0.05 \
  publish_period_sec:=1.0
```

**Launch Parameters:**

| Parameter | Default | Description |
|-----------|---------|-------------|
| `use_sim_time` | false | Whether to use simulation time |
| `resolution` | 0.05 | Map resolution (m/cell) |
| `publish_period_sec` | 1.0 | Map publish period (seconds) |
| `configuration_directory` | config/ | Configuration file directory |
| `configuration_basename` | lds_2d.lua / lds_2d_localization.lua | Configuration file name; mapping uses `lds_2d.lua` by default, and pure localization uses `lds_2d_localization.lua` by default |
| `use_imu` | false | Whether to enable IMU data fusion in mapping mode; supported only by `cartographer_2d.launch.py` |
| `imu_configuration_basename` | lds_2d_imu.lua | Mapping configuration file used when `use_imu:=true` |
| `load_state_filename` | None | Path to the `.pbstream` map file loaded in pure localization mode; required when using `cartographer_2d_localization_launch.py` |

**Subscribed Topics:**

| Topic | Type | Description |
|-------|------|-------------|
| `/scan` | sensor_msgs/LaserScan | 2D laser scan data |
| `/imu` | sensor_msgs/Imu | IMU data, required only when `use_imu:=true` |

**Published Topics:**

| Topic | Type | Description |
|-------|------|-------------|
| `/map` | nav_msgs/OccupancyGrid | Occupancy grid map |
| `/submap_list` | cartographer_ros_msgs/SubmapList | Submap list |

## Detailed Usage

See [Cartographer ROS Official Documentation](https://google-cartographer-ros.readthedocs.io/)

## FAQ

**Q: Severe map drift?**
A: Ensure TF transforms are correct, adjust parameters in `lds_2d.lua`.

**Q: Mapping does not work after enabling IMU?**
A: Ensure the `/imu` topic is published and TF from `imu_link` to `base_footprint` exists. If your actual IMU frame is different, update `tracking_frame` in `lds_2d_imu.lua` accordingly.

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
