---
name: devbox-tool
description: Set up Jetify Devbox environments. Use for devbox.json, devbox CLI (init, add, rm, run, shell), Nix package pinning, project scripts, and reproducible dev environments.
---

# Devbox

Devbox is a CLI tool from Jetify that creates isolated development environments using Nix under the hood.
Each project declares its tools and scripts in a `devbox.json` file at the project root,
which everyone on the team can use to get the same shell environment.

This skill covers editing `devbox.json`, running the `devbox` CLI, and the conventions the user prefers.

## Core conventions (follow these always)

1. **Pin every package to a specific version. Never use `latest` or unversioned packages.** This is the most important rule. Floating versions defeat the entire point of Devbox (reproducibility). If you don't know what version to pin, run `devbox search <pkg> --show-all` first and pick a specific one — do not guess. Examples: `"go@1.22.3"` good, `"go@latest"` bad, `"go"` bad.

2. **Prefer the CLI over hand-editing `devbox.json` for package changes.** `devbox add foo@1.2.3` and `devbox rm foo` keep `devbox.lock` in sync automatically. Hand-edit `devbox.json` only for things the CLI doesn't manage cleanly (scripts, env vars, init hooks, the `$schema` field).

3. **Use `--env-file` + `--pure` for any script that touches secrets or needs a clean environment.** Pattern: `devbox run --env-file=".env" --pure <script-or-cmd>`. `--pure` strips the inherited environment so only what `devbox.json` and `.env` provide is visible — important for build/deploy scripts that must not accidentally pick up host credentials.

4. **Never commit `.env` files.** If you create or modify a `.env`, also make sure `.gitignore` excludes it. Mention this to the user if it isn't already covered.

## Command quick reference

These are the six commands the user cares about most. For anything else, point them at `devbox --help` or the [CLI reference](https://www.jetify.com/docs/devbox/cli-reference/devbox/).

| Command | What it does |
|---|---|
| `devbox init` | Creates a fresh `devbox.json` in the current directory. Run once per project. |
| `devbox list` | Lists packages declared in the current project's `devbox.json`. Add `--outdated` to see which pins have newer versions available. |
| `devbox add <pkg>@<version>` | Adds a package and updates `devbox.lock`. Always supply a version. |
| `devbox rm <pkg>` | Removes a package and updates `devbox.lock`. |
| `devbox run <script-or-cmd>` | Runs a script defined in `devbox.json` (under `shell.scripts`) or an arbitrary command inside the devbox environment. |
| `devbox search <pkg> --show-all` | Searches Nixhub for available package versions. Use before `add` to pick a real version. **Always pass `--show-all`** — the default output is truncated and hides older but often-pinned versions. |

## Workflow: adding a package

When the user says "add X to my devbox" or similar:

1. If they didn't specify a version, run `devbox search <pkg> --show-all` to see the full list of available versions, then pick the latest stable specific version — e.g. `1.22.3`, not `1` or `latest`. Always use `--show-all`; the default output is truncated.
2. Run `devbox add <pkg>@<specific-version>`.
3. Confirm what got added by showing the updated `packages` list, or running `devbox list`.

If the user explicitly asks for `latest`, push back once: explain that pinning is the team convention and that `devbox.lock` will drift unpredictably with `latest`. If they still want `latest`, do it — but make sure they made an informed choice.

## Workflow: defining a script

Scripts go under `shell.scripts` in `devbox.json`. Values can be either a single string or an array of strings (each entry is one shell command, run in sequence). Example:

```json
"shell": {
  "scripts": {
    "build": "go build ./...",
    "deploy": [
      "./scripts/lint.sh",
      "./scripts/deploy.sh"
    ]
  }
}
```

Then `devbox run build` or `devbox run deploy`. For scripts that need secrets, the user runs them as:

```
devbox run --env-file=".env" --pure <script>
```

You do **not** put `--env-file` inside the script definition itself; it's a flag on `devbox run`. Either tell the user the exact invocation, or wrap it in a thin wrapper script if they want a single command.

## Workflow: troubleshooting / auditing an existing devbox.json

When asked to review or fix a `devbox.json`:

- Flag any package without an `@<version>` pin, or with `@latest`. Suggest a specific version (use `devbox search <pkg> --show-all` if available).
- Check that `$schema` points to a real Devbox release version (the URL pattern is `https://raw.githubusercontent.com/jetify-com/devbox/<version>/.schema/devbox.schema.json`).
- Check that scripts referenced under `shell.scripts` actually exist on disk if they're shell-out paths like `./scripts/foo.sh`.
- If there's an `env_from` pointing at a `.env` file, confirm `.gitignore` excludes it.

## Reference

A representative `devbox.json` lives at `references/devbox.json` — read it when the user wants to see a typical setup or you need to remember the structure (packages array, shell.scripts as named entries pointing to shell scripts in `./scripts/`).

The full schema lives at `https://raw.githubusercontent.com/jetify-com/devbox/<version>/.schema/devbox.schema.json` and supports these top-level keys: `$schema`, `packages` (list or map), `env` (string-valued map), `env_from` (path to .env or `jetify-cloud`), `shell.init_hook`, `shell.scripts`, `include`. The official reference page is at https://www.jetify.com/docs/devbox/configuration.
