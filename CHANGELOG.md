# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

## [1.1.0] - 2026-02-28

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

## [1.0.0] - 2026-02-28

### Added

- Initial release of `sysinfo2md`
- Collects OS, CPU, GPU, RAM, storage, network, desktop environment, shell, and package information
- Writes output to a Markdown file (default: `~/sysinfo.md`)
- `-o` / `--output` flag to specify a custom output path
- `-c` / `--clipboard` flag to write to file and copy to clipboard
- `-C` / `--clipboard-only` flag to copy to clipboard without writing a file
- Clipboard auto-detection: `wl-copy` (Wayland), `xclip`, `xsel` (X11)
- `install.sh` to install the command to `~/.local/bin`
