# sysinfo2md

A simple Linux command that collects system hardware and software information and writes it to a Markdown file — ideal for quickly sharing your system specs with an AI chatbot.

## Features

- CPU, GPU, RAM, storage, network, desktop environment, shell, and package counts
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

# Write to a custom path
sysinfo2md -o ~/documents/my-system.md

# Write to file AND copy to clipboard
sysinfo2md -c

# Copy to clipboard only (no file written)
sysinfo2md -C

# Show help
sysinfo2md -h
```

## Example output

```markdown
# System Information

_Generated: 2026-02-28 16:21:58 EST_

## Operating System

- **Distro**: Arch Linux
- **Kernel**: 6.18.13-arch1-1
- **Architecture**: x86_64
- **Hostname**: mymachine

## CPU

- **Model**: AMD Ryzen AI 5 340 w/ Radeon 840M
- **Physical cores**: 6
- **Logical threads**: 12
- **Current frequency**: 3426 MHz
- **Governor**: powersave

...
```

## Options

| Flag | Long form | Description |
|---|---|---|
| `-o FILE` | `--output FILE` | Output file path (default: `~/sysinfo.md`) |
| `-c` | `--clipboard` | Write to file and copy to clipboard |
| `-C` | `--clipboard-only` | Copy to clipboard only, no file written |
| `-h` | `--help` | Show help and exit |

## License

MIT
