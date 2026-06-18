---
name: minecraft-development
description: Develop Minecraft plugins and mods. Use for Paper plugins, Fabric mods, NeoForge mods, Gradle setup, plugin.yml, fabric.mod.json, mods.toml, Mixins, and MC-specific APIs.
---

# Minecraft Development

This skill covers three Minecraft development targets:

| Target        | Type                | Build plugin    | Plugin/mod metadata  |
|---------------|---------------------|-----------------|----------------------|
| **Paper**     | Server plugin only  | Paperweight     | `plugin.yml`         |
| **Fabric**    | Client + server mod | Fabric Loom     | `fabric.mod.json`    |
| **NeoForged** | Client + server mod | NeoGradle / MDG | `neoforge.mods.toml` |

Dev environment is always Linux. The runtime can be anything Minecraft supports.

**Version-check everything, every time.** Minecraft's ecosystem moves fast and breaks things constantly — not just the game API, but Gradle plugin versions, toolchain/Java requirements, mapping sets (Mojmap/Yarn), metadata file schemas (`plugin.yml`, `fabric.mod.json`, `neoforge.mods.toml`), and even Gradle itself. Code, docs, or examples that are a year old (or sometimes a few months old) can be subtly or completely wrong. Before trusting any doc, example, or interface:
- Confirm which MC version it targets and whether that matches the user's target version.
- Don't assume a pattern that worked for one MC version still applies to another, even adjacent ones — re-check rather than extrapolate.
- This applies to build files and tooling versions just as much as to game APIs.

**Language and build constraints (non-negotiable):**
- Build files: Gradle Groovy DSL only (`build.gradle`, never `build.gradle.kts`)
- Source language: Java only (no Kotlin, no Groovy source files)
- Preference order: Java > Groovy > Kotlin, Gradle > Maven

## First step: establish context

Before writing any code or config, determine:

1. **Which framework?** Paper, Fabric, or NeoForge. If unclear, ask.
2. **Which MC version?** If the user hasn't specified, get the latest stable release:
   ```sh
   curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' \
     | jq -r '.versions | map(select(.type == "release")) | .[0].id'
   ```
   Use this version everywhere — Gradle dependencies, plugin metadata, API version strings. Once known, treat it as the lens for everything that follows: any doc, snippet, or interface you consult next needs to be checked against this specific version, not assumed current.

Then read the relevant reference file before proceeding:

- Paper plugin → `references/paper.md`
- Paper server config → `references/paper-configuration.md`
- Fabric mod → `references/fabric.md`
- NeoForge mod → `references/neoforge.md`
- Any framework → `references/common.md` for asset/data file paths, JSON formats, identifiers, lang, models, recipes, loot tables, tags
- Mixins (Fabric or NeoForge) → `references/mixins.md` for mixins.json schema, annotation reference, and accessor pattern

## Common conventions across all three

**Gradle is the build tool.** All three frameworks ship Gradle plugins that handle Minecraft-specific setup (source remapping, deobfuscation, run tasks). Never reach for Maven.

**Java version**: tracks the MC version (e.g. MC 26.x targets Java 25+) and has bumped multiple times across recent MC releases. Check the required Java version for the target MC version rather than assuming, then set it via `toolchain { languageVersion = JavaLanguageVersion.of(<n>) }` in Gradle.

**Always verify API versions against the actual MC version being targeted.** Paper API, Fabric API, and NeoForge API all have their own versioning that tracks MC versions. Do not guess version numbers — derive them from official sources or ask the user to confirm.

**Build and run commands** (all three):
```sh
./gradlew build          # compile and package the jar
./gradlew test           # run unit tests
./gradlew runServer      # launch a dev server (Paper/NeoForge)
./gradlew runClient      # launch a dev client (Fabric/NeoForge)
```

## When the user is scaffolding a new project

Walk through in this order:
1. Confirm framework and MC version.
2. Set up `build.gradle` with the correct plugin and repositories (see reference file).
3. Create the framework's metadata file (`plugin.yml`, `fabric.mod.json`, or `neoforge.mods.toml`).
4. Write the main entry point class.
5. Show how to run the dev environment.

Do not generate boilerplate beyond these steps. If the user wants events, commands, etc., add them on request.

## Handoffs

- **Upstream:** `spec-driven-development` — if the project needs a design pass before scaffolding; `planning-and-task-breakdown` — for multi-feature plugins/mods
- **Downstream:** `test-driven-development` — unit tests for plugin/mod logic; `git-workflow-and-versioning` — commit scaffolding before adding features
