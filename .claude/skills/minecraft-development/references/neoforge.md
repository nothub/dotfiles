# NeoForged Mod Development

NeoForge is the successor to MinecraftForge. Mods can target client, server, or both.

Docs: https://docs.neoforged.net/

## Gradle setup

Use ModDevGradle (MDG) — the current recommended build plugin:

```groovy
// build.gradle
plugins {
    id 'java'
    id 'net.neoforged.moddev' version '<latest>'
}

neoForge {
    version = '<neoforge-version>'

    runs {
        client { client() }
        server {
            server()
            programArgument '--nogui'
        }
    }

    mods {
        mymod {
            sourceSet sourceSets.main
        }
    }
}
```

Find the latest MDG version at: https://projects.neoforged.net/neoforged/moddevgradle

Find the NeoForge version for your MC version at: https://projects.neoforged.net/neoforged/neoforge

NeoForge uses its own version number (not the MC version directly). The NeoForge version for MC 26.1.2 follows the pattern `26.1.x` — check the project page for the latest.

## Mod metadata: neoforge.mods.toml

Place at `src/main/resources/META-INF/neoforge.mods.toml`:

```toml
modLoader = "javafml"
loaderVersion = "[4,)"
license = "MIT"

[[mods]]
    modId = "mymod"
    version = "${file.jarVersion}"
    displayName = "My Mod"
    description = "What the mod does"

[[dependencies.mymod]]
    modId = "neoforge"
    type = "required"
    versionRange = "[21.5,)"
    ordering = "NONE"
    side = "BOTH"

[[dependencies.mymod]]
    modId = "minecraft"
    type = "required"
    versionRange = "[26.1.2,)"
    ordering = "NONE"
    side = "BOTH"
```

The `${file.jarVersion}` placeholder reads from the jar's `MANIFEST.MF`, populated by Gradle. Also add `Implementation-Version` to your jar manifest in `build.gradle`:

```groovy
jar {
    manifest {
        attributes 'Implementation-Version': project.version
    }
}
```

## Entry point

```java
package com.example.mymod;

import net.neoforged.bus.api.IEventBus;
import net.neoforged.fml.common.Mod;

@Mod("mymod")
public class MyMod {

    public static final String MOD_ID = "mymod";

    public MyMod(IEventBus modEventBus) {
        // register deferred registers, event subscribers, etc.
        ModBlocks.BLOCKS.register(modEventBus);
        ModItems.ITEMS.register(modEventBus);

        // for game events (not mod lifecycle), register on NeoForge event bus:
        NeoForge.EVENT_BUS.register(this);
    }
}
```

## Two event buses

NeoForge has two buses — pick the right one:

| Bus | Access | Used for |
|-----|--------|----------|
| **Mod event bus** | `IEventBus modEventBus` (constructor param) | Mod lifecycle: `FMLCommonSetupEvent`, registry events, `RegisterCapabilitiesEvent` |
| **NeoForge event bus** | `NeoForge.EVENT_BUS` | Game events: `PlayerEvent`, `LivingDeathEvent`, `BlockEvent`, tick events |

```java
// on the NeoForge bus — subscribe with @SubscribeEvent:
@SubscribeEvent
public void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
    event.getEntity().sendSystemMessage(
        Component.literal("Welcome!")
    );
}
```

Or use the static annotation approach:
```java
@Mod.EventBusSubscriber(modid = MyMod.MOD_ID, bus = Mod.EventBusSubscriber.Bus.GAME)
public class GameEvents {

    @SubscribeEvent
    public static void onPlayerJoin(PlayerEvent.PlayerLoggedInEvent event) {
        // ...
    }
}
```

## Registries with DeferredRegister

NeoForge defers registration to avoid ordering issues:

```java
import net.neoforged.neoforge.registries.DeferredRegister;
import net.minecraft.core.registries.BuiltInRegistries;
import net.minecraft.world.level.block.Block;
import net.minecraft.world.level.block.state.BlockBehaviour;

public class ModBlocks {

    public static final DeferredRegister<Block> BLOCKS =
        DeferredRegister.create(BuiltInRegistries.BLOCK, MyMod.MOD_ID);

    public static final Supplier<Block> MY_BLOCK = BLOCKS.register(
        "my_block",
        () -> new Block(BlockBehaviour.Properties.of())
    );
}
```

Register each `DeferredRegister` on the mod event bus in the `@Mod` constructor:
```java
ModBlocks.BLOCKS.register(modEventBus);
```

## Sided code

Use `@EventBusSubscriber(Dist.CLIENT)` or check `FMLEnvironment.dist` at runtime to gate client-only code:

```java
@Mod.EventBusSubscriber(modid = MyMod.MOD_ID, bus = Mod.EventBusSubscriber.Bus.MOD, value = Dist.CLIENT)
public class ClientEvents {

    @SubscribeEvent
    public static void onClientSetup(FMLClientSetupEvent event) {
        // client-only setup
    }
}
```

## Access Transformers

When you need to access a private/protected field or method in vanilla, add an AT instead of a mixin:

`src/main/resources/META-INF/accesstransformer.cfg`:
```
public net.minecraft.world.entity.LivingEntity f_20942_ # lastHurt
```

Declare the AT file in `neoforge.mods.toml`:
```toml
[[accessTransformers]]
    file = "META-INF/accesstransformer.cfg"
```

Or in `build.gradle` via MDG:
```groovy
neoForge {
    accessTransformers.add 'src/main/resources/META-INF/accesstransformer.cfg'
}
```

## Capabilities

Capabilities attach arbitrary data/behavior to entities, block entities, or items without subclassing:

```java
// Register in RegisterCapabilitiesEvent (mod event bus):
@SubscribeEvent
public static void registerCapabilities(RegisterCapabilitiesEvent event) {
    event.registerEntity(
        MyCapability.class,
        EntityType.PLAYER,
        (player, side) -> new MyCapabilityImpl(player)
    );
}

// Access:
player.getCapability(MyCapability.class).ifPresent(cap -> {
    cap.doSomething();
});
```

## Key packages

| Package | Contents |
|---------|----------|
| `net.neoforged.fml.*` | FML lifecycle, mod loading |
| `net.neoforged.neoforge.event.*` | Game events (player, world, entity, …) |
| `net.neoforged.neoforge.registries.*` | DeferredRegister, registry helpers |
| `net.neoforged.neoforge.capabilities.*` | Capability system |
| `net.minecraft.*` | Vanilla classes |
| `net.neoforged.bus.api.*` | Event bus infrastructure |

## Tips

- Forgetting which bus to use is the #1 NeoForge mistake. Mod lifecycle events → mod bus. Game events → NeoForge bus.
- `DeferredRegister` suppliers are lazy — don't call `.get()` during mod constructor; wait until after registry events fire.
- Use `toRun*` task variants (`./gradlew runServer`) for testing; the MDG sets up the necessary run directories automatically.
- SRG/official mappings: NeoForge uses official Mojang mappings by default. Field names in AT files use SRG names (e.g., `f_12345_`). Check them at https://mcsr.rs/ or with the `./gradlew createMcpToSrg` task.
