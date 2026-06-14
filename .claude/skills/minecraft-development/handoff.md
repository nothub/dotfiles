# Handoff: minecraft-development skill

## Goal

Create a Claude skill at `.claude/skills/minecraft-development/` that gives Claude reliable,
accurate context for three Minecraft development targets:

- **Paper** — server-side plugins (Bukkit/Paper API)
- **Fabric** — client+server mods (Fabric Loom, Fabric API, Mixins)
- **NeoForged** — client+server mods (NeoGradle/MDG, event buses, DeferredRegister)

The skill should let Claude scaffold new projects, explain core APIs, generate idiomatic
boilerplate, and answer framework-specific questions — without hallucinating package names,
version strings, or Gradle config.

## Constraints (non-negotiable, user-specified)

- Build files: **Gradle Groovy DSL only** (`build.gradle`, never `build.gradle.kts`)
- Source language: **Java only** (no Kotlin, no Groovy source)
- Preference order when choosing tools: Java > Groovy > Kotlin, Gradle > Maven
- Dev environment: **Linux only** — no macOS/Windows paths, instructions, or workarounds
- Runtime: anything Minecraft supports (no assumption about client/server-only)
- More Gradle conventions are coming from the user — **wait before finalizing build file templates**

## Fetch latest MC version

Run this when the user hasn't pinned a version:

```sh
curl -fsSL 'https://launchermeta.mojang.com/mc/game/version_manifest.json' \
  | jq -r '.versions | map(select(.type == "release")) | .[0].id'
```

As of this writing, latest stable is **26.1.2**.

## Current state

### Files written

```
.dotfiles/.claude/skills/minecraft-development/
├── SKILL.md         ✓  router: pick framework, fetch MC version, common conventions
└── references/
    ├── paper.md     ✓  Gradle (Groovy), paper-plugin.yml, events, commands, scheduler, PDC
    ├── fabric.md    ✓  Gradle (Groovy), fabric.mod.json, events, registries, mixins, config
    └── neoforge.md  ✓  Gradle (Groovy), mods.toml, dual event buses, DeferredRegister, ATs, capabilities
```

All three reference files have been corrected from the initial Kotlin DSL drafts to Groovy DSL.

### What's covered per framework

**Paper** (`references/paper.md`):
- Paperweight userdev Gradle plugin, `paperDevBundle` version string pattern
- `paper-plugin.yml` (modern format — preferred over `plugin.yml`)
- `JavaPlugin` entry point (`onEnable` / `onDisable`)
- Event listeners (`@EventHandler`, `registerEvents`)
- Paper Brigadier command API via `LifecycleEvents.COMMANDS`
- BukkitScheduler (sync/async, delayed/repeating)
- Persistent Data Container
- Key packages table, Adventure Component tip

**Fabric** (`references/fabric.md`):
- Fabric Loom Gradle plugin, version pinning via `gradle.properties`
- Version sources: fabricmc.net/versions.html, maven repos
- `fabric.mod.json` (schema, entrypoints, mixins, depends)
- `ModInitializer` / `ClientModInitializer` entry points
- Event subscription pattern (`EVENT.register(...)`)
- Registry pattern (`Registry.register` via `Registries.*`)
- Mixins (`.mixins.json`, `@Mixin`, `@Inject`) with caution note
- Config: manual JSON in `getConfigDir()`, no built-in API
- `@Environment(EnvType.CLIENT)` for sided code

**NeoForge** (`references/neoforge.md`):
- ModDevGradle (MDG) setup — the current recommended build plugin
- `neoforge.mods.toml` metadata, `${file.jarVersion}` + manifest wiring
- `@Mod` constructor entry point
- **Two event buses** (the #1 NeoForge footgun): mod bus vs NeoForge bus — clearly documented
- `@SubscribeEvent` and `@Mod.EventBusSubscriber` patterns
- `DeferredRegister<T>` registration pattern
- `Dist.CLIENT` sided code with `@EventBusSubscriber`
- Access Transformers (AT) as an alternative to mixins for visibility
- Capabilities (attach behavior without subclassing)
- SRG name tip for AT fields

## What's next

### Blocked: Gradle conventions

User said they have Gradle Groovy DSL preferences to share. Until those arrive, don't
finalize or harden the Gradle sections. When they do come in, apply them consistently
across all three reference files.

### Pending: test case evaluation

Three test prompts were proposed but not run yet:

1. **Paper scaffold** — `"I want to create a new Paper plugin that greets players when they join. Set up the project for me."`
2. **Fabric event** — `"My Fabric mod needs to detect when a player breaks a block and log the block type. How do I set up the event listener?"`
3. **NeoForge block** — `"Add a new custom block to my NeoForge mod. Just a basic block with no special behavior. Show me the DeferredRegister setup and where to call it from my @Mod class."`

User can choose to skip evals and go straight to use, or run them via the skill-creator
eval loop (subagents with and without skill, eval-viewer to compare outputs).

### Nice to have (not committed)

These came up during research but were intentionally left out to avoid scope creep.
Add only if the user asks:

- `settings.gradle` templates (waiting on user Gradle prefs)
- NeoForge data generation (`DataProvider`, `GatherDataEvent`)
- Fabric networking (`ServerPlayNetworking`, `ClientPlayNetworking`)
- Paper's Folia-compatible scheduler (`RegionScheduler`)
- Common cross-framework patterns: config files, lang files, model JSONs, recipes
- A `references/common.md` for shared concepts (resource locations, data packs, loot tables)

## Open questions for user

1. What Gradle project conventions do you use? (wrapper version, `settings.gradle` structure,
   group/version properties, any standard plugins like `spotless`, `checkstyle`?)
2. Do you want devbox integration for the dev environment setup?
3. Should the skill also cover testing? (Mockbukkit for Paper, Fabric's test server for Fabric)
4. Run the test cases or skip evals and start using the skill as-is?
