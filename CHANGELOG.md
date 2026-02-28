# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

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
