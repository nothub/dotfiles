# SpongePowered Mixin

Mixin patches vanilla classes at the bytecode level at load time. Fabric and NeoForge both use the same library.

Docs: https://docs.fabricmc.net/develop/misc/mixins

Use mixins when the framework's event/API system doesn't expose what you need. Prefer events — mixins break more often after MC updates.

## mixins.json

Place at `src/main/resources/<modid>.mixins.json`.

```json
{
  "required": true,
  "minVersion": "0.8",
  "package": "com.example.mymod.mixin",
  "compatibilityLevel": "JAVA_21",
  "mixins": [],
  "client": ["TitleScreenMixin"],
  "server": [],
  "injectors": {
    "defaultRequire": 1
  }
}
```

| Field | Notes |
|-------|-------|
| `required` | Crash the game if the mixin set fails to apply |
| `minVersion` | Minimum Mixin library version. Use `"0.8"`. |
| `package` | Parent package. All class names in the arrays are relative to this. |
| `compatibilityLevel` | Java version string. Match your build target (`"JAVA_21"`). |
| `mixins` | Apply on both physical client and dedicated server |
| `client` | Apply on physical client only |
| `server` | Apply on dedicated server only |
| `injectors.defaultRequire` | Targets each injector must match. `1` = fail loudly if no match, `0` = optional |

## Register in fabric.mod.json

String form — config loaded on both sides:
```json
"mixins": ["mymod.mixins.json"]
```

Object form — restrict when the entire config is loaded, independent of the `client`/`server` arrays inside it:
```json
"mixins": [
  "mymod.mixins.json",
  {
    "config": "mymod.client-mixins.json",
    "environment": "client"
  }
]
```

## Register in neoforge.mods.toml

Uncomment the `[[mixins]]` block in the mods.toml template and set `config` to the mixins.json filename:

```toml
[[mixins]]
    config="mymod.mixins.json"
```

The file must be on the classpath (place it in `src/main/resources/`). Add one `[[mixins]]` block per config file if you have separate client and common configs.

## Common annotations

| Annotation | Purpose |
|------------|---------|
| `@Mixin(Target.class)` | Declare the class being mixed into |
| `@Inject` | Insert code at a point in a method without removing existing bytecode |
| `@At("HEAD")` | Injection point: start of method |
| `@At("RETURN")` | Injection point: before each return statement |
| `@At(value="INVOKE", target="...")` | Before/after a specific method call |
| `@Shadow` | Reference a field or method that exists in the target class |
| `@Accessor` | Generate a getter/setter interface for a private field |
| `@Invoker` | Generate a public caller interface for a private method |
| `@Overwrite` | Replace a method entirely — avoid, breaks mod compatibility |

## @Inject: CallbackInfo vs CallbackInfoReturnable

For void methods, use `CallbackInfo`. For methods that return a value, use `CallbackInfoReturnable<T>`.

```java
// void method — cancel to skip the rest of the original method body:
@Inject(at = @At("HEAD"), method = "play", cancellable = true)
private void onPlay(SoundInstance sound, CallbackInfo ci) {
    if (shouldBlock(sound)) ci.cancel();
}

// method returning SoundSystem.PlayResult — cancel and override the return value:
@Inject(at = @At("HEAD"), method = "play", cancellable = true)
private void onPlayDirect(SoundInstance sound, CallbackInfoReturnable<SoundSystem.PlayResult> ci) {
    if (shouldBlock(sound)) {
        ci.setReturnValue(SoundSystem.PlayResult.NOT_STARTED);
        ci.cancel();
    }
}
```

`ci.cancel()` alone on a CIR returns `null`/`0`/`false`. Always call `setReturnValue` first.

## Disambiguating overloaded methods

When the target class has multiple methods with the same name, the `method` string in `@Inject` must include the full JVM descriptor to pick the right one:

```java
// selects the overload that takes SoundInstance and returns PlayResult:
@Inject(
    at = @At("HEAD"),
    method = "play(Lnet/minecraft/client/sound/SoundInstance;)Lnet/minecraft/client/sound/SoundSystem$PlayResult;",
    cancellable = true
)
private void injectPlay(SoundInstance sound, CallbackInfoReturnable<SoundSystem.PlayResult> ci) { ... }
```

Descriptor format: `methodName(Lpkg/ClassName;I[B)Lreturn/Type;` — `L...;` for objects, `I` int, `B` byte, `V` void. Nested classes use `$`, not `.`.

Use a tool like [Mixin Extras](https://github.com/LlamaLad7/MixinExtras) or read the decompiled class to find the exact signature.

## Accessor example

When you need to read or write a private field, define an accessor interface instead of using `@Shadow`:

```java
@Mixin(AbstractSoundInstance.class)
public interface AbstractSoundInstanceAccessor {

    @Accessor
    void setLocation(Identifier location);
}
```

Then cast the target instance to the interface:
```java
((AbstractSoundInstanceAccessor) soundInstance).setLocation(newId);
```

## Tips

- Client-only mixins go in `"client"`. Server-only in `"server"`. Both sides in `"mixins"`.
- Annotate client-only mixin classes with `@Environment(EnvType.CLIENT)` as well — belt-and-suspenders against server crashes.
- `defaultRequire: 1` makes failures loud. Only set to `0` for optional compatibility patches.
- Use `@Accessor`/`@Invoker` over `@Shadow` for accessing private members — they're safer to refactor.
