#!/usr/bin/env bats

SCRIPT="${BATS_TEST_DIRNAME}/../sysinfo2md.sh"

@test "script has valid bash syntax" {
    run bash -n "$SCRIPT"
    [[ $status -eq 0 ]]
}

@test "--help outputs usage information" {
    run bash "$SCRIPT" --help
    [[ $status -eq 0 ]]
    [[ "$output" == *"Usage: sysinfo2md"* ]]
    [[ "$output" == *"--output"* ]]
    [[ "$output" == *"--stdout"* ]]
    [[ "$output" == *"--quiet"* ]]
    [[ "$output" == *"--exclude"* ]]
    [[ "$output" == *"--only"* ]]
    [[ "$output" == *"--list-sections"* ]]
}

@test "--version outputs version string" {
    run bash "$SCRIPT" --version
    [[ $status -eq 0 ]]
    [[ "$output" == "sysinfo2md"* ]]
}

@test "-V (short version) outputs version string" {
    run bash "$SCRIPT" -V
    [[ $status -eq 0 ]]
    [[ "$output" == "sysinfo2md"* ]]
}

@test "--list-sections lists all available sections" {
    run bash "$SCRIPT" --list-sections
    [[ $status -eq 0 ]]
    [[ "$output" == *"Available sections:"* ]]
    [[ "$output" == *"os"* ]]
    [[ "$output" == *"cpu"* ]]
    [[ "$output" == *"memory"* ]]
    [[ "$output" == *"gpu"* ]]
    [[ "$output" == *"storage"* ]]
    [[ "$output" == *"network"* ]]
    [[ "$output" == *"desktop"* ]]
    [[ "$output" == *"shell"* ]]
    [[ "$output" == *"packages"* ]]
    [[ "$output" == *"battery"* ]]
    [[ "$output" == *"audio"* ]]
    [[ "$output" == *"usb"* ]]
    [[ "$output" == *"input"* ]]
    [[ "$output" == *"virtualization"* ]]
}

@test "-l (short list-sections) lists all sections" {
    run bash "$SCRIPT" -l
    [[ $status -eq 0 ]]
    [[ "$output" == *"os"* ]]
    [[ "$output" == *"cpu"* ]]
}

@test "--stdout produces markdown output" {
    run bash "$SCRIPT" --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == "# System Information"* ]]
    [[ "$output" == *"## Operating System"* ]]
    [[ "$output" == *"## CPU"* ]]
    [[ "$output" == *"Generated:"* ]]
}

@test "--stdout does not create a file" {
    OUTPUT="$BATS_TMPDIR/test_no_file_$$"
    run bash "$SCRIPT" --stdout
    [[ ! -f "$OUTPUT" ]]
}

@test "--output writes to specified file" {
    OUTPUT="$BATS_TMPDIR/test_output_$$"
    run bash "$SCRIPT" --output "$OUTPUT"
    [[ $status -eq 0 ]]
    [[ -f "$OUTPUT" ]]
    [[ "$(cat "$OUTPUT")" == "# System Information"* ]]
    rm -f "$OUTPUT"
}

@test "-o (short output) writes to specified file" {
    OUTPUT="$BATS_TMPDIR/test_short_output_$$"
    run bash "$SCRIPT" -o "$OUTPUT"
    [[ $status -eq 0 ]]
    [[ -f "$OUTPUT" ]]
    rm -f "$OUTPUT"
}

@test "--quiet suppresses status messages" {
    OUTPUT="$BATS_TMPDIR/test_quiet_$$"
    run bash "$SCRIPT" --quiet --output "$OUTPUT"
    [[ $status -eq 0 ]]
    [[ "$output" == "" ]]
    rm -f "$OUTPUT"
}

@test "without --quiet, status message is shown" {
    OUTPUT="$BATS_TMPDIR/test_status_$$"
    run bash "$SCRIPT" --output "$OUTPUT"
    [[ $status -eq 0 ]]
    [[ "$output" == *"System info written to:"* ]]
    rm -f "$OUTPUT"
}

@test "--exclude battery removes battery section" {
    run bash "$SCRIPT" --exclude battery --stdout
    [[ $status -eq 0 ]]
    [[ "$output" != *"## Battery"* ]]
    [[ "$output" == *"## Operating System"* ]]
}

@test "--exclude multiple sections removes all specified" {
    run bash "$SCRIPT" --exclude battery,packages --stdout
    [[ $status -eq 0 ]]
    [[ "$output" != *"## Battery"* ]]
    [[ "$output" != *"## Installed Packages"* ]]
    [[ "$output" == *"## Operating System"* ]]
}

@test "-e (short exclude) removes battery section" {
    run bash "$SCRIPT" -e battery --stdout
    [[ $status -eq 0 ]]
    [[ "$output" != *"## Battery"* ]]
}

@test "--only os shows only operating system section" {
    run bash "$SCRIPT" --only os --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Operating System"* ]]
    [[ "$output" != *"## CPU"* ]]
    [[ "$output" != *"## Memory"* ]]
}

@test "--only cpu,network shows only those sections" {
    run bash "$SCRIPT" --only cpu,network --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## CPU"* ]]
    [[ "$output" == *"## Network"* ]]
    [[ "$output" != *"## Operating System"* ]]
    [[ "$output" != *"## Memory"* ]]
}

@test "-n (short only) shows only specified section" {
    run bash "$SCRIPT" -n os --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Operating System"* ]]
    [[ "$output" != *"## CPU"* ]]
}

@test "--only takes precedence over --exclude" {
    run bash "$SCRIPT" --exclude battery --only battery,os --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Operating System"* ]]
    [[ "$output" == *"## Battery"* ]]
    [[ "$output" != *"## CPU"* ]]
}

@test "--only with new audio section includes it" {
    run bash "$SCRIPT" --only audio --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Audio"* ]]
    [[ "$output" != *"## CPU"* ]]
}

@test "--only with new virtualization section includes it" {
    run bash "$SCRIPT" --only virtualization --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Virtualization"* ]]
}

@test "--only with new usb section includes it" {
    run bash "$SCRIPT" --only usb --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## USB Devices"* ]]
}

@test "--only with new input section includes it" {
    run bash "$SCRIPT" --only input --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Input Devices"* ]]
}

@test "--verbose shows recent packages (when supported)" {
    run bash "$SCRIPT" --only packages --verbose --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Installed Packages"* ]]
    [[ "$output" == *"Last installed:"* ]]
}

@test "-v (short verbose) shows recent packages" {
    run bash "$SCRIPT" --only packages -v --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"Last installed:"* ]]
}

@test "unknown option returns error" {
    run bash "$SCRIPT" --unknown-option
    [[ $status -ne 0 ]]
    [[ "$output" == *"unknown option"* ]]
}

@test "combined flags work together" {
    run bash "$SCRIPT" --only os,cpu --quiet --stdout
    [[ $status -eq 0 ]]
    [[ "$output" == *"## Operating System"* ]]
    [[ "$output" == *"## CPU"* ]]
    [[ "$output" != *"## Memory"* ]]
}

@test "default output goes to ~/sysinfo.md" {
    OUTPUT="$HOME/sysinfo.md"
    rm -f "$OUTPUT"
    run bash "$SCRIPT"
    [[ $status -eq 0 ]]
    [[ -f "$OUTPUT" ]]
    [[ "$(cat "$OUTPUT")" == "# System Information"* ]]
    rm -f "$OUTPUT"
}
