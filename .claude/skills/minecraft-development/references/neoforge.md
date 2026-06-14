# NeoForged Mod Development

NeoForge is the successor to MinecraftForge. Mods can target client, server, or both.

Docs: https://docs.neoforged.net/

## Gradle setup

```groovy
// settings.gradle
pluginManagement {
    repositories {
        gradlePluginPortal()
    }
}

plugins {
    id 'org.gradle.toolchains.foojay-resolver-convention' version '1.0.0'
}
```

```properties
# gradle.properties

# Gradle
org.gradle.jvmargs=-Xmx1G
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.configuration-cache=true

# Parchment mappings (better parameter names for vanilla methods)
parchment_minecraft_version=1.21.11
parchment_mappings_version=2025.12.20

# Minecraft / NeoForge
minecraft_version=1.21.11
minecraft_version_range=[1.21.11]
neo_version=21.11.36-beta
neo_version_range=[21.4.0,)
loader_version_range=[4,)

# Mod
mod_id=mymod
mod_name=My Mod
mod_license=MIT
mod_version=1.0.0
mod_group_id=com.example.mymod
mod_authors=YourName
mod_description=What the mod does
```

```groovy
// build.gradle
plugins {
    id 'java-library'
    id 'net.neoforged.moddev' version '<latest>'
    id 'idea'
}

tasks.named('wrapper', Wrapper).configure {
    distributionType = Wrapper.DistributionType.BIN
}

version = mod_version
group = mod_group_id

repositories {
    // add extra mod repositories here if needed
}

base {
    archivesName = mod_id
}

java.toolchain.languageVersion = JavaLanguageVersion.of(21)

neoForge {
    version = project.neo_version

    parchment {
        mappingsVersion = project.parchment_mappings_version
        minecraftVersion = project.parchment_minecraft_version
    }

    runs {
        client { client() }
        server {
            server()
            programArgument '--nogui'
        }
        data {
            clientData()
            programArguments.addAll '--mod', project.mod_id, '--all',
                '--output', file('src/generated/resources/').getAbsolutePath(),
                '--existing', file('src/main/resources/').getAbsolutePath()
        }
        configureEach {
            logLevel = org.slf4j.event.Level.DEBUG
        }
    }

    mods {
        "${mod_id}" {
            sourceSet(sourceSets.main)
        }
    }
}

// Include data-gen output in the final jar
sourceSets.main.resources { srcDir 'src/generated/resources' }

// localRuntime: optional runtime deps that don't become transitive dependencies
configurations {
    runtimeClasspath.extendsFrom localRuntime
}

tasks.withType(JavaCompile).configureEach {
    options.encoding = 'UTF-8'
}

idea {
    module {
        downloadSources = true
        downloadJavadoc = true
    }
}

// Expand gradle.properties values into the mods.toml template
var generateModMetadata = tasks.register("generateModMetadata", ProcessResources) {
    var replaceProperties = [
        minecraft_version      : minecraft_version,
        minecraft_version_range: minecraft_version_range,
        neo_version            : neo_version,
        neo_version_range      : neo_version_range,
        loader_version_range   : loader_version_range,
        mod_id                 : mod_id,
        mod_name               : mod_name,
        mod_license            : mod_license,
        mod_version            : mod_version,
        mod_authors            : mod_authors,
        mod_description        : mod_description
    ]
    inputs.properties replaceProperties
    expand replaceProperties
    from 'src/main/templates'
    into 'build/generated/sources/modMetadata'
}
sourceSets.main.resources.srcDir generateModMetadata
neoForge.ideSyncTask generateModMetadata

jar.archiveFileName.set("${project.name.toLowerCase()}-${project.version}+${project.minecraft_version}-neoforge.jar")
jar.destinationDirectory.set(layout.buildDirectory.dir('dist'))
```

Find the latest MDG version at: https://projects.neoforged.net/neoforged/moddevgradle

Find the NeoForge version for your MC version at: https://projects.neoforged.net/neoforged/neoforge

## Mod metadata: neoforge.mods.toml

The metadata file lives at `src/main/templates/META-INF/neoforge.mods.toml`. The `generateModMetadata` task expands `${variable}` placeholders using values from `gradle.properties`.

```toml
modLoader="javafml"
loaderVersion="${loader_version_range}"
license="${mod_license}"
#issueTrackerURL="https://..."  #optional

[[mods]]
    modId="${mod_id}"
    version="${mod_version}"
    displayName="${mod_name}"
    authors="${mod_authors}"
    logoFile="logo.png"           #optional — filename relative to jar root
    #displayURL="https://..."     #optional
    #updateJSONURL="https://..."  #optional
    description='''${mod_description}'''

#[[mixins]]
#    config="${mod_id}.mixins.json"

[[dependencies.${mod_id}]]
    modId="neoforge"
    type="required"
    versionRange="${neo_version_range}"
    ordering="AFTER"
    side="BOTH"

[[dependencies.${mod_id}]]
    modId="minecraft"
    type="required"
    versionRange="${minecraft_version_range}"
    ordering="AFTER"
    side="BOTH"
```

`side`: `"BOTH"`, `"CLIENT"`, or `"SERVER"` — use `"CLIENT"` for client-only mods.

`type`: `"required"`, `"optional"`, `"incompatible"`, or `"discouraged"`.

## Entry point

```java
package com.example.mymod;

import net.neoforged.bus.api.IEventBus;
import net.neoforged.fml.common.Mod;

@Mod("mymod")
public class Mod {

    public static final String MOD_ID = "mymod";

    public Mod(IEventBus modEventBus) {
        ModBlocks.BLOCKS.register(modEventBus);
        ModItems.ITEMS.register(modEventBus);

        // for game events (not mod lifecycle), register on the NeoForge event bus:
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
    event.getEntity().sendSystemMessage(Component.literal("Welcome!"));
}
```

Or use the static annotation approach:
```java
@Mod.EventBusSubscriber(modid = Mod.MOD_ID, bus = Mod.EventBusSubscriber.Bus.GAME)
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
        DeferredRegister.create(BuiltInRegistries.BLOCK, Mod.MOD_ID);

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

```java
@Mod.EventBusSubscriber(modid = Mod.MOD_ID, bus = Mod.EventBusSubscriber.Bus.MOD, value = Dist.CLIENT)
public class ClientEvents {

    @SubscribeEvent
    public static void onClientSetup(FMLClientSetupEvent event) {
        // client-only setup
        // enqueueWork defers to the main thread — needed for anything touching Minecraft.getInstance():
        event.enqueueWork(() -> {
            var mc = Minecraft.getInstance();
            // safe to call here
        });
    }
}
```

For a mod that runs on the client only (no server support at all), restrict at the `@Mod` level:

```java
@Mod(value = "mymod", dist = {Dist.CLIENT})
public class Main {
    public Main(IEventBus modEventBus) { ... }
}
```

## Key bindings

```java
import net.minecraft.client.KeyMapping;
import net.neoforged.neoforge.client.event.RegisterKeyMappingsEvent;
import org.lwjgl.glfw.GLFW;

private static final KeyMapping MY_KEY = new KeyMapping(
    "key.mymod.action",       // translation key
    GLFW.GLFW_KEY_R,          // default key (GLFW constant)
    KeyMapping.Category.MISC  // category shown in controls screen
);

// on the mod event bus:
@SubscribeEvent
public static void onRegisterKeyMappings(RegisterKeyMappingsEvent event) {
    event.register(MY_KEY);
}
```

Check if the key was pressed in a tick event (`PlayerTickEvent.Post` on `NeoForge.EVENT_BUS`):

```java
if (MY_KEY.consumeClick()) {
    // fires once per key press; consumeClick() clears the buffered state
}
```

## Access Transformers

When you need to access a private/protected field or method in vanilla, add an AT instead of a mixin:

`src/main/resources/META-INF/accesstransformer.cfg`:
```
public net.minecraft.world.entity.LivingEntity f_20942_ # lastHurt
```

Declare in `build.gradle` via MDG:
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
- `DeferredRegister` suppliers are lazy — don't call `.get()` during the mod constructor; wait until after registry events fire.
- SRG/official mappings: NeoForge uses official Mojang mappings by default. Field names in AT files use SRG names (e.g., `f_12345_`). Check them at https://mcsr.rs/.
