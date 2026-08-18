# HOLUF — NPC Sprite Pipeline (M64)

## 0. Purpose / Authority
This document defines the production pipeline for Non-Playable Character (NPC) overworld sprites in HOLUF. It enforces the M62 Scale Lock while ensuring NPCs populate the world sustainably, respecting canonical regional identities, and avoiding unnecessary production bloat.

## 1. Current Architecture Audit & M62 Scale Authority
- **Current Prototype:** NPCs (e.g., `elder.tscn`) are built using `StaticBody2D` with primitive `Polygon2D` visual nodes (30x40 diamond) and explicit `CollisionShape2D` (radius 16). They do not move or face the player.
- **Gameplay Independence:** The dialogue/interaction system (`npc.gd`) relies entirely on an `Area2D` and `QuestManager`. It is fully decoupled from the visual node. Visuals can be upgraded to Sprites without rewriting NPC logic.
- **M62 Scale Lock Applies:** 
  - Base Tile: 32x32
  - Body Frame: 32x48 px
  - Visual Overflow: up to ~48x64 px
  - Collision Footprint: ~24x16 px (at feet)

## 2. Relationship to M63 (Playable Pipeline)
NPCs must physically belong in the same world as the Player. 
- **Anchor:** Bottom-Center.
- **Baseline:** The soles of an NPC's feet must perfectly align with the Player's baseline so they share the exact same Y-depth and ground plane.
- **Shadows:** Shadows must NOT be baked into the pixel art. They will be handled via a separate semi-transparent oval node beneath the sprite.

## 3. Direction / Animation Tiers
Not every background NPC needs a full 4-directional walk cycle. To keep the 10-hour indie workload sustainable, NPCs are tiered:
- **STATIC NPC (Background):** `Idle` only. 1-Direction (typically facing Down/Camera).
- **INTERACTIVE NPC (Future Optional):** `Idle` only. 4-Directions (turns to face player when spoken to).
- **MOVING / STORY NPC:** `Idle` + `Walk` in 4-Directions (Down, Up, Right, Left).

## 4. Race Silhouette Rules (Race != Nationality)
Do not create regional stereotypes (e.g., "all Lorel NPCs are Humans"). Race identity != Universal body template. Production flexibility != Canonical anatomy.

- **Human:** Use the standard humanoid production baseline defined by M62 (32x48 px). Do not imply every Human has identical proportions.
- **Elf:** Elf remains a distinct canonical race. However, specific anatomy (universal taller stature, universal leaner body, specific ear length/shape) is **DEFERRED TO CHARACTER / NPC FINAL VISUAL DESIGN** because canon is underspecified. The pipeline only guarantees that future Elf designs CAN be supported within the 32x48 body frame (and ~48x64 overflow) without hard-locking unconfirmed anatomy now.
- **Beast:** Beast remains a distinct canonical race. However, do NOT state that all Beasts universally possess ears, tails, horns, muzzles, or specific body widths unless canon explicitly establishes them for that individual. **Race != Culture != Individual.** Detailed Beast anatomy is **DEFERRED TO CHARACTER / NPC FINAL VISUAL DESIGN**. The pipeline CAN SUPPORT broader bodies, head shapes, or racial features within the M62 scale if a canonical design requires it, but support for these forms does NOT mean every member of the race possesses them.

## 5. Regional Clothing Language
The following are **REGIONAL ART-DIRECTION / PRODUCTION LANGUAGE** guidelines derived from worldbuilding, NOT biological racial properties. These represent a *preferred tendency* or *production reference*, rather than mandating that every NPC must wear identical stereotypes:
- **Elaris:** May use homespun cloth, practical muted greens/greys, or coastal fishing/farming silhouettes.
- **Lorel:** May use light fabrics, silks, merchant-oriented silhouettes, sun hats, or bright terracotta/blues.
- **Alexandria:** May use heavy coats, leather aprons, goggles, forged accents, or formal military/academic silhouettes.
- **Mongreaux:** May use nomadic riding leathers, layered furs, or ornate scholarly robes in Montreval.
- **Kamikoto:** May use region-appropriate traditional silhouettes (e.g., kimono-inspired robes, martial dogi, hakama).
- **Aetherion:** May use heavy cold-weather research gear or thick insulated coats. **Crucial:** Aetherion is NOT a country. Aetherion must NOT receive generic civilian farmers/villagers unless canonical story content later explicitly requires them.

## 6. NPC Role Taxonomy
Common required archetypes:
- Civilian (Generic background)
- Merchant / Shopkeeper
- Guard / Soldier
- Scholar / Researcher
- Elder / Leader
- Story-Important NPC

## 7. Unique vs Generic Tiers & Reuse Rules
- **TIER A (Major Story NPC):** 100% unique design. No palette swaps.
- **TIER B (Local Important NPC):** Semi-unique. Can share a body base but features unique clothing or props (e.g., a specific Guard Captain).
- **TIER C (Generic Population):** Controlled reusable archetypes. 
- **Reuse Constraint:** A Tier C generic merchant from Lorel MUST NOT be recolored and placed in Kamikoto. Regional clothing silhouettes must be maintained.

## 8. Production Variation Strategy
- **Method:** Flattened final PNG sprites produced from reusable art-program bases (e.g., layered Aseprite files). 
- **Rule:** Do NOT implement a complex runtime modular layered character generator in Godot. It is unnecessary overhead for this pipeline.

## 9. Spritesheet / Naming / Folder Rules
- **Generic/Role NPCs:** `assets/characters/npc/[region]/`
  - Example: `lorel_merchant_a_world_idle.png`
- **Unique Story NPCs:** `assets/characters/npc/story/[npc_name]/`
  - Example: `lloyd_world_idle.png`
- **Direction Ordering:** Down, Up, Right, Left.

## 10. Godot Import Rules
- **Filter:** `Nearest` (Pixel-perfect).
- **Mipmaps:** Disabled.
- **Compress To:** `Lossless` (Preferred production default for clean pixel art to avoid compression artifacts).
- **Node Choice:** 
  - Use `Sprite2D` for 1-Directional STATIC NPCs (cheaper performance).
  - Use `AnimatedSprite2D` + `SpriteFrames` for 4-Directional / MOVING NPCs (maintains M63 consistency).

## 11. Readability Hierarchy
NPCs must not visually overpower Playable Characters.
- **Hierarchy:** `Player` > `Story NPC` > `Generic NPC` > `Environment`
- Generic NPCs should use slightly less saturated palettes or lower detail density than the vibrant player roster, guiding the player's eye naturally.

## 12. Special Body Cases
Elders (hunched posture), robes, large hats, or beast tails may utilize the `~48x64` visual overflow canvas. If an NPC genuinely requires a footprint larger than 48x64, it must be flagged for special approval. Do NOT silently break the M62 scale lock.

## 13. Acceptance Checklist
Before an NPC sprite is integrated, it must pass:
- [ ] Fits M62 scale rules and 32x48 primary body frame.
- [ ] Bottom-center baseline perfectly aligns with Playable Characters.
- [ ] Displays appropriate regional clothing/material language.
- [ ] Represents canonical Race != Nationality rules.
- [ ] Exported Nearest-Neighbor clean with no anti-aliasing.
- [ ] Palettes do not overpower the Player characters.
- [ ] Folder paths and filenames follow the region/story convention.
- [ ] Does NOT inappropriately reuse assets across culturally clashing regions.

---
**END OF PIPELINE LOCK**
*What M64 Does NOT Implement:* Final NPC artwork, actual map population, environment tiles (M65), layout (M66), or gameplay logic changes.
