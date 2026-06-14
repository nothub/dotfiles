# Fabric Mod Development

Fabric is a lightweight modding toolchain for Minecraft. Mods can target client, server, or both.

Docs: https://docs.fabricmc.net/develop/

## Gradle setup

```groovy
// build.gradle
plugins {
    id 'java'
    id 'fabric-loom' version '<latest>'
}

dependencies {
    minecraft "com.mojang:minecraft:${minecraft_version}"
    mappings "net.fabricmc:yarn:${yarn_mappings}:v2"
    modImplementation "net.fabricmc:fabric-loader:${loader_version}"
    modImplementation "net.fabricmc.fabric-api:fabric-api:${fabric_version}"
}
```

Pin all versions in `gradle.properties`:
```properties
minecraft_version=26.1.2
yarn_mappings=26.1.2+build.1
loader_version=0.16.0
fabric_version=0.100.0+26.1.2
```

Check current versions at:
- Yarn: https://fabricmc.net/versions.html
- Fabric Loader: https://maven.fabricmc.net/net/fabricmc/fabric-loader/
- Fabric API: https://modrinth.com/mod/fabric-api/versions

Find the latest Loom version at: https://maven.fabricmc.net/net/fabricmc/fabric-loom/

## Mod metadata: fabric.mod.json

Place at `src/main/resources/fabric.mod.json`:

```json
{
  "schemaVersion": 1,
  "id": "mymod",
  "version": "1.0.0",
  "name": "My Mod",
  "description": "What the mod does",
  "authors": ["YourName"],
  "license": "MIT",
  "environment": "*",
  "entrypoints": {
    "main": ["com.example.mymod.MyMod"],
    "client": ["com.example.mymod.client.MyModClient"]
  },
  "mixins": ["mymod.mixins.json"],
  "depends": {
    "fabricloader": ">=0.16.0",
    "minecraft": "~26.1.2",
    "java": ">=21",
    "fabric-api": "*"
  }
}
```

`environment`: `"*"` = both sides, `"client"` = client only, `"server"` = server only.

Entrypoints listed under `"main"` initialize on both sides; `"client"` runs on client only.

## Entry points

```java
package com.example.mymod;

import net.fabricmc.api.ModInitializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class MyMod implements ModInitializer {

    public static final String MOD_ID = "mymod";
    public static final Logger LOGGER = LoggerFactory.getLogger(MOD_ID);

    @Override
    public void onInitialize() {
        LOGGER.info("MyMod initialized");
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
        Identifier.of(MyMod.MOD_ID, "my_block"),
        new Block(AbstractBlock.Settings.create())
    );

    public static final Item MY_BLOCK_ITEM = Registry.register(
        Registries.ITEM,
        Identifier.of(MyMod.MOD_ID, "my_block"),
        new BlockItem(MY_BLOCK, new Item.Settings())
    );

    // call this from onInitialize to trigger static init
    public static void initialize() {}
}
```

## Mixins

Mixins patch vanilla classes at bytecode level. Use them when the Fabric API doesn't expose what you need.

`mymod.mixins.json` (in `src/main/resources`):
```json
{
  "required": true,
  "package": "com.example.mymod.mixin",
  "compatibilityLevel": "JAVA_21",
  "mixins": ["ExampleMixin"],
  "injectors": {
    "defaultRequire": 1
  }
}
```

Example mixin:
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
        MyMod.LOGGER.info("World loading...");
    }
}
```

Keep mixins minimal — prefer Fabric API events over mixins when possible. Mixins are harder to maintain across MC updates.

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
- Yarn mappings are specific to each MC build. After updating MC, you need a matching `yarn_mappings` value — check https://fabricmc.net/versions.html.
- Run `./gradlew migrateMappings` when updating the Yarn version to auto-rename identifiers.
