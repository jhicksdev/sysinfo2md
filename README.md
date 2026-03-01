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
- Clean Markdown output ready to paste anywhere
- Optional clipboard copy (Wayland and X11 supported)
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

# Show version
sysinfo2md -v

# Show help
sysinfo2md -h
```

## Example output

```markdown
# System Information

_Generated: 2026-02-28 16:21:58 EST_

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

...
```

## Options

| Flag | Long form | Description |
|---|---|---|
| `-o FILE` | `--output FILE` | Output file path (default: `~/sysinfo.md`) |
| `-s` | `--stdout` | Print to stdout instead of writing a file |
| `-c` | `--clipboard` | Write to file and copy to clipboard |
| `-C` | `--clipboard-only` | Copy to clipboard only, no file written |
| `-v` | `--version` | Show version and exit |
| `-h` | `--help` | Show help and exit |

## License

MIT
