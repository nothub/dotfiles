---
name: minecraft-development
description: Assist with Minecraft plugin and mod development — Paper server plugins, Fabric mods, and NeoForged mods. Use this skill whenever the user is working on a Minecraft plugin or mod, asks about Paper, Fabric, Loom, NeoForge, NeoGradle, Bukkit, Spigot, plugin.yml, fabric.mod.json, mods.toml, event listeners, Mixin patches, DeferredRegister, JavaPlugin, or any Minecraft modding API. Also trigger when the user asks about scaffolding a new plugin/mod project, setting up Gradle for Minecraft, or questions about MC-specific APIs like BukkitScheduler, Fabric registries, or NeoForge capabilities.
---

# Minecraft Development

This skill covers three Minecraft development targets:

| Target        | Type                | Build plugin    | Config file          |
|---------------|---------------------|-----------------|----------------------|
| **Paper**     | Server plugin only  | Paperweight     | `paper.yml`          |
| **Fabric**    | Client + server mod | Fabric Loom     | `fabric.mod.json`    |
| **NeoForged** | Client + server mod | NeoGradle / MDG | `neoforge.mods.toml` |

Dev environment is always Linux. The runtime can be anything Minecraft supports.

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
   Use this version everywhere — Gradle dependencies, plugin metadata, API version strings.

Then read the relevant reference file before proceeding:

- Paper → `references/paper.md`
- Fabric → `references/fabric.md`
- NeoForge → `references/neoforge.md`

## Common conventions across all three

**Gradle is the build tool.** All three frameworks ship Gradle plugins that handle Minecraft-specific setup (source remapping, deobfuscation, run tasks). Never reach for Maven.

**Java version**: Minecraft 26.x targets Java 21+. Use `toolchain { languageVersion = JavaLanguageVersion.of(21) }` in Gradle unless a newer version is required.

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
3. Create the framework's metadata file (`paper-plugin.yml`, `fabric.mod.json`, or `neoforge.mods.toml`).
4. Write the main entry point class.
5. Show how to run the dev environment.

Do not generate boilerplate beyond these steps. If the user wants events, commands, etc., add them on request.
