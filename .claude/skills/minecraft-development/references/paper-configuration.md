# Paper Server Configuration

Paper layers its config across several files. Understanding the hierarchy matters when plugin behavior is overridden by a server setting, or when a plugin needs to read world or server state.

## Config file hierarchy

```
<server-root>/
├── server.properties                   ← vanilla settings (view-distance, max-players, …)
├── bukkit.yml                          ← Bukkit spawn limits, chunk GC, aliases
├── spigot.yml                          ← Spigot mob AI, entity tracking, tick rates
└── config/
    ├── paper-global.yml                ← Paper-wide: proxies, IO, async chunks
    ├── paper-world-defaults.yml        ← per-world defaults
    └── paper-world/
        ├── world/                      ← per-world overrides (inherits world-defaults)
        ├── world_nether/
        └── world_the_end/
```

Keys absent from a per-world directory fall through to `paper-world-defaults.yml`.

## paper-global.yml

Server-wide Paper settings. Generated with all keys on first run.

Key sections relevant to plugin development:

```yaml
proxies:
  velocity:
    enabled: false          # set true when behind a Velocity proxy
    online-mode: false
    secret: ""              # must match Velocity's forwarding.secret

chunk-loading-basic:
  autoconfig-send-distance: true
  player-max-send-distance: 33
  player-max-load-distance: 44

misc:
  load-permissions-yml-before-plugins: true
  chat-threads:
    chat-executor-core-size: -1     # -1 = auto-size

item-validation:
  display-name: 8192                # max chars in item display name
```

## paper-world-defaults.yml

Defaults applied to every world. Edit here to change all worlds; create a per-world file to override one world.

```yaml
entities:
  spawning:
    spawn-limits:
      axolotls: 5
      creature: 10
      monster: 70
      water-ambient: 20
      water-creature: 5
    despawn-ranges:
      monster:
        hard: 128
        soft: 32

chunks:
  entity-per-chunk-save-limit:
    arrow: -1               # -1 = unlimited

environment:
  nether-ceiling-void-damage-height: 0   # 0 = disabled
  disable-explosion-knockback: false

misc:
  disable-teleportation-suffocation-check: false
```

## Reading server settings from plugin code

Paper does not expose most of its config as a stable public API. Use the Bukkit/Paper API methods instead of reading config files directly:

```java
// spawn limits (world-level, respects paper-world-defaults.yml)
int monsterLimit = world.getSpawnLimit(SpawnCategory.MONSTER);

// view and simulation distance
int viewDist = Bukkit.getViewDistance();
int simDist  = Bukkit.getSimulationDistance();

// Spigot config (still available via SpigotConfig)
var spigotWorldConfig = world.spigot().getSpawnCounts();

// check if proxy forwarding is enabled
boolean onlineMode = Bukkit.getOnlineMode();
```

Do not read `paper-global.yml` or `paper-world-defaults.yml` directly from plugin code. Their structure changes between Paper versions and is not part of the stable API.

## Plugin config vs server config

Plugin config (`config.yml` in `getDataFolder()`) is entirely separate from the server config files above.

```java
// extract config.yml from jar resources on first run:
saveDefaultConfig();

// read a value with fallback:
int maxFoo = getConfig().getInt("max-foo", 10);

// write and persist:
getConfig().set("some-key", value);
saveConfig();
```

`getDataFolder()` returns the plugin's own directory (e.g., `plugins/MyPlugin/`). Never hardcode a path relative to the server root — `getDataFolder()` gives you the correct location regardless of where the server is installed.
