# Fabric Mod Development

Fabric is a lightweight modding toolchain for Minecraft. Mods can target client, server, or both.

Docs: https://docs.fabricmc.net/develop/

## Gradle setup

```groovy
// settings.gradle
pluginManagement {
    repositories {
        maven {
            name = 'Fabric'
            url = 'https://maven.fabricmc.net/'
        }
        gradlePluginPortal()
    }
}
```

```properties
# gradle.properties

# Java
java_version=25

# Gradle
org.gradle.jvmargs=-Xmx2G

# Mod
mod_version=1.0.0
maven_group=com.example
archives_base_name=mymod

# Fabric — check current versions at https://fabricmc.net/develop
minecraft_version=26.1.2
yarn_mappings_version=26.1.2+build.1
fabric_loader_version=0.18.3
fabric_api_version=0.140.2+26.1.2
```

```groovy
// build.gradle
plugins {
    id 'fabric-loom' version '<latest>'
}

version = project.mod_version
group = project.maven_group

java {
    toolchain.languageVersion = JavaLanguageVersion.of(project.java_version)
    archivesBaseName = project.archives_base_name
}
tasks.withType(JavaCompile).configureEach {
    it.sourceCompatibility = it.targetCompatibility = JavaVersion.toVersion(project.java_version)
    it.options.release = Integer.valueOf(project.java_version)
    it.options.encoding = 'UTF-8'
}

dependencies {
    minecraft "com.mojang:minecraft:${project.minecraft_version}"
    mappings "net.fabricmc:yarn:${project.yarn_mappings_version}:v2"
    modImplementation "net.fabricmc:fabric-loader:${project.fabric_loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${project.fabric_api_version}"
}

processResources {
    filteringCharset 'UTF-8'
    filesMatching('fabric.mod.json') {
        filter { line -> line.replace('@mod_version@', project.version) }
        filter { line -> line.replace('@minecraft_version@', minecraft_version) }
        filter { line -> line.replace('@fabric_loader_version@', fabric_loader_version) }
        filter { line -> line.replace('@fabric_api_version@', fabric_api_version) }
    }
}

jar {
    from('LICENSE.txt')
}

remapJar.archiveFileName.set("${project.archives_base_name}-${project.version}+${project.minecraft_version}-fabric.jar")
remapJar.destinationDirectory.set(layout.buildDirectory.dir('dist'))

clean {
    delete "${rootDir}/remappedSrc"
    delete "${rootDir}/run"
}
```

Find the latest Loom version at: https://maven.fabricmc.net/net/fabricmc/fabric-loom/

## Mod metadata: fabric.mod.json

Place at `src/main/resources/fabric.mod.json`. The `@placeholder@` tokens are substituted by `processResources` at build time.

```json
{
  "schemaVersion": 1,
  "id": "mymod",
  "version": "@mod_version@",
  "name": "My Mod",
  "description": "What the mod does",
  "authors": ["YourName"],
  "license": "MIT",
  "environment": "*",
  "entrypoints": {
    "main": ["com.example.mymod.Mod"],
    "client": ["com.example.mymod.client.ModClient"]
  },
  "mixins": ["mymod.mixins.json"],
  "depends": {
    "fabricloader": ">=@fabric_loader_version@",
    "minecraft": "@minecraft_version@",
    "fabric": ">=@fabric_api_version@"
  }
}
```

`environment`: `"*"` = both sides, `"client"` = client only, `"server"` = server only.

Entrypoints listed under `"main"` initialize on both sides; `"client"` runs on client only. Declaring an entrypoint category with an empty array is valid.

**Optional fields** (omit if unused):
- `"icon": "icon.png"` — path to the mod icon; can also be a map of pixel widths to paths
- `"contact": {"homepage": "https://...", "issues": "https://..."}` — standard keys: `email`, `homepage`, `irc`, `issues`, `sources`
- `"java": ">=25"` in `depends` — explicit Java version constraint; useful if you use newer Java features
- `"provides": ["alias-id"]` — mod IDs this mod satisfies as a dependency

For the `mixins` field format and the mixins.json schema, see `references/mixins.md`.

## Entry points

```java
package com.example.mymod;

import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Mod implements ModInitializer {

    public static final String MOD_ID = "mymod";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("Mod initialized");
    }
}
```

Client-side entry point implements `ClientModInitializer` instead.

## Events

Fabric events are static instances — subscribe by calling `register`:

```java
import net.fabricmc.fabric.api.event.lifecycle.v1.ServerLifecycleEvents;
import net.fabricmc.fabric.api.event.player.UseBlockCallback;
import net.minecraft.util.ActionResult;

// in onInitialize:
ServerLifecycleEvents.SERVER_STARTED.register(server -> {
    LOGGER.info("Server started");
});

UseBlockCallback.EVENT.register((player, world, hand, hitResult) -> {
    // return PASS to let other handlers run
    return ActionResult.PASS;
});
```

Common event classes live in `net.fabricmc.fabric.api.event.*`.

Client-side tick events — subscribe in a `ClientModInitializer`:

```java
import net.fabricmc.fabric.api.client.event.lifecycle.v1.ClientTickEvents;
import net.minecraft.client.gui.screen.TitleScreen;

// in onInitialize (ClientModInitializer):
ClientTickEvents.END_CLIENT_TICK.register(client -> {
    if (!(client.currentScreen instanceof TitleScreen)) return;
    // runs after every client tick while on the title screen
});
```

`END_CLIENT_TICK` fires after the client has ticked. `START_CLIENT_TICK` fires before.

## Registries

Register blocks, items, etc. in `onInitialize` using `Registry.register`:

```java
import net.minecraft.block.AbstractBlock;
import net.minecraft.block.Block;
import net.minecraft.item.BlockItem;
import net.minecraft.item.Item;
import net.minecraft.registry.Registries;
import net.minecraft.registry.Registry;
import net.minecraft.util.Identifier;

public class ModBlocks {

    public static final Block MY_BLOCK = Registry.register(
        Registries.BLOCK,
        Identifier.of(Mod.MOD_ID, "my_block"),
        new Block(AbstractBlock.Settings.create())
    );

    public static final Item MY_BLOCK_ITEM = Registry.register(
        Registries.ITEM,
        Identifier.of(Mod.MOD_ID, "my_block"),
        new BlockItem(MY_BLOCK, new Item.Settings())
    );

    // call this from onInitialize to trigger static init
    public static void initialize() {}
}
```

## Mixins

See `references/mixins.md` for the full mixins.json schema, annotation reference, and accessor pattern. The SpongePowered Mixin library works identically on Fabric and NeoForge.

Example `@Inject`:

```java
package com.example.mymod.mixin;

import net.minecraft.server.MinecraftServer;
import org.spongepowered.asm.mixin.Mixin;
import org.spongepowered.asm.mixin.injection.At;
import org.spongepowered.asm.mixin.injection.Inject;
import org.spongepowered.asm.mixin.injection.callback.CallbackInfo;

@Mixin(MinecraftServer.class)
public class ExampleMixin {

    @Inject(at = @At("HEAD"), method = "loadWorld")
    private void onLoadWorld(CallbackInfo info) {
        Mod.LOGGER.info("World loading...");
    }
}
```

## Key packages

| Package | Contents |
|---------|----------|
| `net.fabricmc.api` | Entrypoint interfaces |
| `net.fabricmc.fabric.api.*` | Fabric API (events, registries, networking, …) |
| `net.fabricmc.loader.api` | FabricLoader — mod detection, config dir, game dir |
| `net.minecraft.*` | Vanilla classes (remapped via Yarn mappings) |
| `org.spongepowered.asm.mixin` | Mixin annotations |

## Config

Fabric has no built-in config API. Options:
- Simple: write/read a JSON file in `FabricLoader.getInstance().getConfigDir()`.
- Library: Cloth Config (`me.shedaniel.cloth:cloth-config`) — only add this if the user explicitly wants a config screen.

## Tips

- Always develop with Fabric API as a dependency, not vanilla alone. It adds many stable hooks.
- Use `@Environment(EnvType.CLIENT)` on client-only classes to prevent them from loading on the server.
- Yarn mappings are specific to each MC build. After updating MC, you need a matching `yarn_mappings_version` — check https://fabricmc.net/versions.html.
- Run `./gradlew migrateMappings` when updating the Yarn version to auto-rename identifiers.
