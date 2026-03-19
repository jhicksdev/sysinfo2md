# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [2026.03.19] - 2026-03-19

### Added

- Modular section registry: sections registered and iterated dynamically via `register_section()`
- `--only SECTIONS` (`-n`): include only specified sections (e.g. `--only os,cpu,gpu`)
- `--exclude SECTIONS` (`-e`): exclude specified sections (e.g. `--exclude battery,packages`)
- `--quiet` (`-q`): suppress status messages
- `--verbose` (`-v`): show last installed packages per package manager
- `--list-sections` (`-l`): list all available sections and exit
- `section_audio`: PipeWire/PulseAudio/ALSA audio device detection
- `section_usb`: USB device summary via `lsusb`
- `section_input`: keyboard and pointing device detection
- `section_virtualization`: VM, container, WSL, and bare-metal detection
- BATS test suite with 28 test cases
- GitHub Actions CI (ShellCheck, BATS, bash syntax check)

### Changed

- `-v` is now `--verbose` (was `--version`); `-V` is now `--version`
- Display manager version check wrapped in `timeout 2` to prevent hangs

### Fixed

- `plasmalogin --version` hang on KDE systems (now wrapped in `timeout 2`)

## [0.6.1] - 2026-02-28

### Fixed

- Renamed OS section `Model` field to `Device` to distinguish it from CPU `Model`

## [0.6.0] - 2026-02-28

### Changed

- `uptime -p` now falls back to parsing `/proc/uptime` directly on systems where the `-p` flag is unavailable (e.g. busybox)
- CPU model detection now falls back to `Hardware` field and `/proc/device-tree/model` for ARM systems
- CPU frequency now falls back to `/sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq` when `/proc/cpuinfo` has no `cpu MHz` field
- `free -h --si` now falls back to `free -h` on systems without `--si` support
- Network section now falls back from `ip -brief` to `ip address` or `ifconfig`
- Display manager detection now guards against non-systemd systems
- Theme/icons/font detection now uses `gsettings` for GNOME and other non-KDE desktops

## [0.5.0] - 2026-02-28

### Changed

- CPU frequency now displays in GHz instead of MHz (e.g. `3.4 GHz`)
- CPU temperature no longer shows a leading `+` sign (e.g. `56.4°C`)
- GPU output strips verbose vendor prefix and PCI class label (e.g. `AMD Krackan [Radeon 840M / 860M Graphics]`)

### Added

- Fan speed to the CPU section (via `sensors`, non-zero RPM only)

## [0.4.0] - 2026-02-28

### Added

- CPU temperature to the CPU section (via `sensors`, fallback to `/sys/class/thermal`)
- Battery section with charge percentage, status, power draw, and estimated time remaining

## [0.3.0] - 2026-02-28

### Added

- `-s` / `--stdout` flag to print output to stdout instead of writing a file

## [0.2.0] - 2026-02-28

### Added

- Device model name (from DMI) to the OS section
- Uptime to the OS section
- Locale to the OS section
- Display manager detection to the Desktop section
- Window manager detection to the Desktop section
- Screen resolution detection to the Desktop section
- KDE theme and icon theme detection (from `kdeglobals`)
- GTK theme and font detection (from `gtk-3.0/settings.ini`)
- `-v` / `--version` flag to print the current version and exit
- `.claude/` to `.gitignore`

## [0.1.0] - 2026-02-28

Initial release of `sysinfo2md` — a simple Linux command that collects system hardware and software information and writes it to a Markdown file.

### Added

- Collects OS, CPU, GPU, RAM, storage, network, desktop environment, shell, and package information
- Writes output to a Markdown file (default: `~/sysinfo.md`)
- `-o` / `--output` flag to specify a custom output path
- `-c` / `--clipboard` flag to write to file and copy to clipboard
- `-C` / `--clipboard-only` flag to copy to clipboard without writing a file
- Clipboard auto-detection: `wl-copy` (Wayland), `xclip`, `xsel` (X11)
- `install.sh` to install the command to `~/.local/bin`
