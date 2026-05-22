# Manifest

This document provides a quick inventory of the project structure and public surface area.

## Project

- Name: `system-uptime`
- Version: `0.2.0`
- Language: Crystal
- License: MIT

## Supported Platforms

- Linux
- macOS
- BSD systems with `sysctl(KERN_BOOTTIME)` support

## Entrypoints

- `src/system-uptime.cr`: canonical require path
- `src/sys-uptime.cr`: compatibility require path

## Public API

- `System::Uptime.seconds`
- `System::Uptime.minutes`
- `System::Uptime.hours`
- `System::Uptime.days`
- `System::Uptime.uptime`
- `System::Uptime.boot_time`

## File Inventory

- `README.md`: usage and installation documentation
- `CHANGES.md`: release history
- `LICENSE`: project license
- `shard.yml`: shard metadata
- `src/system/uptime.cr`: uptime implementation
- `src/system-uptime.cr`: canonical entrypoint
- `src/sys-uptime.cr`: compatibility entrypoint
- `spec/spec_helper.cr`: spec setup
- `spec/system/uptime_spec.cr`: uptime specs
