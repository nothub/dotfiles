---
name: cli-app-designer
description: Design, review, or modify command-line application behavior in any language. Use for commands and subcommands, flags and options, stdin/stdout/stderr behavior, exit codes, process signals, usage text, help output, XDG-compatible configuration, environment variables, SemVer-compatible version output, and documenting the interface in USAGE.txt while keeping it in sync with the implementation.
---

## Specs

Follow these conventions where applicable:

- POSIX-style cli and process behavior
- XDG-compatible file paths

## Usage

- Define the CLI interface in `USAGE.txt`.
- Keep `USAGE.txt` in sync with implemented commands, subcommands, flags, options, env vars, config files, and examples.
- Embed `USAGE.txt` in the app artifact and use it as the source for usage and help messages.

### I/O

- Write primary command output to stdout.
- Write logs, warnings, diagnostics, and errors to stderr.
- Read piped input from stdin when the command accepts stream input.
- Keep stdout pipe- and parse-friendly.
- Do not mix logs or progress output into stdout.

### Commands

These CLI commands should be implemented unless there is a clear reason not to:

- `help`: Show app usage. Default command unless the app has a clear default action.
- `doctor`: Check the app for common problems.
- `config get [key]`: Show the full effective configuration, or one value when `key` is provided.
- `config set <key> <value>`: Persist a configuration value to the user config file.
- `version`: Show the app version.

## Configuration

### Order

The config will be loaded from these sources in order:

1. Hardcoded defaults
2. YAML files
    - `/etc/{{project-name}}/config.yaml`
    - `~/.config/{{project-name}}/config.yaml`
3. Environment variables
4. Flags

### Flags

Every flag must have a long version, the short version is optional.

Make sure these flags are always implemented:

- `--config {{path}}`
- `--verbose`

### Output formats

Prefer human-readable output by default.

Add `--json` only when structured output is useful for scripting or automation.

When `--json` is used:

- write only valid JSON to stdout;
- write logs, warnings, and diagnostics to stderr;
- keep field names stable across compatible versions.

## Signals

Do a graceful shutdown on `SIGINT` or `SIGTERM` signals.
For long-running processes, reload config on `SIGHUP` when practical.

## Exit codes

- Return `0` for success.
- Return non-zero for errors.
- Return `1` for general runtime errors.
- Return `2` for invalid usage, invalid flags, or invalid arguments.
- Return `130` when interrupted by `SIGINT`.
- Print error messages to stderr.
