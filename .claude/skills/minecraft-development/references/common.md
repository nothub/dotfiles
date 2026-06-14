# Common Minecraft Conventions

Conventions shared across Paper, Fabric, and NeoForge.

## Identifiers (resource locations)

All Minecraft content is identified by a `namespace:path` string. Your mod's namespace is your mod ID.

```
minecraft:stone          ← vanilla
mymod:my_block           ← your mod
```

Creating one in each framework:

```java
// Paper
NamespacedKey key = new NamespacedKey("mymod", "my_value");

// Fabric
Identifier id = Identifier.of("mymod", "my_block");

// NeoForge
ResourceLocation id = ResourceLocation.fromNamespaceAndPath("mymod", "my_block");
```

The identifier maps directly to file paths for assets and data (see below).

## Asset directory structure

Assets are client-side (textures, models, sounds, lang). Root: `src/main/resources/assets/<namespace>/`

```
assets/mymod/
├── blockstates/
│   └── my_block.json
├── lang/
│   └── en_us.json
├── models/
│   ├── block/
│   │   └── my_block.json
│   └── item/
│       └── my_block.json
├── sounds/
│   └── my_sound.ogg
└── textures/
    ├── block/
    │   └── my_block.png
    └── item/
        └── my_block.png
```

## Data directory structure

Data is server-side (recipes, loot tables, tags). Root: `src/main/resources/data/<namespace>/`

```
data/mymod/
├── recipe/
│   └── my_block.json
└── loot_table/
    └── blocks/
        └── my_block.json

data/minecraft/
└── tags/
    └── block/
        └── mineable/
            └── pickaxe.json     ← add your block to vanilla tags here
```

## Lang file

`assets/mymod/lang/en_us.json`:

```json
{
  "block.mymod.my_block": "My Block",
  "item.mymod.my_item": "My Item",
  "itemGroup.mymod.my_tab": "My Mod"
}
```

Translation keys follow these patterns:
- Blocks: `block.<namespace>.<path>`
- Items: `item.<namespace>.<path>`
- Creative tabs: `itemGroup.<namespace>.<name>`
- Custom: `<namespace>.<anything>`

## Block model

`assets/mymod/models/block/my_block.json` — simple full cube using a single texture:

```json
{
  "parent": "minecraft:block/cube_all",
  "textures": {
    "all": "mymod:block/my_block"
  }
}
```

Common parents:
- `minecraft:block/cube_all` — same texture on all 6 faces
- `minecraft:block/cube_column` — top/bottom vs sides (logs)
- `minecraft:block/cross` — transparent plant-style (flowers)
- `minecraft:block/orientable` — front face differs (furnace-style)

## Block state file

`assets/mymod/blockstates/my_block.json` — single-state block (no variants):

```json
{
  "variants": {
    "": { "model": "mymod:block/my_block" }
  }
}
```

With facing variants (e.g. a block that rotates):

```json
{
  "variants": {
    "facing=north": { "model": "mymod:block/my_block" },
    "facing=south": { "model": "mymod:block/my_block", "y": 180 },
    "facing=west":  { "model": "mymod:block/my_block", "y": 270 },
    "facing=east":  { "model": "mymod:block/my_block", "y": 90  }
  }
}
```

## Item model

For a block item, the item model just references the block model:

`assets/mymod/models/item/my_block.json`:

```json
{
  "parent": "mymod:block/my_block"
}
```

For a flat item (no 3D model):

```json
{
  "parent": "minecraft:item/generated",
  "textures": {
    "layer0": "mymod:item/my_item"
  }
}
```

## Recipe

`data/mymod/recipe/my_block.json` — shaped crafting:

```json
{
  "type": "minecraft:crafting_shaped",
  "pattern": [
    "###",
    "# #",
    "###"
  ],
  "key": {
    "#": { "item": "minecraft:stone" }
  },
  "result": {
    "id": "mymod:my_block",
    "count": 1
  }
}
```

Shapeless crafting:

```json
{
  "type": "minecraft:crafting_shapeless",
  "ingredients": [
    { "item": "minecraft:stone" },
    { "item": "minecraft:dirt" }
  ],
  "result": {
    "id": "mymod:my_block",
    "count": 1
  }
}
```

## Loot table

`data/mymod/loot_table/blocks/my_block.json` — drop the block itself when mined:

```json
{
  "type": "minecraft:block",
  "pools": [
    {
      "rolls": 1,
      "entries": [
        {
          "type": "minecraft:item",
          "name": "mymod:my_block"
        }
      ],
      "conditions": [
        {
          "condition": "minecraft:survives_explosion"
        }
      ]
    }
  ]
}
```

## Tags

Add your block to an existing vanilla tag by creating a file under `data/minecraft/tags/`:

`data/minecraft/tags/block/mineable/pickaxe.json`:

```json
{
  "replace": false,
  "values": [
    "mymod:my_block"
  ]
}
```

`"replace": false` merges with the existing tag instead of replacing it.

Common block tags:
- `minecraft:tags/block/mineable/pickaxe` — breakable with pickaxe
- `minecraft:tags/block/mineable/axe` — breakable with axe
- `minecraft:tags/block/mineable/shovel` — breakable with shovel
- `minecraft:tags/block/needs_stone_tool` — requires stone+ tool
- `minecraft:tags/block/needs_iron_tool` — requires iron+ tool
