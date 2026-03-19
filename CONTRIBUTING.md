# Contributing to sysinfo2md

Thanks for your interest in contributing! This is a small Bash project, so the bar to entry is low.

## Ways to contribute

- **Bug reports** — open an issue describing what went wrong and on which distro/hardware
- **New info sections** — add support for hardware or software not currently covered
- **Distro compatibility** — test and fix issues on non-Arch distros
- **Clipboard backends** — add support for additional clipboard tools

## Getting started

```bash
git clone https://github.com/jhicksdev/sysinfo2md.git
cd sysinfo2md
bash install.sh
```

## Making changes

All logic lives in `sysinfo2md.sh`. Each section of the Markdown output is its own function (e.g. `section_cpu`, `section_gpu`) — adding a new section means writing a new function, registering it with `register_section`, and adding it to the `build_markdown` case statement.

**Before submitting a pull request:**

- Test the script end-to-end: `bash sysinfo2md.sh --stdout` or `bash sysinfo2md.sh -o /tmp/test.md && cat /tmp/test.md`
- Make sure the script passes syntax check: `bash -n sysinfo2md.sh`
- Run the test suite: `bats tests/` (requires [bats](https://github.com/bats-core/bats-core))
- If adding a new section, add it to the `register_section` calls and the `build_markdown` case statement

## Testing

The project uses [BATS](https://github.com/bats-core/bats-core) for shell testing.

```bash
# Install bats (Arch)
sudo pacman -S bats

# Install bats (Debian/Ubuntu)
sudo apt-get install bats

# Run all tests
bats tests/

# Run a single test file
bats tests/sysinfo2md.bats
```

Tests cover: `--help`, `--version`, `--list-sections`, `--stdout`, `--only`, `--exclude`, `--quiet`, `--verbose`, output file writing, and error handling.

## Code style

- **Pure Bash** — no Python, no external scripts
- **ShellCheck** — the project is checked with ShellCheck (CI enforces `severity: error`)
- **Strict mode** — always use `set -euo pipefail`
- **Use `local`** for all function-scoped variables
- **Guard optional commands** with `command -v` and provide a graceful fallback
- **Suppress expected errors** with `2>/dev/null` rather than letting sections silently disappear
- **Wrap GUI binaries** that may hang in `timeout 2` when calling with `--version`
- **Keep new section functions consistent** with the existing pattern:

```bash
section_foo() {
    echo "## Foo"
    echo ""
    # ... content ...
}
```

- **Register new sections** at the top of the script (after `register_all_sections`) and add to the `build_markdown` case statement:

```bash
# In register_all_sections():
register_section "foo"

# In build_markdown() case statement:
foo) section_foo ;;
```

## Versioning

This project follows [Semantic Versioning](https://semver.org/):

- **Patch** (`0.x.1`) — bug fixes and small corrections
- **Minor** (`0.x+1.0`) — new features or sections
- **Major** (`1.0.0`) — first full, polished release (reserved)

When bumping the version, update `VERSION` in `sysinfo2md.sh` and add an entry to `CHANGELOG.md`.

## Submitting a pull request

1. Fork the repo and create a branch for your change
2. Make your changes and test them
3. Open a pull request with a clear description of what was changed and why

## Reporting bugs

Open a GitHub issue and include:
- Your distro and version
- Your display server (Wayland or X11)
- The full error output or the section of the Markdown that looks wrong
