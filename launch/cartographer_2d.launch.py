# Copyright 2026 SpacemiT (Hangzhou) Technology Co. Ltd.
#
# SPDX-License-Identifier: Apache-2.0


import os
from ament_index_python.packages import get_package_share_directory
from launch import LaunchDescription
from launch.substitutions import LaunchConfiguration
from launch_ros.actions import Node


def generate_launch_description():
    # Node Parameter Configuration
    # Path to the navigation package
    pkg_share_dir = get_package_share_directory('cartographer_run')
    # Whether to use simulation time, set to true when using Gazebo
    use_sim_time = LaunchConfiguration('use_sim_time', default='false')
    # Map resolution
    resolution = LaunchConfiguration('resolution', default='0.05')
    # Period for publishing map data
    publish_period_sec = LaunchConfiguration('publish_period_sec', default='1.0')
    # Path to configuration directory in the package
    configuration_directory = LaunchConfiguration(
        'configuration_directory', default=os.path.join(pkg_share_dir, 'config'))
    # Configuration file name
    configuration_basename = LaunchConfiguration('configuration_basename', default='lds_2d.lua')

    # Launch nodes: cartographer_node, cartographer_occupancy_grid_node
    cartographer_node = Node(
        package='cartographer_ros',
        executable='cartographer_node',
        name='cartographer_node',
        output='screen',
        parameters=[{'use_sim_time': use_sim_time}],
        arguments=['-configuration_directory', configuration_directory,
                   '-configuration_basename', configuration_basename])

    cartographer_occupancy_grid_node = Node(
        package='cartographer_ros',
        executable='cartographer_occupancy_grid_node',
        name='cartographer_occupancy_grid_node',
        output='screen',
        parameters=[{'use_sim_time': use_sim_time}],
        arguments=['-resolution', resolution, '-publish_period_sec', publish_period_sec])


    ld = LaunchDescription()
    ld.add_action(cartographer_node)
    ld.add_action(cartographer_occupancy_grid_node)

    return ld
