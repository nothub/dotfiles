---
name: ci-cd-and-automation
description: Set up or modify CI/CD pipelines. Use for Forgejo Actions, Jenkins, quality gates, semver release automation, and VPS or Kubernetes deployment.
---

# CI/CD and Automation

## Overview

Automate quality gates so no change reaches production without passing build, vet, and tests. CI is the enforcement layer for code quality — it catches what humans miss, consistently, on every change.

**Shift left:** Static analysis before tests, tests before deploy. A bug caught in `go vet` costs seconds; the same bug in production costs hours.

**Small batches:** Frequent deploys of small changes are safer than infrequent deploys of large ones. Three-change deploys are easy to debug. Thirty-change deploys are not.

## CI Providers in Use

| Context | Provider | SCM |
|---|---|---|
| Personal (self-hosted) | Forgejo Actions | Forgejo |
| Work | Jenkins | SCM-Manager |

Jenkins uses a `Jenkinsfile` (declarative pipeline).

## Quality Gate Pipeline

Every change goes through these gates before merge. Adapt the tools to the language.

```
PR / push
    │
    ▼
┌──────────────────┐
│  STATIC ANALYSIS │  go vet, staticcheck, shellcheck
│  ↓ pass          │
│  TESTS           │  go test ./...
│  ↓ pass          │
│  BUILD           │  go build ./...
│  ↓ pass          │
│  SECURITY        │  govulncheck
└──────────────────┘
    │
    ▼
  Ready to merge
```

No gate is skippable. Fix the code, not the check.

## Forgejo Actions and Jenkins

Forgejo SCM is for personal projects, Jenkins (triggered by SCM-Manager via webhook) is for work. Ready-made templates — Forgejo Go CI, Forgejo shell CI, Forgejo semver release, Jenkins declarative pipeline, Jenkins parallel stages, Jenkins secrets — live in `references/ci-pipeline-templates.md`. Read it when setting up or modifying a pipeline.

Not all GitHub marketplace actions are available on Forgejo. Prefer shell steps (`run:`) over third-party actions when possible. Forgejo runners are self-hosted; ensure the runner label matches (`runs-on: ubuntu-latest` maps to whatever label your runner has).

## Conventional Commits and Semver Releases

Commit format: `<type>(<scope>): <description>`

```
feat: add user export endpoint
fix(auth): handle expired token edge case
chore(deps): update go.mod
docs: update README with new flags
feat!: rename config file format  ← breaking change
```

**Version bump rules:**
- `fix:` → patch (1.0.0 → 1.0.1)
- `feat:` → minor (1.0.0 → 1.1.0)
- `feat!:` or `BREAKING CHANGE:` footer → major (1.0.0 → 2.0.0)

**Tagging a release:**

```sh
# Determine version from commits since last tag
git-cliff --bumped-version   # prints e.g. v1.2.0

# Tag and push
VERSION=$(git-cliff --bumped-version)
git tag -s "$VERSION" -m "$VERSION"
git push origin "$VERSION"
```

CI picks up the tag and runs the release job (see Release on tag above).

**Changelog:** `git-cliff` reads conventional commits and generates `CHANGELOG.md` or release notes. Config in `cliff.toml` at repo root.

## Deployment

### VPS (systemd + container)

Deploy by building a container image in CI, pushing to a registry, then pulling on the server:

```yaml
  deploy:
    needs: [check]
    runs-on: ubuntu-24.04
    if: github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v6
      - name: Build and push image
        run: |
          docker build -t registry.example.com/app:${{ github.sha }} .
          docker push registry.example.com/app:${{ github.sha }}
      - name: Deploy
        run: |
          ssh deploy@server "
            docker pull registry.example.com/app:${{ github.sha }}
            systemctl restart app
          "
```

For Podman Quadlet deployments, use Quadlet unit files and an nginx reverse proxy with certbot for HTTPS.

### Kubernetes

Tag-triggered deploy: update the image tag in the manifest and apply.

## Branch Strategy

**Trunk-based (small/fast-moving projects):**

```
main ─── feat/x ──┐
     └── fix/y ───┴── merge to main → deploy
```

CI runs on every PR. Merge when green. Deploy from main.

**Gitflow (larger projects, release planning):**

```
main ─────────────────── release tags
develop ──── feat/x ────┤
         └── feat/y ────┘
```

CI runs on PR to develop and on merge to main. Tags trigger releases.

Don't mix strategies within a project. Pick one at project start.

## Environment Management

```
.env.example     → committed (template, no real values)
.env             → NOT committed (local dev)
CI secrets       → stored in Jenkins credentials / Forgejo secrets
Production       → stored in vault or deployment platform
```

Never put production secrets in CI. Use separate credentials per environment.

## Dependency Updates

Use [Renovate](https://docs.renovatebot.com/) — works with Forgejo and SCM-Manager.

```json
// renovate.json
{
  "$schema": "https://docs.renovatebot.com/renovate-schema.json",
  "configMigration": true,
  "minimumReleaseAge": "3 days",
  "semanticCommits": "enabled",
  "timezone": "Europe/Berlin"
}
```

## CI Optimization

When the pipeline is slow, apply in order:

```
1. Cache dependencies      → actions/cache, Go module cache
2. Parallelize jobs        → lint, test, build as separate jobs
3. Path filters            → skip CI for docs-only changes
4. Shard test suites       → go test -run TestFoo in parallel jobs
5. Self-hosted runners     → faster hardware if hosted runners are the bottleneck
```

## Red Flags

- No CI on a project with more than one contributor
- CI failures ignored or bypassed (`--no-verify`, disabled checks)
- Tests disabled to make the build pass
- Secrets in code or CI config files
- No rollback mechanism for production deploys
- Release process is manual and undocumented

## Verification

After setting up or modifying CI:

- [ ] Build, vet, and tests all run and are required to pass before merge
- [ ] Pipeline triggers on PR and on push to main
- [ ] Secrets are in the secrets store, not in YAML files
- [ ] Release job triggers only on semver tags
- [ ] Deployment has a known rollback path
- [ ] Pipeline completes in under 10 minutes
