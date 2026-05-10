# sys-uptime

## Description

A Crystal interface for getting system uptime information.

## Supported Platforms

- Linux
- macOS
- BSD systems via `sysctl(KERN_BOOTTIME)` where available

At the moment there is no Windows support.

## Installation

Add this to your application's `shard.yml`:

```yaml
dependencies:
  sys-uptime:
    github: djberg96/crystal-sys-uptime
```

Then run:

```sh
shards install
```

## Synopsis

```crystal
require "sys-uptime"

# Get everything
pp System::Uptime.uptime

# Get individual units
pp System::Uptime.days
pp System::Uptime.hours
pp System::Uptime.minutes
pp System::Uptime.seconds

# Get the boot time
pp System::Uptime.boot_time
```

## API

- `System::Uptime.seconds` returns total uptime in seconds as `Int64`
- `System::Uptime.minutes` returns total uptime in minutes as `Int64`
- `System::Uptime.hours` returns total uptime in hours as `Int64`
- `System::Uptime.days` returns total uptime in days as `Int64`
- `System::Uptime.uptime` returns a `days:hours:minutes:seconds` string
- `System::Uptime.boot_time` returns the system boot time as a `Time`

## Notes

This shard is modeled after the Ruby `sys-uptime` library, but the Crystal
API is intentionally smaller right now.

The current time, user count, and load average are not included, even though
you may be used to seeing them in the command line `uptime` tool.

On Linux, uptime is read from `/proc/uptime`.

On macOS and BSD systems, uptime is derived from the kernel boot time. In
restricted environments where `sysctl(KERN_BOOTTIME)` is blocked, the shard
attempts a `who -b` fallback.

## Known Bugs

None that I am aware of. Please log any bugs you find on the project website.

## License

MIT

## Copyright

Copyright 2026, Daniel J. Berger

## Warranty

This library is provided "as is" and without any express or implied
warranties, including, without limitation, the implied warranties of
merchantability and fitness for a particular purpose.

## Author

Daniel J. Berger
