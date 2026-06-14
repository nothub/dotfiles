# Paper Plugin Development

Paper is a high-performance Minecraft server fork. Plugins run server-side only.

Docs: https://docs.papermc.io/paper/dev

## Gradle setup

```groovy
// build.gradle
plugins {
    id 'java'
    id 'io.papermc.paperweight.userdev' version '<latest>'
}

repositories {
    maven { url 'https://repo.papermc.io/repository/maven-public/' }
}

dependencies {
    paperweight.paperDevBundle('<mc-version>-R0.1-SNAPSHOT')
}

assemble.dependsOn reobfJar
```

The `paperDevBundle` version is `<mc-version>-R0.1-SNAPSHOT`. For MC 26.1.2, use `26.1.2-R0.1-SNAPSHOT`.

Find the latest Paperweight version at: https://plugins.gradle.org/plugin/io.papermc.paperweight.userdev

## Plugin metadata: paper-plugin.yml

`paper-plugin.yml` is the modern format (prefer it over `plugin.yml` for new projects).

```yaml
name: MyPlugin
version: "1.0.0"
main: com.example.myplugin.MyPlugin
api-version: "1.21"
description: "What the plugin does"
authors:
  - YourName
dependencies:
  server:
    # example optional dep
    LuckPerms:
      load: BEFORE
      required: false
      join-classpath: false
```

`api-version` should match the major MC version (e.g. `"1.21"` for 26.x).

## Entry point

```java
package com.example.myplugin;

import org.bukkit.plugin.java.JavaPlugin;

public class MyPlugin extends JavaPlugin {

    @Override
    public void onEnable() {
        getLogger().info("Plugin enabled");
    }

    @Override
    public void onDisable() {
        getLogger().info("Plugin disabled");
    }
}
```

## Event listeners

Register a listener in `onEnable`, then annotate handlers with `@EventHandler`:

```java
import org.bukkit.event.EventHandler;
import org.bukkit.event.Listener;
import org.bukkit.event.player.PlayerJoinEvent;

public class JoinListener implements Listener {

    @EventHandler
    public void onPlayerJoin(PlayerJoinEvent event) {
        event.getPlayer().sendMessage("Welcome!");
    }
}
```

```java
// in onEnable:
getServer().getPluginManager().registerEvents(new JoinListener(), this);
```

Use `@EventHandler(priority = EventPriority.HIGH)` when ordering relative to other plugins matters.

## Commands (Paper Command API)

Paper's modern command API uses `LifecycleEventManager` and `Commands`:

```java
import io.papermc.paper.command.brigadier.Commands;
import io.papermc.paper.plugin.lifecycle.event.types.LifecycleEvents;

// in onEnable:
getLifecycleManager().registerEventHandler(LifecycleEvents.COMMANDS, event -> {
    Commands commands = event.registrar();
    commands.register(
        Commands.literal("hello")
            .executes(ctx -> {
                ctx.getSource().getSender().sendMessage("Hello!");
                return com.mojang.brigadier.Command.SINGLE_SUCCESS;
            })
            .build()
    );
});
```

Declare commands in `paper-plugin.yml` under `commands:` for tab-completion registration (optional with the new API but still useful for documentation).

## Scheduler

```java
// run once after 20 ticks (1 second), sync:
getServer().getScheduler().runTaskLater(this, () -> {
    // runs on main thread
}, 20L);

// repeating async task:
getServer().getScheduler().runTaskTimerAsynchronously(this, () -> {
    // runs off main thread — don't touch world state here
}, 0L, 200L); // start immediately, repeat every 10s
```

Paper also exposes the Folia-compatible `RegionScheduler` / `AsyncScheduler` on newer versions.

## Persistent Data Container (PDC)

Store custom data on any `PersistentDataHolder` (entities, blocks, items):

```java
import org.bukkit.NamespacedKey;
import org.bukkit.persistence.PersistentDataType;

NamespacedKey key = new NamespacedKey(this, "my_value");
entity.getPersistentDataContainer().set(key, PersistentDataType.INTEGER, 42);
int val = entity.getPersistentDataContainer()
    .getOrDefault(key, PersistentDataType.INTEGER, 0);
```

## Key packages

| Package | Contents |
|---------|----------|
| `org.bukkit` | Core Bukkit API (Server, World, Entity, ItemStack, …) |
| `org.bukkit.event.*` | Event types and listener infrastructure |
| `org.bukkit.command` | Legacy command API |
| `io.papermc.paper.*` | Paper extensions (Component API, command brigadier, …) |
| `net.kyori.adventure.*` | Text components and messaging |

## Tips

- Use `net.kyori.adventure.text.Component` for all player-facing text, not legacy color codes.
- Plugin data files go in `getDataFolder()` — it's already created for you.
- `getConfig()` auto-loads `config.yml` from the jar's resources. Call `saveDefaultConfig()` in `onEnable` to extract it on first run.
