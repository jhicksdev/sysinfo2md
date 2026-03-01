#!/usr/bin/env bash
# sysinfo2md — gather system hardware/software info and write to Markdown
# Usage: sysinfo2md [-o FILE] [-c] [-C] [-h]

set -euo pipefail

VERSION="0.6.1"

OUTPUT_FILE="$HOME/sysinfo.md"
COPY_TO_CLIPBOARD=false
CLIPBOARD_ONLY=false
STDOUT_ONLY=false

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------
usage() {
    cat <<EOF
Usage: sysinfo2md [OPTIONS]

Collect system hardware and software information and write it to a Markdown file.

Options:
  -o, --output FILE    Output file path (default: ~/sysinfo.md)
  -s, --stdout         Print to stdout instead of writing a file
  -c, --clipboard      Write to file AND copy to clipboard
  -C, --clipboard-only Copy to clipboard only, do not write a file
  -v, --version        Show version and exit
  -h, --help           Show this help message and exit

Clipboard backends (tried in order): wl-copy (Wayland), xclip, xsel
EOF
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        -o|--output)
            OUTPUT_FILE="$2"
            shift 2
            ;;
        -s|--stdout)
            STDOUT_ONLY=true
            shift
            ;;
        -c|--clipboard)
            COPY_TO_CLIPBOARD=true
            shift
            ;;
        -C|--clipboard-only)
            CLIPBOARD_ONLY=true
            shift
            ;;
        -v|--version)
            echo "sysinfo2md $VERSION"
            exit 0
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            echo "sysinfo2md: unknown option '$1'" >&2
            usage >&2
            exit 1
            ;;
    esac
done

# ---------------------------------------------------------------------------
# Clipboard helper
# ---------------------------------------------------------------------------
copy_to_clipboard() {
    local content="$1"
    if command -v wl-copy &>/dev/null; then
        printf '%s' "$content" | wl-copy
        echo "Copied to clipboard via wl-copy (Wayland)."
    elif command -v xclip &>/dev/null; then
        printf '%s' "$content" | xclip -selection clipboard
        echo "Copied to clipboard via xclip (X11)."
    elif command -v xsel &>/dev/null; then
        printf '%s' "$content" | xsel --clipboard --input
        echo "Copied to clipboard via xsel (X11)."
    else
        echo "Warning: no clipboard tool found (install wl-copy, xclip, or xsel)." >&2
    fi
}

# ---------------------------------------------------------------------------
# Info collectors — each prints its own Markdown section
# ---------------------------------------------------------------------------

section_os() {
    echo "## Operating System"
    echo ""
    if [[ -r /sys/class/dmi/id/product_name ]]; then
        echo "- **Device**: $(< /sys/class/dmi/id/product_name)"
    fi
    if [[ -f /etc/os-release ]]; then
        # shellcheck source=/dev/null
        source /etc/os-release
        echo "- **Distro**: ${PRETTY_NAME:-unknown}"
    fi
    echo "- **Kernel**: $(uname -r)"
    echo "- **Architecture**: $(uname -m)"
    echo "- **Hostname**: $(hostname 2>/dev/null || cat /etc/hostname 2>/dev/null || uname -n)"
    if [[ -n "${XDG_SESSION_TYPE:-}" ]]; then
        echo "- **Session type**: $XDG_SESSION_TYPE"
    fi
    local uptime_str
    uptime_str=$(uptime -p 2>/dev/null | sed 's/^up //')
    if [[ -z "$uptime_str" ]] && [[ -f /proc/uptime ]]; then
        local secs days hours mins
        secs=$(awk '{print int($1)}' /proc/uptime)
        days=$((secs / 86400)); hours=$(( (secs % 86400) / 3600 )); mins=$(( (secs % 3600) / 60 ))
        [[ $days -gt 0 ]] && uptime_str="${days}d "
        [[ $hours -gt 0 ]] && uptime_str="${uptime_str}${hours}h "
        [[ $mins -gt 0 ]] && uptime_str="${uptime_str}${mins}m"
        uptime_str="${uptime_str% }"
    fi
    [[ -n "$uptime_str" ]] && echo "- **Uptime**: $uptime_str"
    echo "- **Locale**: ${LANG:-unknown}"
}

section_cpu() {
    echo "## CPU"
    echo ""
    local model cores threads freq
    model=$(grep -m1 "^model name" /proc/cpuinfo | cut -d: -f2- | xargs)
    if [[ -z "$model" ]]; then
        model=$(grep -m1 "^Hardware" /proc/cpuinfo | cut -d: -f2- | xargs)
    fi
    if [[ -z "$model" ]] && [[ -f /proc/device-tree/model ]]; then
        model=$(tr -d '\0' < /proc/device-tree/model)
    fi
    cores=$(grep -m1 "^cpu cores" /proc/cpuinfo | cut -d: -f2 | xargs)
    threads=$(grep -c "^processor" /proc/cpuinfo)
    freq=$(grep -m1 "^cpu MHz" /proc/cpuinfo | cut -d: -f2 | xargs | awk '{printf "%.1f GHz", $1/1000}')
    if [[ -z "$freq" ]] && [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq ]]; then
        freq=$(awk '{printf "%.1f GHz", $1/1000000}' /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)
    fi
    echo "- **Model**: ${model:-unknown}"
    echo "- **Physical cores**: ${cores:-unknown}"
    echo "- **Logical threads**: $threads"
    echo "- **Current frequency**: ${freq:-unknown}"
    if [[ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]]; then
        echo "- **Governor**: $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)"
    fi
    local cpu_temp=""
    if command -v sensors &>/dev/null; then
        cpu_temp=$(sensors 2>/dev/null | grep -E '^(Tctl|Package id 0|Core 0):' | head -1 | grep -oP '[+-]\d+\.\d+' | head -1 | sed 's/^+//' || true)
        [[ -n "$cpu_temp" ]] && cpu_temp="${cpu_temp}°C"
    fi
    if [[ -z "$cpu_temp" ]] && [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
        cpu_temp=$(awk '{printf "%.1f°C", $1/1000}' /sys/class/thermal/thermal_zone0/temp)
    fi
    [[ -n "$cpu_temp" ]] && echo "- **Temperature**: $cpu_temp"
    local fan_speed=""
    if command -v sensors &>/dev/null; then
        fan_speed=$(sensors 2>/dev/null | grep -E '^fan[0-9]+:' | grep -v '\s0 RPM' | head -1 | awk '{print $2, $3}' || true)
    fi
    [[ -n "$fan_speed" ]] && echo "- **Fan speed**: $fan_speed"
}

section_memory() {
    echo "## Memory (RAM)"
    echo ""
    echo '```'
    free -h --si 2>/dev/null || free -h
    echo '```'
}

section_gpu() {
    echo "## GPU"
    echo ""
    if command -v lspci &>/dev/null; then
        local gpus
        gpus=$(lspci | grep -iE 'VGA|3D controller|Display controller' \
            | sed 's/^[^ ]* //' \
            | sed 's/^[^:]*: //' \
            | sed 's/Advanced Micro Devices, Inc\. \[AMD\/ATI\]/AMD/' \
            | sed 's/NVIDIA Corporation/NVIDIA/' \
            | sed 's/Intel Corporation/Intel/')
        if [[ -n "$gpus" ]]; then
            while IFS= read -r gpu; do
                echo "- $gpu"
            done <<< "$gpus"
        else
            echo "_No GPU detected via lspci._"
        fi
    else
        echo "_lspci not available._"
    fi
    # NVIDIA extra info
    if command -v nvidia-smi &>/dev/null; then
        echo ""
        echo "**NVIDIA driver info:**"
        echo '```'
        nvidia-smi --query-gpu=name,driver_version,memory.total,temperature.gpu \
            --format=csv,noheader 2>/dev/null || true
        echo '```'
    fi
    # AMD extra info
    if command -v radeontop &>/dev/null; then
        echo ""
        echo "_radeontop is available for AMD GPU monitoring._"
    fi
}

section_storage() {
    echo "## Storage"
    echo ""
    echo "### Block devices"
    echo '```'
    lsblk -o NAME,SIZE,TYPE,FSTYPE,MOUNTPOINTS 2>/dev/null || lsblk -o NAME,SIZE,TYPE,MOUNTPOINT
    echo '```'
    echo ""
    echo "### Filesystem usage"
    echo '```'
    df -h --output=source,fstype,size,used,avail,pcent,target \
        | grep -vE '^tmpfs|^devtmpfs|^udev|^efivarfs|^Filesystem' \
        | { echo "Source          FStype    Size  Used Avail Use% Mounted on"; cat; } \
        2>/dev/null || df -h
    echo '```'
}

section_network() {
    echo "## Network"
    echo ""
    echo "### Interfaces"
    echo '```'
    if command -v ip &>/dev/null; then
        ip -brief address 2>/dev/null || ip address
    elif command -v ifconfig &>/dev/null; then
        ifconfig
    else
        echo "_No network tool available (ip, ifconfig)._"
    fi
    echo '```'
}

section_desktop() {
    echo "## Desktop Environment"
    echo ""
    local found=false
    if [[ -n "${XDG_CURRENT_DESKTOP:-}" ]]; then
        echo "- **Desktop**: $XDG_CURRENT_DESKTOP"
        found=true
    fi
    if [[ -n "${DESKTOP_SESSION:-}" ]]; then
        echo "- **Session**: $DESKTOP_SESSION"
        found=true
    fi
    if [[ -n "${XDG_SESSION_TYPE:-}" ]]; then
        echo "- **Display server**: $XDG_SESSION_TYPE"
        found=true
    fi
    # Display manager
    local dm_id=""
    if command -v systemctl &>/dev/null; then
        dm_id=$(systemctl show display-manager.service --no-pager --property=Id 2>/dev/null \
            | cut -d= -f2 | sed 's/\.service$//')
    fi
    if [[ -n "$dm_id" && "$dm_id" != "Id" ]]; then
        local dm_ver=""
        if command -v "$dm_id" &>/dev/null; then
            dm_ver=$("$dm_id" --version 2>/dev/null | head -1 | xargs) || true
        fi
        echo "- **Display manager**: $dm_id${dm_ver:+ $dm_ver}"
        found=true
    fi
    # Window manager
    local wm=""
    for wm_bin in kwin_wayland kwin_x11 mutter gnome-shell openbox i3 sway bspwm xfwm4 marco fluxbox icewm; do
        if pgrep -x "$wm_bin" &>/dev/null; then
            wm="$wm_bin"
            break
        fi
    done
    [[ -n "$wm" ]] && echo "- **Window manager**: $wm" && found=true
    # Screen resolution
    local resolution=""
    if command -v xrandr &>/dev/null && [[ -n "${DISPLAY:-}" ]]; then
        resolution=$(xrandr 2>/dev/null | grep ' connected' | grep -oP '\d+x\d+(?=\+)' | head -1 || true)
    fi
    if [[ -z "$resolution" ]]; then
        resolution=$(cat /sys/class/drm/*/modes 2>/dev/null | head -1 || true)
    fi
    [[ -n "$resolution" ]] && echo "- **Resolution**: $resolution" && found=true
    # Wayland/X display
    if [[ -n "${WAYLAND_DISPLAY:-}" ]]; then
        echo "- **Wayland display**: $WAYLAND_DISPLAY"
        found=true
    fi
    if [[ -n "${DISPLAY:-}" ]]; then
        echo "- **X display**: $DISPLAY"
        found=true
    fi
    # KDE theme and icons
    if [[ -f ~/.config/kdeglobals ]]; then
        local kde_theme kde_icons
        kde_theme=$(awk -F= '/^\[KDE\]/{s=1;next} /^\[/{s=0} s && /^LookAndFeelPackage=/{print $2;exit}' \
            ~/.config/kdeglobals 2>/dev/null || true)
        kde_icons=$(awk -F= '/^\[Icons\]/{s=1;next} /^\[/{s=0} s && /^Theme=/{print $2;exit}' \
            ~/.config/kdeglobals 2>/dev/null || true)
        [[ -n "$kde_theme" ]] && echo "- **Theme**: $kde_theme" && found=true
        [[ -n "$kde_icons" ]] && echo "- **Icons**: $kde_icons" && found=true
    fi
    # GTK/GNOME theme, icons, and font
    local gtk_theme="" gtk_icons="" gtk_font=""
    local gtk_cfg=~/.config/gtk-3.0/settings.ini
    if [[ -f "$gtk_cfg" ]]; then
        gtk_theme=$(grep '^gtk-theme-name=' "$gtk_cfg" | cut -d= -f2 | xargs || true)
        gtk_font=$(grep '^gtk-font-name=' "$gtk_cfg" | cut -d= -f2 | xargs || true)
    elif command -v gsettings &>/dev/null; then
        gtk_theme=$(gsettings get org.gnome.desktop.interface gtk-theme 2>/dev/null | tr -d "'" || true)
        gtk_icons=$(gsettings get org.gnome.desktop.interface icon-theme 2>/dev/null | tr -d "'" || true)
        gtk_font=$(gsettings get org.gnome.desktop.interface font-name 2>/dev/null | tr -d "'" || true)
    fi
    if [[ -f ~/.config/kdeglobals ]]; then
        [[ -n "$gtk_theme" ]] && echo "- **GTK theme**: $gtk_theme" && found=true
    else
        [[ -n "$gtk_theme" ]] && echo "- **Theme**: $gtk_theme" && found=true
        [[ -n "$gtk_icons" ]] && echo "- **Icons**: $gtk_icons" && found=true
    fi
    [[ -n "$gtk_font" ]] && echo "- **Font**: $gtk_font" && found=true
    if ! $found; then
        echo "_Could not detect desktop environment (may be running headless)._"
    fi
}

section_shell_and_term() {
    echo "## Shell & Terminal"
    echo ""
    echo "- **Login shell**: $(basename "$SHELL") ($SHELL)"
    local shell_ver
    shell_ver=$("$SHELL" --version 2>&1 | head -1) && echo "- **Shell version**: $shell_ver" || true
    if [[ -n "${TERM:-}" ]]; then
        echo "- **TERM**: $TERM"
    fi
    if [[ -n "${TERM_PROGRAM:-}" ]]; then
        echo "- **Terminal emulator**: $TERM_PROGRAM"
    fi
}

section_packages() {
    echo "## Installed Packages"
    echo ""
    local found=false
    if command -v pacman &>/dev/null; then
        echo "- **pacman**: $(pacman -Q 2>/dev/null | wc -l) packages"
        found=true
    fi
    if command -v dpkg &>/dev/null; then
        echo "- **dpkg**: $(dpkg -l 2>/dev/null | grep -c '^ii') packages"
        found=true
    fi
    if command -v rpm &>/dev/null; then
        echo "- **rpm**: $(rpm -qa 2>/dev/null | wc -l) packages"
        found=true
    fi
    if command -v flatpak &>/dev/null; then
        echo "- **flatpak**: $(flatpak list 2>/dev/null | wc -l) packages"
        found=true
    fi
    if command -v snap &>/dev/null; then
        echo "- **snap**: $(snap list 2>/dev/null | tail -n +2 | wc -l) packages"
        found=true
    fi
    if ! $found; then
        echo "_No recognised package manager found._"
    fi
}

section_battery() {
    local bat_dir=""
    for d in /sys/class/power_supply/BAT*; do
        [[ -d "$d" ]] && bat_dir="$d" && break
    done
    [[ -z "$bat_dir" ]] && return

    echo "## Battery"
    echo ""
    local capacity status
    capacity=$(cat "$bat_dir/capacity" 2>/dev/null)
    status=$(cat "$bat_dir/status" 2>/dev/null)
    [[ -n "$capacity" ]] && echo "- **Charge**: ${capacity}%"
    [[ -n "$status" ]] && echo "- **Status**: $status"
    if [[ -f "$bat_dir/power_now" ]]; then
        local power_uw
        power_uw=$(cat "$bat_dir/power_now" 2>/dev/null)
        if [[ -n "$power_uw" && "$power_uw" -gt 0 ]]; then
            echo "- **Power draw**: $(awk "BEGIN {printf \"%.1fW\", $power_uw/1000000}")"
        fi
    fi
    if [[ "$status" == "Discharging" && -f "$bat_dir/energy_now" && -f "$bat_dir/power_now" ]]; then
        local energy_now power_now
        energy_now=$(cat "$bat_dir/energy_now" 2>/dev/null)
        power_now=$(cat "$bat_dir/power_now" 2>/dev/null)
        if [[ -n "$energy_now" && -n "$power_now" && "$power_now" -gt 0 ]]; then
            echo "- **Time remaining**: ~$(awk "BEGIN {printf \"%.1fh\", $energy_now/$power_now}")"
        fi
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------
build_markdown() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S %Z')

    echo "# System Information"
    echo ""
    echo "_Generated: ${timestamp}_"
    echo ""

    section_os
    echo ""
    section_cpu
    echo ""
    section_memory
    echo ""
    section_gpu
    echo ""
    section_storage
    echo ""
    section_network
    echo ""
    section_desktop
    echo ""
    section_shell_and_term
    echo ""
    section_packages
    echo ""
    section_battery
}

CONTENT=$(build_markdown)

if $STDOUT_ONLY; then
    printf '%s\n' "$CONTENT"
elif $CLIPBOARD_ONLY; then
    copy_to_clipboard "$CONTENT"
else
    printf '%s\n' "$CONTENT" > "$OUTPUT_FILE"
    echo "System info written to: $OUTPUT_FILE"
    if $COPY_TO_CLIPBOARD; then
        copy_to_clipboard "$CONTENT"
    fi
fi
