# CLI Usability Checklist

Quick reference for usable, scriptable CLI tools. Use alongside the `go-cli-project` and `cli-app-designer` skills.

## Exit Codes
- [ ] `0` on success
- [ ] `1` on runtime error (I/O failure, parse error, unexpected state)
- [ ] `2` on invalid usage (bad flags, missing required args)
- [ ] `130` on SIGINT (Ctrl+C)
- [ ] Non-zero exit for every failure path — never exit 0 on error

## Output Streams
- [ ] Primary output goes to stdout only
- [ ] Errors, warnings, and log lines go to stderr only
- [ ] No progress noise or decorative output mixed into stdout
- [ ] stdout is pipe-safe: plain text or machine-readable JSON, nothing else
- [ ] Color and formatting use stderr or TTY detection (`os.Stdout.Fd()`)

## Help Output
- [ ] `help` subcommand (not `--help`) prints usage to stdout and exits 0
- [ ] Usage line shows all flags and their defaults
- [ ] Every flag, env var, and config key documented in `--help` / USAGE.txt
- [ ] Examples included for non-obvious workflows
- [ ] `help <subcommand>` works when subcommands exist

## Error Messages
- [ ] Message says what failed and includes the problematic value
- [ ] Message is on stderr, not stdout
- [ ] Message suggests a fix when the cause is a bad argument or config
- [ ] No stack traces in user-facing errors (log them at debug level)

## Machine-Readable Output
- [ ] `--json` flag produces valid JSON on stdout, nothing else
- [ ] JSON output is stable: same input always produces same keys
- [ ] Structured errors (`{"error": "..."}`) when `--json` is active
- [ ] No extra fields added without bumping a version marker

## Scriptability
- [ ] No interactive prompts unless explicitly invoked (e.g. `--interactive`)
- [ ] stdin readable when input is piped (`-` as explicit stdin arg, or auto-detect)
- [ ] Deterministic output order — no random map iteration in output
- [ ] No output line wider than 120 chars by default (or configurable)

## Signal Handling
- [ ] SIGINT (Ctrl+C) → clean exit, exit code 130
- [ ] SIGTERM → clean exit, exit code 1
- [ ] In-progress work is flushed or rolled back before exit
- [ ] No zombie goroutines left after signal

## Configuration
- [ ] Config loaded in order: defaults → `/etc/<tool>/config.yaml` → `~/.config/<tool>/config.yaml` → env vars → flags
- [ ] `--config <path>` overrides all config file locations
- [ ] `--verbose` enables debug output to stderr
- [ ] Unknown config keys warn rather than silently ignore

## Version Output
- [ ] `version` subcommand prints semver to stdout and exits 0
- [ ] Version string is machine-parseable (`v1.2.3`, not `Tool v1.2.3 (built on ...)`)
- [ ] Build metadata (commit, date) printed only with `--verbose`

## Anti-Patterns

| Anti-Pattern | Problem | Fix |
|---|---|---|
| Printing errors to stdout | Breaks pipe consumers and scripts | Use stderr for all errors |
| Exit 0 on failure | Scripts can't detect failure | Always exit non-zero on error |
| Hardcoded color codes on stdout | Corrupts piped output | Only colorize stderr or when TTY detected |
| Interactive prompt with no opt-out | Blocks automation | Add `--yes` / `--non-interactive` flag |
| Mixing log lines into stdout | Pollutes machine-readable output | Send logs to stderr |
| No `--json` flag for structured output | Forces brittle text parsing | Add `--json` for any tool consumed by scripts |
| Progress bar on stdout | Breaks pipe consumers | Progress to stderr only |
| Fatal on missing optional config | Breaks users who omit it | Apply defaults, warn on stderr |
