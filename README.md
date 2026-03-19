# sysinfo2md

A simple Linux command that collects system hardware and software information and writes it to a Markdown file — ideal for quickly sharing your system specs with an AI chatbot or agent.

## Features

- Device model, OS, kernel, hostname, uptime, and locale
- CPU model, core count, frequency, temperature, fan speed, and governor
- GPU detection with cleaned-up vendor names (AMD, NVIDIA, Intel)
- RAM and swap usage
- Storage block devices and filesystem usage
- Network interfaces and IP addresses
- Desktop environment, display manager, window manager, resolution, theme, icons, and font
- Shell, terminal, and installed package counts (pacman, dpkg, rpm, flatpak, snap)
- Battery charge, status, and power draw (laptops only)
- Audio devices (PipeWire/PulseAudio/ALSA)
- USB device summary
- Input devices (keyboard and pointing devices)
- Virtualization detection (bare metal, VM, container, WSL)
- Clean Markdown output ready to paste anywhere
- Optional clipboard copy (Wayland and X11 supported)
- Selective sections — include or exclude specific information
- Lightweight — pure Bash, no dependencies beyond standard Linux tools

## Installation

```bash
git clone https://github.com/jhicksdev/sysinfo2md.git
cd sysinfo2md
bash install.sh
```

This installs the command to `~/.local/bin/sysinfo2md`. Make sure `~/.local/bin` is in your `$PATH`.

### Clipboard support

| Display server | Package to install |
|---|---|
| Wayland | `wl-clipboard` (provides `wl-copy`) |
| X11 | `xclip` or `xsel` |

**Arch Linux:**
```bash
sudo pacman -S wl-clipboard   # Wayland
sudo pacman -S xclip          # X11
```

## Usage

```bash
# Write to ~/sysinfo.md (default)
sysinfo2md

# Print to stdout (useful for piping or AI agents)
sysinfo2md --stdout

# Write to a custom path
sysinfo2md -o ~/documents/my-system.md

# Write to file AND copy to clipboard
sysinfo2md -c

# Copy to clipboard only (no file written)
sysinfo2md -C

# Suppress status messages
sysinfo2md -q

# Include only specific sections
sysinfo2md --only os,cpu,gpu

# Exclude specific sections
sysinfo2md --exclude battery,packages

# Show verbose package info (last installed packages)
sysinfo2md -v

# List all available sections
sysinfo2md --list-sections

# Show version
sysinfo2md -V

# Show help
sysinfo2md -h
```

## Example output

```markdown
# System Information

_Generated: 2026-03-19 00:35:00 EDT_

## Operating System

- **Device**: HP OmniBook X Flip Laptop 16-ar0xxx
- **Distro**: Arch Linux
- **Kernel**: 6.18.13-arch1-1
- **Architecture**: x86_64
- **Hostname**: mymachine
- **Session type**: wayland
- **Uptime**: 5 hours, 12 minutes
- **Locale**: en_US.UTF-8

## CPU

- **Model**: AMD Ryzen AI 5 340 w/ Radeon 840M
- **Physical cores**: 6
- **Logical threads**: 12
- **Current frequency**: 3.4 GHz
- **Governor**: powersave
- **Temperature**: 48.8°C
- **Fan speed**: 2950 RPM

## GPU

- AMD Krackan [Radeon 840M / 860M Graphics] (rev c3)

## Desktop Environment

- **Desktop**: KDE
- **Session**: plasma
- **Display server**: wayland
- **Display manager**: sddm
- **Window manager**: kwin_wayland
- **Resolution**: 1920x1200
- **Theme**: Catppuccin-Mocha-Mauve
- **Icons**: Papirus-Dark
- **GTK theme**: catppuccin-mocha-mauve-standard+default
- **Font**: Noto Sans, 10

## Battery

- **Charge**: 82%
- **Status**: Charging
- **Power draw**: 29.7W

## Audio

### Playback devices (PipeWire/PulseAudio)
- Built-in Audio Analog Stereo
- **Audio server**: PipeWire detected

## USB Devices

```
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
Bus 001 Device 002: ID 04f2:b7fe Chicony Electronics Co., Ltd HP 5MP Camera
```

## Input Devices

- **Keyboard**: AT Translated Set 2 keyboard
- **Pointing devices**: HP Elite USB-C Hub Pointer

## Virtualization

- **Type**: Bare metal

...
```

## Options

| Flag | Long form | Description |
|---|---|---|
| `-o FILE` | `--output FILE` | Output file path (default: `~/sysinfo.md`) |
| `-s` | `--stdout` | Print to stdout instead of writing a file |
| `-c` | `--clipboard` | Write to file and copy to clipboard |
| `-C` | `--clipboard-only` | Copy to clipboard only, no file written |
| `-q` | `--quiet` | Suppress status messages |
| `-v` | `--verbose` | Show last installed packages per manager |
| `-e SECTIONS` | `--exclude SECTIONS` | Exclude sections (comma-separated) |
| `-n SECTIONS` | `--only SECTIONS` | Include only specified sections |
| `-l` | `--list-sections` | List all available sections and exit |
| `-V` | `--version` | Show version and exit |
| `-h` | `--help` | Show help and exit |

### Available sections

`os`, `cpu`, `memory`, `gpu`, `storage`, `network`, `desktop`, `shell`, `packages`, `battery`, `audio`, `usb`, `input`, `virtualization`

### Examples

```bash
# Only OS and CPU info
sysinfo2md --only os,cpu

# Everything except battery and packages
sysinfo2md --exclude battery,packages

# Quiet mode for scripting
sysinfo2md -q -o /tmp/sysinfo.md

# Pipe to AI agent
sysinfo2md --only os,cpu,gpu --stdout | my-ai-agent

# Full output with recent packages
sysinfo2md --verbose
```

## License

MIT
