# HOLUF — World Production Visual Bible

## 0. Purpose / Authority
This document serves as the visual production source-of-truth for HOLUF's world. It defines what the world should visually feel like, how regions distinguish themselves, which visual rules remain consistent globally, and establishes a foundation for subsequent milestones (M62–M75). 
**Note:** This is an art-direction milestone. It explicitly **does not** lock pixel dimensions, final gameplay collision, or exact encounter placement.

## 1. Canon Sources
This Bible is derived from the highest-priority canonical text:
- `design_lock.md`
- `world_building/elaris.md`
- `world_building/lorel.md`
- `world_building/alexandria.md`
- `world_building/mongreaux.md`
- `world_building/kamikoto.md`
- `world_building/aetherion.md`
*(and secondary reference files for off-route nations)*

## 2. Global Visual Pillars
- **Dark Fantasy Identity:** Dark fantasy comes from tone, history, material wear, danger, and environmental storytelling—not just black/red palettes. Avoid excessive visual melodrama. There must be areas of calm, normal life, and beauty to provide contrast.
- **2D Top-Down Readability:** Gameplay clarity supersedes excessive detail. Walkable spaces must be immediately identifiable.
- **World Readability:** Players must instantly recognize whether a path is safe, dangerous, or a main route just from visual language.
- **Consistency Across Countries:** Despite diverse inspirations, all regions share a unified rendering style and material logic to feel like one cohesive planet (Asterra).
- **Environmental Storytelling:** Use ruined structures, repaired walls, or overgrown paths to tell history without excessive dialogue.

## 3. Top-Down Readability Rules
- **Environment Silhouette Hierarchy:** Ground planes must contrast with vertical walls/obstacles.
- **Ground vs. Path Distinction:** Paths should guide the player naturally through negative space, using color value or texture density to stand out against wild ground.
- **Interactable Readability:** Items or objects the player can interact with (doors, chests, signs) must use a distinct color accent or value contrast.
- **Lighting Philosophy:** Shadows should anchor objects to the ground, but not obscure walkable paths.

## 4. Detail / Clutter Hierarchy
To preserve gameplay readability, clutter is strictly categorized:
- **PRIMARY (Crucial for Gameplay):** Walkable ground, paths, buildings, doors/exits, major landmarks. Must have the highest contrast and clarity.
- **SECONDARY (Context & Boundaries):** Trees, rocks, fences, market structures, functional props. Used to define collision boundaries and world logic.
- **TERTIARY (Flavor):** Small debris, grass tufts, flowers, cracks, tiny decoration. Must be low-contrast and sparse enough to not overwhelm the primary read.

## 5. Material Language
- Avoid pure generic colors (e.g., #FF0000). Use qualitative, grounded palettes: *weathered stone*, *oxidized copper*, *sun-bleached wood*, *damp moss*.
- Wear and tear should be logical: paths wear down in the center, buildings weather at the base (dirt) and roof (rain/sun).

## 6. Terrain + Path Language
- **Main Route:** Wide, well-worn, clearly defined edges (paved or packed dirt).
- **Secondary Route:** Narrower, more grass intrusion, softer edges.
- **Optional/Secret Route:** Visually obscured, overgrown, requires visual inference.
- **Dangerous Route:** Broken tiles, dark soil, encroaching jagged vegetation.
*(Note: Collision implementation is deferred).*

## 7. Architecture Language
- **Roof Readability:** Roofs must have a distinct color/texture from the ground to define building footprints instantly.
- **Entrances:** Doors should be clearly inset or framed to indicate transitions.
- **Scale:** Buildings should feel appropriately massive relative to characters, but exact tile grid size is deferred to M62.

## 8. Vegetation Language
- Vegetation provides regional identity (e.g., pines vs. palms vs. cherry blossoms) but must not block the camera view of the player unless intentionally hiding a secret.
- Trunks must be readable as collision; canopies can be softer.

## 9. Lighting / Atmosphere
- Lighting tendencies define mood.
- Natural regions rely on sun angle/ambient color.
- Aetherion and dangerous zones use unnatural atmospheric effects (fog, spatial distortion, unnatural light sources).

---

## 10. Main Route Region Identities

### Elaris
- **Core visual sentence:** An isolated, stagnant island where life is safe but suffocating.
- **Terrain language:** Coastal cliffs, small farm plots, simple dirt paths.
- **Architecture language:** Simple, functional, slightly worn. Stone and wood, tightly packed in Caelora but rural elsewhere.
- **Vegetation:** Temperate coastal scrub, practical crops.
- **Palette family:** Muted greens, weathered greys, pale coastal blues.
- **Identifiable in 2 seconds:** Small-scale island life, no grand architecture, feeling of isolation.
- **AVOID:** Grand castles, advanced technology, bustling diverse crowds.

### Lorel
- **Core visual sentence:** A vibrant, sunlit federation of trade and culture.
- **Terrain language:** Paved trade roads, gentle hills, Mediterranean coastlines.
- **Architecture language:** Mediterranean/Italian inspired. Terracotta roofs, stucco walls, plazas, canals or port structures.
- **Vegetation:** Olive-like trees, vibrant vines, warm-climate flora.
- **Palette family:** Warm terracotta, sunlit ochre, rich sea blue.
- **Identifiable in 2 seconds:** Bright, wealthy, culturally rich, sun-drenched.
- **AVOID:** Gloomy fog, brutalist stone, isolated rural depression.

### Alexandria
- **Core visual sentence:** A pragmatic, structured nation of engineering and applied magic.
- **Terrain language:** Highly structured, rigid roads, controlled environment.
- **Architecture language:** Central European/Germanic. Heavy stone, half-timbered accents, metalwork, prominent workshops and clockworks.
- **Vegetation:** Managed forests, structured parks.
- **Palette family:** Slate grey, deep forest green, forged iron, brass accents.
- **Identifiable in 2 seconds:** Industrial-fantasy precision, heavy stonework, organized.
- **AVOID:** Wild overgrowth, fragile wooden huts, chaotic layouts.

### Mongreaux
- **Core visual sentence:** A massive expanse of plains leading to a grand, cosmopolitan center of learning.
- **Terrain language:** Vast sweeping steppes, wide travel routes, huge scale.
- **Architecture language:** French/Mongolian blend. Ranging from nomadic outposts on the plains to grand, ornate, multi-cultural academies in Montreval.
- **Vegetation:** Rolling grass seas, scattered large ancient trees.
- **Palette family:** Golden plains, regal blues, white stone (in the capital).
- **Identifiable in 2 seconds:** Wide open spaces contrasting with a massive, educated metropolitan hub.
- **AVOID:** Claustrophobic forests, primitive/savage stereotyping of the plains.

### Kamikoto
- **Core visual sentence:** A disciplined land of tradition, swordsmanship, and ancient mirror technology.
- **Terrain language:** Mountainous passes, meticulously manicured paths, bamboo groves.
- **Architecture language:** Japanese inspired. Sloped roofs, wooden joints, paper lanterns, ancient shrines integrated with advanced Mirror Gate ruins.
- **Vegetation:** Cherry blossoms, bamboo, pines, moss gardens.
- **Palette family:** Deep reds, rich dark wood, vibrant spring pinks/greens.
- **Identifiable in 2 seconds:** Striking architectural silhouettes, disciplined cleanliness, martial presence.
- **AVOID:** Generic "ninja" fantasy cliches; keep it grounded in craftsmanship and history.

### Aetherion
- **Core visual sentence:** A hostile, unnatural convergence of ancient spatial phenomena and modern cold research.
- **Terrain language:** Jagged rocks, unnatural geometric terrain breaks, frozen or barren ground.
- **Architecture language:** Cold research facilities built brutally into ancient, incomprehensible ruins. Purely functional, no civilian comforts.
- **Vegetation:** Dead or crystallized flora, zero agricultural life.
- **Atmosphere/Lighting:** Unnatural sky, spatial distortions, shifting fog, eerie glow.
- **Palette family:** Cold steel, glacial blue, void black, unnatural spatial violet/teal.
- **Identifiable in 2 seconds:** It is NOT a country. It is an isolated, dangerous laboratory built on a spatial anomaly.
- **AVOID:** Normal houses, marketplaces, standard fantasy villages, "evil villain lava castles."

---

## 11. Off-Route World Reference
*(These regions are referenced in lore but are not the primary production focus for the main route.)*

### Valeria
- **Identity:** West-central Ardoria. Spanish/Portuguese inspired. Coastal trade, horse traditions, constitutional monarchy.
- **Visuals:** Coastal hills, equestrian plains, warm oceanic palettes.

### Averon
- **Identity:** North-west Ardoria. Scottish/Swiss inspired. Highlands, severe weather, human/elf coexistence.
- **Visuals:** Rocky highlands, deep lochs, sturdy mountain holds, cold winds.

### Ravaryn
- **Identity:** East-southeast Ardoria. Balkan/Caucasus inspired. Rugged mountains, fortified towns, human/beast coexistence.
- **Visuals:** Steep rocky valleys, layered defensive architecture, resilient communities.

### Kharuun
- **Identity:** West Island. Steppe inspired. Nomadic and semi-nomadic Beast/Human populations.
- **Visuals:** Vast grasslands, nomadic camps, riverside permanent settlements, wide skies.

---

## 12. Region Distinctness Matrix

| Feature | Elaris | Lorel | Alexandria | Mongreaux | Kamikoto | Aetherion |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Terrain** | Coastal, small farms | Gentle hills, paved roads | Structured, rigid | Vast steppes | Mountain passes | Jagged, broken |
| **Architecture** | Simple wood/stone | Terracotta, stucco | Heavy stone, metal | Grand masonry (city) / Tents (plains) | Wood, sloped roofs | Cold facilities + ruins |
| **Vegetation** | Coastal scrub | Olive, warm flora | Managed forests | Rolling grass | Bamboo, pines | Dead / crystallized |
| **Palette** | Muted green/grey | Warm ochre/blue | Slate, iron, dark green | Golden yellow, white | Deep red, dark wood | Steel, void, violet |
| **Atmosphere** | Stagnant, isolated | Sunny, vibrant | Pragmatic, smoky | Open, sweeping | Disciplined, quiet | Unnatural, distorted |
| **Special Motif**| Rural isolation | Trade / canals | Engineering/Magic | Cosmopolitan scale | Mirror Gate tech | Spatial anomaly |

---

## 13. Environment Asset Taxonomy
To guide M65 pipeline production, assets will be categorized as follows:
- **Base Surfaces:** Walkable ground, paths, terrain edges, water.
- **Verticality:** Cliffs, ledges (M73), walls, fences.
- **Structures:** Building exteriors, roofs, doors, windows, structural ruins.
- **Flora:** Trees, shrubs, grass patches.
- **Geology:** Large rocks, pebbles.
- **Functional Props:** Bridges, signs, crates, market stalls.
- **Regional Props:** Culturally specific items (e.g., Kamikoto lanterns, Alexandrian gears).
- **Landmarks:** Massive unique structures (e.g., Spatial Core, Mirror Gates).

---

## 14. Character / Environment Compatibility
- Characters must easily separate visually from the terrain.
- Playable character accents must remain readable against their native environments.
- NPC silhouettes should not disappear into the background.
- Contrast should rely on value and saturation, not just thick outlines.

---

## 15. Environmental Animation / VFX Boundaries
- **Baseline (Required):** Water flow, simple light source flickering, basic weather (rain/snow).
- **Polish (Optional/Later):** Grass swaying, cloth/flag wind physics, advanced spatial distortion shaders.
- **Aetherion Exception:** Spatial distortion is required baseline for Aetherion's identity.

---

## 16. What M61 Does NOT Lock
- Exact pixel dimensions (16x16 vs 32x32 vs 48x48).
- Final character/NPC sprite designs.
- Exact map layouts or collision boundaries.
- Actual gameplay encounters or ledge mechanics.

## 17. Handoff Requirements for M62–M65
- **M62 (Scale Lock):** Must use this Bible to ensure chosen scale supports the desired architectural and character readability.
- **M65 (Tileset Production):** Must use the Taxonomy and Distinctness Matrix to begin drafting base tiles.

## 18. Open / Deferred Visual Decisions
- Exact RGB/Hex palettes (to be locked when first assets are produced).
- Final pixel density.
- Animation frame counts for environmental VFX.
