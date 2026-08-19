# HOLUF — Environment Production Pipeline (M65)

## 1. Current Environment Architecture Audit
- **Current Prototype:** Ground and world visuals in the existing prototype (`world.tscn`) are built using raw primitive nodes (`Polygon2D`) for paths, grass patches, and environment blocks.
- **Node Usage:** The prototype does NOT currently use `TileMap` or `TileMapLayer` nodes. Collision is handled manually via `CollisionShape2D` (e.g., `RectangleShape2D`, `CircleShape2D`) attached to `StaticBody2D` nodes (e.g., `NorthWestForest`).
- **Production Status:** There are no real production tilesets or final art assets currently in use. The existing map is a functional whitebox.
- **Technical Constraints:** The final production pipeline must migrate this primitive approach to a scalable Godot pixel-art grid system without breaking existing gameplay `Area2D` triggers. **Do not silently treat prototype primitives as final art architecture.**

## 2. Environment Asset Taxonomy
M61's taxonomy is operationalized as follows:

**BASE SURFACES**
- walkable ground, dirt, grass, sand, stone/paving, terrain variants, region-specific surface variants.

**PATHS**
- main route, secondary route, optional/secret route visual language, dangerous/broken route visual language.

**VERTICALITY**
- cliffs, ledges, walls, fences, stairs where appropriate. *(Note: M73/M74 own actual climbable/drop-down ledge mechanics. M65 only defines their ART REQUIREMENTS. Do NOT implement ledge gameplay.)*

**STRUCTURES**
- exterior walls, roofs, doors, windows, structural trims, ruins.

**FLORA**
- trees, shrubs, grass, crops, flowers, region-specific vegetation.

**GEOLOGY**
- rocks, boulders, pebbles, cliff materials.

**FUNCTIONAL PROPS**
- signs, crates, barrels, bridges, lamps, carts, market structures, fences, benches where appropriate.

**REGIONAL PROPS**
- culturally/location-specific decorative or functional objects.

**LANDMARKS**
- unique structures, Mirror Gate-related structures, major facility architecture, Spatial Core-related environment.

**WATER / LIQUID SURFACES**
- shoreline, ocean/coast, rivers if required, ponds if required, animated water requirements. *(Note: VFX-related environment assets are classified here. M205 owns final World VFX polish.)*

## 3. 32x32 Modular Grid Language
Production must respect the locked 32x32 grid established in M62.

- **Rule:** BASE TILE != OBJECT SIZE. The 32x32 rule means modular construction aligns to the world grid; it does NOT force every visual object into 32x32 bounds.
- A tree, building, or cliff can visually occupy multiple tiles.
- **Modular Size Examples:** `32x32`, `64x32`, `64x64`, `96x64`, `96x96`, etc. Do NOT invent arbitrary mandatory dimensions for every object. M62 is the ultimate authority.

## 4. Terrain Transition Standard
To maintain a sustainable solo/indie pixel-art workflow, HOLUF avoids requiring hundreds of complex edge/corner variants for every possible terrain combination (e.g., grass ↔ dirt, sand ↔ water, stone ↔ dirt).

- **Recommendation:** Use a **controlled hybrid** system. Use Godot's built-in terrain/autotile logic for primary, high-volume transitions (like grass to dirt), and rely on manual transition tiles or overlay props (like grass tufts, pebbles) to hide hard seams where creating a full autotile set is overkill. Do NOT invent Godot features.

## 5. Tileset / Atlas Strategy
To support multiple distinct regions (Elaris, Lorel, Alexandria, Mongreaux, Kamikoto, Aetherion) without creating one gigantic impossible-to-maintain global texture:

- **Recommendation:** Use **category-separated regional atlases**.
  - **GLOBAL REUSABLE ASSETS:** Neutral foundational textures (basic dirt, generic shadows, invisible technical principles).
  - **REGIONAL ASSETS:** Atlases grouped by region and category (e.g., `elaris_terrain`, `lorel_buildings`). Generic underlying logic may be reused, but regional identity must remain visually distinct. Do NOT encourage inappropriate cross-region palette swaps.
  - **UNIQUE LANDMARK ASSETS:** Dedicated small sheets for major, one-off structures.

## 6. Regional Environment Identity
These are art-direction / production tendencies derived from M61. Do NOT turn them into rigid cultural stereotypes or invent unsupported geography. Where canon is insufficient: **DEFERRED**.

- **ELARIS:** Isolated small island, coastal environment, small farms, simple wood/stone architecture, weathered materials, modest scale, muted coastal identity.
- **LOREL:** Warm/sunlit, trade-oriented, Mediterranean-inspired visual language, terracotta/stucco/coastal-commercial identity.
- **ALEXANDRIA:** Structured, heavy stone, metalwork, engineering/applied-magic identity.
- **MONGREAUX:** Broad plains / steppe, large open spaces, contrast with educated metropolitan areas.
- **KAMIKOTO:** Disciplined, mountain/bamboo/pine, crafted wood/traditional architecture, Mirror Gate heritage.
- **AETHERION:** **NOT A COUNTRY.** Hostile research/spatial-anomaly environment, cold functional facilities, ancient spatial ruins, no generic civilian town language.

## 7. Building Production Standard
Buildings at the 32x32 scale must be modular to avoid drawing every house from scratch, while preventing obvious copy-paste settlements. Do NOT create a runtime procedural building generator.

- **Components:** EXTERIOR SHELL, ROOF, DOOR (32px normal / 64px large), WINDOW, TRIM, DECORATION, COLLISION FOOTPRINT.
- **Modularity:** Establish controlled variation through interchangeable wall modules, roof variants, door/window variants, trims, and wear patterns. Do not bake gameplay collision assumptions into visual artwork unnecessarily.

## 8. Tree / Vegetation Standard
Respect M62: Tree collision is `~32x32`; Tree visual canopy is `~64x96` to `96x96`.

- **Rule:** CANOPY VISUAL != TRUNK / COLLISION FOOTPRINT. 
- **Readability:** Trees must anchor clearly to the ground and support top-down readability. Canopies must not make traversable space impossible to read.
- **Categories:** Small vegetation, medium shrubs, standard tree, large tree, crop/field assets. Regions do not need identical flora.

## 9. Cliff / Ledge Visual Standard
M65 owns visual-production requirements only. Do NOT implement gameplay or exact ledge placement (owned by M66/M73/M74).

- **Visuals:** Ensure readable cliff tops, cliff faces, clear height changes, and consistent edge/corner treatments.
- **Future-proofing:** Ensure that climbable ledges (M73) and drop-down ledges (M74) can remain visibly distinct from standard impassable cliffs.

## 10. Water / Coastline Standard
Because multiple regions include coastal/water environments, shoreline assets must be standardized without requiring excessive animation workload.

- **Structure:** Water base, shoreline edge, corner transitions. Shallow/deep distinctions are only required if gameplay/art demands it.
- **Animation:** Simple water animation and foam/wave accents where appropriate. M61 requires baseline environmental animation (e.g., basic water flow). Define a sustainable baseline. Do not create final water assets yet.

## 11. Environment Animation Tiers
Animation workload is tiered to remain sustainable:

- **TIER 1 — REQUIRED BASELINE:** Simple water, basic light flicker where relevant, required environmental identity animation.
- **TIER 2 — OPTIONAL POLISH:** Grass sway, flags, cloth, extra ambient motion.
- **TIER 3 — SPECIAL / UNIQUE:** Spatial distortion, Mirror Gate-specific environment effects, Aetherion anomalies. *(Note: Do NOT implement M205 World VFX. This is purely production classification. Aetherion spatial distortion is required per M61, but actual implementation remains later.)*

## 12. Collision Art Boundary
**VISUAL ASSET != COLLISION.**

- M65 defines which art features need clear collision-readable silhouettes.
- M69 and region-specific milestones own final collision tuning.
- Do NOT redesign player collision or implement final map collisions during M65. Avoid baking invisible gameplay assumptions into textures.

## 13. Depth / Y-Sort Compatibility
Environment assets must visually work with 32x48 player sprites, NPC bottom-center anchoring, and top-down Y-depth sorting.

- **Split Rendering:** Assets like trees, large signs, market stalls, and tall structures may require split rendering (BASE / LOWER PART + OVERHANG / UPPER PART) if the player needs to visually walk "behind" the upper portion of the object. Do not implement final scene architecture unless proving a Godot-safe approach.

## 14. Readability Hierarchy
Environment detail must not overpower gameplay. Negative space is useful; do not fill every empty tile with decoration.

- **Hierarchy:** `Playable Character > Story-important NPC > Generic NPC > Environment`
- **PRIMARY:** Paths, entrances, exits, important landmarks, collision boundaries.
- **SECONDARY:** Trees, fences, buildings, functional props.
- **TERTIARY:** Grass tufts, cracks, small flowers, debris.

## 15. Color / Palette Strategy
Do NOT arbitrarily lock final exact RGB/HEX palette values without production evidence. Exact values remain **DEFERRED TO FIRST REGION FINAL ASSET PRODUCTION**.

- **Strategy:** Define regional palette families, material consistency, value separation, and saturation hierarchy to ensure player/NPC readability against backgrounds.

## 16. Pixel-Art Export Standard
- Integer pixel dimensions.
- No anti-aliasing; no unintended smoothing.
- Transparent background where appropriate.
- No baked shadows unless explicitly required.
- Clean tile seams; no half-pixel alignment.
- No accidental padding that breaks atlas alignment.

## 17. Godot 4.7.1 Import Standard

### A. TEXTURE FILTERING STANDARD
HOLUF pixel-art textures must render with: `Nearest`

For 2D, configure `Nearest` through:
- CanvasItem texture filtering where asset/node-specific control is required, OR
- the appropriate project-wide default when production integration owns it.

**PIXEL ART MUST USE NEAREST FILTERING.**
(Note: `Nearest` is a texture rendering/filtering property, NOT a normal image-import option).

### B. IMAGE IMPORT STANDARD
For raster pixel-art assets, configure the import settings as follows:
- **Compress > Mode:** `Lossless`
- **Mipmaps > Generate:** `Disabled`

`Lossless` remains the preferred default for clean HOLUF pixel art to avoid compression artifacts.

## 18. Godot TileSet / Terrain Workflow
- **Recommendation:** Godot 4's modern workflow favors `TileMapLayer` over the deprecated monolithic `TileMap` node. Production maps should utilize individual `TileMapLayer` nodes for ground, paths, and structural layers, pointing to a shared `TileSet` resource.
- **Migration:** Do NOT mass-migrate current scenes in M65. Migration is owned by future region production milestones.

## 19. Folder / Naming Convention
Do NOT create unnecessary folder depth. Use clear `snake_case`.

- **Paths:**
  - `assets/environment/common/`
  - `assets/environment/elaris/`
  - `assets/environment/lorel/`
  - `assets/environment/alexandria/`
  - `assets/environment/mongreaux/`
  - `assets/environment/kamikoto/`
  - `assets/environment/aetherion/`
- **Categories:** terrain, structures, flora, props, landmarks, water.
- **Filenames:** `[region]_[category]_[asset]_[variant].png` (e.g., `elaris_structures_house_a.png`). Unique landmarks may use dedicated names.

## 20. Source Art vs Exported Game Asset
Do not build a runtime layered environment generator in engine.

- **SOURCE ART:** (Aseprite, Krita, Photoshop, etc.) Can contain layers, guides, and construction logic. Keep separate from the game folder if large.
- **EXPORTED GAME ASSET:** Must be a clean, flattened production PNG imported into Godot.

## 21. Reuse Without Visual Repetition
The world should feel cohesive but regions must remain recognizable.

- **REUSE ALLOWED:** Invisible technical principles, base dimensions, generic structural logic, neutral props when culturally appropriate.
- **CONTROLLED VARIATION:** Roof shapes, wall wear, windows, vegetation variants, prop placement.
- **AVOID:** Same house recolored across every country, identical market stalls across unrelated cultures, copy-paste settlement appearance.

## 22. Performance / Production Sanity
Do NOT premature optimize or invent arbitrary performance limits.

- Avoid thousands of unique tiny texture files; atlas reuse is cleaner.
- Avoid one gigantic global atlas.
- Avoid excessive animated decorative tiles.
- Avoid huge transparent padding.
- Reuse production modules intelligently.

## 23. Handoff to M66 and Region Production
M65 locks the environment pipeline. It does NOT create final art.
- **M66 (Map Layout Production Pipeline):** Owns map spatial flow, district/route structure, dimensions, and exploration organization.
- **M67:** Owns entrances, exits, and map transitions.
- **M69:** Owns final player collision against production art.
- **M73/M74:** Owns ledge gameplay mechanics.
- **M76+:** Owns Elaris-specific actual production.
- **M77:** Owns Elaris final tileset/environment art production.

## 24. Important Current World-Design Direction
The pipeline must support the **Seamless Place Rule** (owned by M66/M67/M70). A city or location that is conceptually one place must exist as one contiguous explorable map whenever practical. M65 ensures technical art-pipeline decisions do not make continuous city maps impractical (e.g., avoiding bloated atlases that would force a map split).

## 25. Elaris / Caelora Compatibility Note
- **Elaris** = isolated island/polity.
- **Caelora** = its capital/main coastal city.
- M65 ensures the pipeline can support coastal city architecture, harbor assets, royal landmarks, and farmlands when Elaris production begins. Do NOT place buildings or design Caelora in M65.

## 26. Acceptance Checklist
- [x] 32x32 base grid preserved
- [x] M61 regional identity preserved
- [x] M62 scale preserved
- [x] player/NPC readability preserved
- [x] terrain transitions sustainable
- [x] atlas strategy sustainable
- [x] building modularity defined
- [x] vegetation scale compatible
- [x] shoreline/water pipeline defined
- [x] cliff/ledge art compatibility defined
- [x] collision remains separate from visual art
- [x] Y-sort/overhang compatibility addressed
- [x] Nearest filtering preserved
- [x] Mipmaps disabled
- [x] Lossless compression terminology correct
- [x] no final region art created
- [x] no M66 layout work performed
- [x] no gameplay systems changed
