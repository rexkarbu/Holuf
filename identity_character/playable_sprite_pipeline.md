# HOLUF — Playable Character Sprite Pipeline (M63)

## 0. Purpose
This document establishes the production pipeline for all playable character overworld sprites in HOLUF. It builds upon the M62 Scale Lock and defines the mechanical, animation, and technical constraints that character artists and technical animators must follow.

**Important:** This is for the 2D top-down exploration world, NOT for battle sprites.

## 1. M62 Scale Authority
All playable character sprites must adhere to the M62 Scale Lock:
- **Body Frame:** 32x48 px (The character's physical body must fit here).
- **Full Visual Canvas (Overflow):** Up to ~48x64 px (Used ONLY for weapons, capes, hair, and dynamic movement extensions).
- **Collision Footprint:** ~24x16 px (Placed at the bottom of the feet).

## 2. Anchor / Baseline Alignment
- **Pivot/Anchor:** All sprites must be anchored at the **Bottom-Center** of their canvas.
- **Feet Baseline:** The soles of the character's feet must consistently touch the same vertical baseline across all 10 characters.
- **Rule:** When swapping between Aren and Torga in the Party UI, the character must not visually "jump" up or down. Their feet must share the exact same Y-coordinate relative to the anchor.

## 3. Directional System
- **System:** 4-Directional (Down, Up, Right, Left).
- **Why not 8-Dir?** To maintain a sustainable indie production workload for a 10-hour game with 10 playable characters and a unique BEAST system.
- **Asymmetry Rule:** 
  - Characters with perfectly symmetrical designs may mirror the Left/Right animations to save production time.
  - Characters with asymmetrical designs (e.g., Katsura's katana on one hip, Orin's specific shoulder pauldron) **must** have dedicated, uniquely drawn Left and Right frames to prevent weapon teleportation.

## 4. Baseline Animation Set
To keep scope manageable, the required world animation set is strictly limited to:
1. **Idle** (4 Directions)
2. **Walk / Run** (4 Directions)

*Note: Interaction, taking damage, or climbing are NOT currently required for the base world pipeline. Overworld interactions can be performed from the Idle state.*

## 5. Animation Timing & Frame Count
- **Idle:** 2 to 4 frames. Timing ~2-4 FPS. (Simple breathing or stance loop).
- **Walk:** 4 frames classic cycle (Stand -> Step Right -> Stand -> Step Left) or 6 frames for fluidity. Timing ~6-8 FPS.
- The visual step rate should comfortably match the current player movement speed (`150.0`).
- **Engine Implementation:** Driven by `AnimatedSprite2D` and `SpriteFrames`. This avoids the unnecessary complexity of `AnimationPlayer` state machines for simple overworld movement.

## 6. 10-Character Silhouette Compatibility
The 48x64 visual canvas has been audited against the locked 10-character roster:
- **LOW Overflow Risk:** Aelia (Magicbook), Lyra (Dagger).
- **MEDIUM Overflow Risk:** Aren (Sword), Neria (Staff), Katsura (Katana), Sylven (Bow).
- **HIGH Overflow Risk:** Doran (Claymore), Torga (Axe/Beast body), Kaelis (Spear), Orin (Longsword/Beast body).
*Solution for High Risk:* Extremely long weapons (Claymore, Spear) must be posed diagonally across the back or resting on the shoulder during Idle/Walk to fit within the 48x64 overflow boundary without severe clipping.

## 7. Spritesheet Organization & Naming
- **Format:** Separate sheets per animation state to keep source files clean and export-friendly.
- **Folder Structure:** `assets/characters/playable/[character_name]/world/`
- **File Naming Convention:**
  - `[character_name]_world_idle.png`
  - `[character_name]_world_walk.png`
- **Direction Ordering (Rows):**
  1. Down
  2. Up
  3. Right
  4. Left

## 8. Godot Import Rules
- **Texture Filter:** `Nearest` (Crucial to prevent pixel blurring).
- **Mipmaps:** Disabled.
- **Compression:** VRAM Uncompressed / Lossless.
- **SpriteFrames:** A standardized `SpriteFrames` resource will be created for each character, mapping directly to `AnimatedSprite2D`.

## 9. Shadows
- Drop shadows should **not** be baked directly into the character sprite.
- Shadows will be handled via a separate, semi-transparent black oval `Sprite2D` or `Polygon2D` placed beneath the `AnimatedSprite2D` in the engine. This allows shadows to dynamically fade or hide when entering certain terrains or water.

## 10. Sprite Acceptance Checklist
Before a character's world sprite is approved, it must pass:
- [ ] Fits the 32x48 body frame (with allowed weapon/cape overflow up to 48x64).
- [ ] Feet align perfectly to the shared bottom-center baseline.
- [ ] Weapon silhouette is readable and does not clip out of the canvas.
- [ ] Rendered cleanly with Nearest-Neighbor filtering (no accidental anti-aliasing).
- [ ] Left/Right mirroring is only used if the character design is truly symmetrical.
- [ ] Animation does not visually "slide" against the 150.0 movement speed.
- [ ] Idle and walk anchors remain completely stable (no jitter).
- [ ] File names and folder paths match the pipeline convention.

---
**END OF PIPELINE LOCK**
*This document satisfies M63 and prepares the art team for actual sprite production. Do not implement these graphics into `player.tscn` until M68 (Final Player Movement Against Production Art).*
