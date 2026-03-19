# AGENTS.md

This file provides guidance for agentic coding assistants operating in the sysinfo2md repository.

## Project Overview

**sysinfo2md** is a pure Bash script that collects Linux system hardware/software information and writes it to a Markdown file — ideal for sharing system specs with AI chatbots or agents.

## Build / Lint / Test Commands

### Syntax check
```bash
bash -n sysinfo2md.sh
```

### Run the full test suite
```bash
bats tests/
```

### Run a single test file
```bash
bats tests/sysinfo2md.bats
```

### Run ShellCheck (requires `shellcheck` installed)
```bash
shellcheck sysinfo2md.sh
```

### Run the script
```bash
bash sysinfo2md.sh --stdout          # print to stdout
bash sysinfo2md.sh -o /tmp/test.md   # write to file
bash sysinfo2md.sh --help            # show help
```

## Code Style Guidelines

### Script Settings
- Always use `set -euo pipefail` at the top of the script
- Shebang: `#!/usr/bin/env bash`
- All function-scoped variables must be `local`
- No external dependencies beyond standard Linux tools

### Functions
- Each Markdown section is its own function: `section_<name>()`
- Pattern:
  ```bash
  section_foo() {
      echo "## Foo"
      echo ""
      # ... content ...
  }
  ```
- Guard optional commands with `command -v <cmd> &>/dev/null`
- Suppress expected errors with `2>/dev/null`
- Wrap GUI binaries that may hang with `timeout 2 <cmd> --version`

### Adding a New Section
1. Write the `section_<name>()` function
2. Register it in `register_all_sections()`:
   ```bash
   register_section "name"
   ```
3. Add to `build_markdown()` case statement:
   ```bash
   name) section_name ;;
   ```

### Variables
- Uppercase for globals (`VERSION`, `OUTPUT_FILE`)
- Lowercase for locals
- Use `:=` for defaulting in parameter expansion: `${VAR:-default}`

### Argument Parsing
- Use `while [[ $# -gt 0 ]]; do ... done` with a `case` statement
- Always `shift` after consuming an argument
- Use `--`) to terminate options parsing

### Error Handling
- Unknown options: print to stderr and exit 1
- Missing required args: print to stderr and exit 1
- Use `err() { echo "sysinfo2md: $*" >&2; }` for error messages

### Messaging
- Use `msg() { $QUIET && return; echo "$*"; }` for status messages
- Messages to stdout are suppressed by `--quiet`
- Errors always go to stderr

### String Matching
- Use `[[ ]]` for conditional tests (not `[ ]`)
- Use `==` inside `[[ ]]`, not `=`
- Quote variable expansions: `"$var"`, not `$var`

### Regex / Grep
- Prefer `grep -E` for extended regex
- Use `|| true` to prevent failures in pipelines
- Prefer `[[ "$var" == *pattern* ]]` over `grep` where simple

### Arrays
- Use `declare -a` for indexed arrays
- Iterate with `for item in "${array[@]}"; do ... done`
- Check array length: `[[ ${#array[@]} -gt 0 ]]`

## Architecture

### Modular Section Registry
Sections are registered in `SECTIONS` array via `register_section()`. The `build_markdown()` function iterates this array and calls the appropriate section functions through a `case` statement. This enables `--only` and `--exclude` filtering.

### Flags
| Short | Long | Purpose |
|-------|------|---------|
| `-o` | `--output` | Output file path |
| `-s` | `--stdout` | Print to stdout |
| `-c` | `--clipboard` | Write file and copy |
| `-C` | `--clipboard-only` | Copy only |
| `-q` | `--quiet` | Suppress status messages |
| `-v` | `--verbose` | Show last installed packages |
| `-e` | `--exclude` | Exclude sections (comma-sep) |
| `-n` | `--only` | Include only sections (comma-sep) |
| `-l` | `--list-sections` | List available sections |
| `-V` | `--version` | Show version |
| `-h` | `--help` | Show help |

## Versioning

Follow date-based versioning (`YYYY.MM.DD`). When bumping:
1. Update `VERSION` in `sysinfo2md.sh` (use today's date)
2. Add entry to `CHANGELOG.md` with the same date
3. Update feature list in README.md
4. Only push to GitHub once per day — accumulate changes and push together

## File Structure

```
sysinfo2md.sh       # Main script (all logic lives here)
tests/
  sysinfo2md.bats   # BATS test suite
.github/
  workflows/
    ci.yml          # GitHub Actions CI
CONTRIBUTING.md     # Contributor guidelines
README.md           # User documentation
CHANGELOG.md        # Version history
```

## CI

GitHub Actions runs on every push:
1. **ShellCheck** — linting with `severity: error`
2. **BATS Tests** — full test suite
3. **Syntax Check** — `bash -n` validation

All three jobs must pass for a PR to be merged.
