# Paper Plugin Development

Paper is a high-performance Minecraft server fork. Plugins run server-side only.

Docs: https://docs.papermc.io/paper/dev

## Gradle setup

```groovy
// settings.gradle
rootProject.name = 'MyPlugin'
```

```properties
# gradle.properties
java_version=25
plugin_version=1.0.0
minecraft_version=26.1.2
```

```groovy
// build.gradle
plugins {
    id 'java-library'
    id 'xyz.jpenilla.run-paper' version '<latest>'
}

group = 'com.example'
version = project.plugin_version

repositories {
    mavenCentral()
    maven {
        url = 'https://repo.papermc.io/repository/maven-public/'
        content {
            includeGroup 'com.mojang'
            includeGroup 'io.papermc.paper'
            includeGroup 'net.kyori'
            includeGroup 'net.md-5'
        }
    }
}

dependencies {
    compileOnly group: 'io.papermc.paper', name: 'paper-api', version: "${project.minecraft_version}.build.+"
}

java {
    toolchain.languageVersion = JavaLanguageVersion.of(project.java_version)
}
tasks.withType(JavaCompile).configureEach {
    it.options.release = Integer.parseInt(project.java_version)
    it.options.encoding = 'UTF-8'
}

tasks {
    runServer {
        minecraftVersion("${project.minecraft_version}")
        jvmArgs('-Dcom.mojang.eula.agree=true', '-DPaper.skipServerPropertiesComments=true')
    }
}

processResources {
    filteringCharset 'UTF-8'
    filesMatching('plugin.yml') {
        filter { line -> line.replace('@mod_version@', project.version) }
        filter { line -> line.replace('@minecraft_version@', minecraft_version) }
    }
}

jar.archiveFileName.set("${project.name.toLowerCase()}-${project.version}+${project.minecraft_version}-paper.jar")
jar.destinationDirectory.set(layout.buildDirectory.dir('dist'))
```

The `paper-api` version format is `${minecraft_version}.build.+` for MC 26.x. For older MC (1.x series), the format was `${minecraft_version}-R0.1-SNAPSHOT`.

Find the latest `run-paper` version at: https://plugins.gradle.org/plugin/xyz.jpenilla.run-paper

## Plugin metadata: plugin.yml

Place at `src/main/resources/plugin.yml`. The `@placeholder@` tokens are substituted by `processResources` at build time.

```yaml
name: 'MyPlugin'
version: '@mod_version@'
api-version: '@minecraft_version@'
main: 'com.example.myplugin.Plugin'
description: 'What the plugin does'
website: 'https://github.com/example/myplugin'
authors: [ 'YourName' ]
contributors: [ ]

commands:
  myplugin:
    description: 'Does the thing'
    usage: '/myplugin'
    aliases: [ 'mp' ]
    permission: myplugin.use

permissions:
  myplugin.use:
    default: true
```

`commands` and `permissions` are optional — omit both if the plugin has no commands.

`permissions.default`: `true` = all players, `false` = nobody, `op` = ops only.

`paper-plugin.yml` is experimental — use `plugin.yml` for now.

## Entry point

The main class is conventionally named `Plugin`:

```java
package com.example.myplugin;

import org.bukkit.plugin.java.JavaPlugin;

public class Plugin extends JavaPlugin {

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

Separate listener class:

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

// in onEnable:
getServer().getPluginManager().registerEvents(new JoinListener(), this);
```

Self-registration — the plugin class itself is the listener:

```java
public final class Plugin extends JavaPlugin implements Listener {

    @Override
    public void onEnable() {
        getServer().getPluginManager().registerEvents(this, this);
    }

    @EventHandler(ignoreCancelled = true)
    public void onPlayerJoin(PlayerJoinEvent event) {
        // ignoreCancelled = true skips events already cancelled by another plugin
    }
}
```

`PlayerInteractEvent` fires twice — once per hand. Guard with:
```java
if (ev.getHand() != EquipmentSlot.HAND) return;
```

Use `@EventHandler(priority = EventPriority.HIGH)` when ordering relative to other plugins matters.

## Adventure text API

Paper uses [Adventure](https://docs.advntr.dev/) for all player-facing text:

```java
import static net.kyori.adventure.text.Component.text;
import static net.kyori.adventure.text.format.NamedTextColor.GREEN;
import static net.kyori.adventure.text.format.NamedTextColor.RED;

player.sendMessage(text("Status: ").append(text("active").color(GREEN)));
```

Never use legacy color codes (`§a`, `ChatColor`). `Component` is the only correct type for messages.

## Commands (Paper Command API)

Paper's modern command API uses `LifecycleEventManager` and Brigadier:

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

Programmatic wiring with a lambda (alternative to Brigadier — works for simple commands):

```java
// in onEnable:
PluginCommand cmd = getCommand("mycommand"); // must also be declared in plugin.yml
cmd.setExecutor((sender, command, label, args) -> {
    if (!(sender instanceof Player player)) {
        sender.sendMessage("Players only.");
        return true;
    }
    // ...
    return true;
});
cmd.setTabCompleter((sender, command, label, args) -> Collections.emptyList());
```

## Block API

Navigate relative blocks:
```java
Block above = block.getRelative(BlockFace.UP);
Block neighbor = block.getRelative(1, 0, -1); // x, y, z offset
```

Block state predicates:
```java
block.isSolid()                 // solid, opaque block
block.isEmpty()                 // air or void
block.canPlace(blockData)       // blockData is valid to place here (respects shape constraints)
(int) block.getLightFromBlocks() // block light level 0–15 (from torches etc., not sky)
```

Compute loot drops respecting tool enchantments:
```java
for (ItemStack stack : block.getDrops(tool)) {
    block.getWorld().dropItemNaturally(block.getLocation(), stack);
}
```

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

Paper also exposes a Folia-compatible `RegionScheduler` / `AsyncScheduler` on newer versions.

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

## NMS access

When the plugin needs internal server classes (NMS), replace `paper-api` with `paperweight.userdev`:

```groovy
plugins {
    id 'io.papermc.paperweight.userdev' version '<latest>'
}

dependencies {
    paperweight.paperDevBundle("${project.minecraft_version}-R0.1-SNAPSHOT")
}

assemble.dependsOn reobfJar
```

This downloads the deobfuscated server jar and remaps the output back to production-obfuscated names on build. Do not use this unless NMS access is actually required — it significantly increases build complexity and breaks more often across MC updates.

Find the latest paperweight version at: https://plugins.gradle.org/plugin/io.papermc.paperweight.userdev

## Tips

- Use `net.kyori.adventure.text.Component` for all player-facing text, not legacy color codes.
- Plugin data files go in `getDataFolder()` — it is already created for you.
- `getConfig()` auto-loads `config.yml` from the jar's resources. Call `saveDefaultConfig()` in `onEnable` to extract it on first run.
