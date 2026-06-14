# Paper Server Configuration

Paper layers config across several files. Understanding the hierarchy matters when plugin behavior
is being overridden by a server setting, or when you need to advise a server admin on correct setup.

## Config file hierarchy

```
<server-root>/
├── server.properties ← vanilla settings
├── bukkit.yml        ← spawn limits, chunk GC, connection throttle
├── spigot.yml        ← entity AI, item merging, hopper perf
├── commands.yml      ← command aliases, vanilla command overrides
├── permissions.yml   ← static permission metadata (not a perm plugin)
└── config/
    ├── paper-global.yml         ← Paper-wide: proxies, IO, anticheat, watchdog
    ├── paper-world-defaults.yml ← per-world defaults
    └── paper-world/
        └── <worldname>/
            └── paper-world.yml  ← per-world overrides (inherits world-defaults)
```

Keys absent from a per-world file fall through to `paper-world-defaults.yml`.

---

## server.properties

Defaults that commonly need changing:

```properties
# Required for offline-mode servers, proxies, or players without enforced chat signing
enforce-secure-profile=false     # default: true

# Required when running behind BungeeCord or Velocity
online-mode=false                # default: true

# Default 16 protects a 33×33 block square around spawn; classic SMP usually sets 0
spawn-protection=0               # default: 16

# Private servers
white-list=true                  # default: false
enforce-whitelist=true           # default: false — also kicks unlisted online players on reload

# Most SMPs run normal or hard; easy is the default
difficulty=normal                # default: easy

# Reduce for performance (6–8), raise for quality (12–16); affects client render distance cap
view-distance=10                 # default: 10

# Entity AI and block ticking distance — can be lower than view-distance for performance
simulation-distance=6            # default: 10

# Kick idle players on public servers, do not kick idlers on private servers; 0 disables
player-idle-timeout=60           # default: 0

# GDPR / privacy — disable IP logging if required
log-ips=false                    # default: true
```

Other notable properties:

```properties
motd=A Minecraft Server          # displayed in server list
level-seed=                      # set before first start for specific world gen
max-players=20

# LZ4 is faster than deflate with similar ratios — worth switching on new installs
region-file-compression=lz4      # default: deflate

# Pause server after this many seconds empty; saves CPU on small private servers
pause-when-empty-seconds=60      # default: -1 (disabled)

# Protects against neighbor-update lag machines; default is fine for most servers
max-chained-neighbor-updates=1000000
```

---

## paper-global.yml (`config/paper-global.yml`)

```yaml
proxies:
  velocity:
    enabled: true          # required when behind Velocity
    online-mode: true
    secret: ""             # must match velocity.toml forwarding-secret
  bungee-cord:
    online-mode: true      # set false only if BungeeCord handles auth itself

# Reduces how aggressively the server adjusts send distance; leave true for auto-tuning
chunk-loading-basic:
  autoconfig-send-distance: true

# Reduce tab-spam limits if legitimate plugins (chests, inventories) are triggering kicks
spam-limiter:
  tab-spam-increment: 1
  tab-spam-limit: 500

# Customize for offline/proxy servers where Mojang auth is not used
messages:
  kick:
    authentication-servers-down: "<red>Could not connect to authentication servers."

# Spark is preferred over timings; disable to reduce overhead
timings:
  enabled: false           # default: true

watchdog:
  early-warning-delay: 10000    # ms before first hang warning
  early-warning-every: 5000     # ms between repeated warnings
```

---

## paper-world-defaults.yml (`config/paper-world-defaults.yml`)

```yaml
misc:
  # ALTERNATE_CURRENT is much more performant than vanilla with minor behavior differences.
  # EIGENCRAFT is also faster than VANILLA with closer vanilla parity.
  redstone-implementation: ALTERNATE_CURRENT   # default: VANILLA

  # Skip the end credits screen after the Ender Dragon dies — common on SMP
  disable-end-credits: true                    # default: false

environment:
  # Applies void damage above y=128 in the nether — blocks nether roof exploitation
  nether-ceiling-void-damage-height: 128       # default: 0 (disabled)

entities:
  spawning:
    # Each player gets their own mob cap pool — fairer on multiplayer servers
    per-player-mob-spawns: true                # default: true in Paper

    # Override bukkit.yml caps per-world; -1 = use bukkit.yml value
    spawn-limits:
      monster: 70
      animal: 10
      water-creature: 5
      water-ambient: 20
      axolotl: 5

    despawn-ranges:
      monster:
        hard: 128
        soft: 32

  behavior:
    # Spawner-created mobs have no AI — large performance win near mob farms
    # set to true globally here or per-world in paper-world.yml
    nerf-spawner-mobs: false                   # default: false

anticheat:
  anti-xray:
    enabled: false                 # default: false — enable to block X-ray clients
    engine-mode: HIDE              # HIDE (mode 1, fast), OBFUSCATE (mode 2, effective),
                                   # OBFUSCATE_LAYER (mode 3, most effective, highest cost)
    # mode 2/3 send fake blocks to clients; significant bandwidth and CPU cost

lootables:
  # Refills containers (chests, barrels) on a schedule — useful for RPG/adventure servers
  auto-replenish: false            # default: false

chunks:
  auto-save-interval: -1           # -1 = use bukkit.yml; set per-world to override
```

---

## bukkit.yml

```yaml
settings:
  # Milliseconds between connections from the same IP; set 0 when behind a proxy
  connection-throttle: 4000        # default: 4000

  # Shutdown message shown to players when the server stops
  shutdown-message: Server closed.

# Global mob caps — paper-world-defaults.yml can override per-world
spawn-limits:
  monsters: 70
  animals: 10
  water-animals: 5
  water-ambient: 20
  axolotls: 5
  ambient: 15

# How often spawning runs, in ticks. Increase to reduce spawn lag on busy servers.
ticks-per:
  animal-spawns: 400               # default: 400 (every 20s)
  monster-spawns: 1                # default: 1 (every tick)
  water-spawns: 1
  ambient-spawns: 1
```

---

## spigot.yml

```yaml
settings:
  # Script called on /restart; set for your OS
  restart-script: ./start.sh      # default: ./start.sh

world-settings:
  default:
    # Entities outside this range (blocks) get reduced AI — core performance knob
    entity-activation-range:
      animals: 32
      monsters: 32
      misc: 16
      water: 16                   # default: 16
      tick-inactive-villagers: true

    # Merge nearby items and XP orbs — increase slightly for performance
    merge-radius:
      item: 2.5
      exp: 3.0

    # Hard cap on TNT explosions per tick — protects against lag bombs
    max-tnt-per-tick: 20          # default: 100

    # Ticks before dropped items despawn (default 6000 = 5 minutes)
    item-despawn-rate: 6000

    # Massive hopper performance improvement; disables InventoryMoveItemEvent
    # only set true if no plugins depend on that event
    hopper:
      disable-move-event: true   # default: false
```

---

## Per-world overrides

Create `config/paper-world/<worldname>/paper-world.yml` with only the keys that differ from `paper-world-defaults.yml`. Example — tighter mob cap in the nether:

```yaml
entities:
  spawning:
    spawn-limits:
      monster: 30
```

---

## Reading server settings from plugin code

Paper does not expose most of its config as a stable public API. Use Bukkit/Paper API methods:

```java
// spawn limits (respects paper-world-defaults.yml overrides)
int monsterLimit = world.getSpawnLimit(SpawnCategory.MONSTER);

// view and simulation distance
int viewDist = Bukkit.getViewDistance();
int simDist  = Bukkit.getSimulationDistance();

// online-mode
boolean onlineMode = Bukkit.getOnlineMode();

// difficulty
Difficulty diff = world.getDifficulty();
```

Do not read `paper-global.yml` or `paper-world-defaults.yml` directly from plugin code — their internal structure changes between Paper versions.

---

## Plugin config vs server config

Plugin config lives in `getDataFolder()` and is entirely separate from the server config files above.

```java
// extract config.yml from jar resources on first run:
saveDefaultConfig();

// read with fallback:
int maxFoo = getConfig().getInt("max-foo", 10);

// write and persist:
getConfig().set("some-key", value);
saveConfig();
```

`getDataFolder()` returns the plugin's own directory (e.g., `plugins/MyPlugin/`). Never hardcode paths relative to the server root.
