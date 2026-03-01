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

All logic lives in `sysinfo2md.sh`. Each section of the Markdown output is its own function (e.g. `section_cpu`, `section_gpu`) — adding a new section means writing a new function and calling it in `build_markdown`.

**Before submitting a pull request:**

- Test the script end-to-end: `sysinfo2md --stdout` or `sysinfo2md -o /tmp/test.md && cat /tmp/test.md`
- Make sure the script passes with `bash -n sysinfo2md.sh` (syntax check)
- If adding a new section, add an entry for it in the README feature list

## Code style

- Pure Bash — no Python, no external scripts
- Use `local` for all function-scoped variables
- Guard all optional commands with `command -v` and provide a graceful fallback
- Suppress expected errors with `2>/dev/null` rather than letting sections silently disappear
- Keep new section functions consistent with the existing pattern:
  ```bash
  section_foo() {
      echo "## Foo"
      echo ""
      # ... content ...
  }
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
