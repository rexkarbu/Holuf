# HOLUF Player Collision Production Lock — M69

This document serves as the canonical lock for Player Collision rules, dimensions, and baseline behavior as of M69.

## 1. Player Physics Root
- The `CharacterBody2D` root explicitly represents the **ground/feet baseline**.
- Visuals (e.g. `Polygon2D`, future sprites) must align their soles/bottom edge to this `y=0` local coordinate.

## 2. Collision Shape
- Node: `RectangleShape2D`
- Size: `24x16` px
- Center offset: `position = Vector2(0, -8)`
- Local footprint: `X: -12 to 12`, `Y: -16 to 0`. This ensures that the solid physics footprint lies precisely on and above the player's grounding baseline.

## 3. Scale Relationship
- Typical humanoid body visuals will span `32x48` px (or overflow to `~48x64`).
- Visual overflow does NOT impact the collision footprint. The footprint strictly remains `24x16`.

## 4. Bottom-Center Compatibility
- Future `AnimatedSprite2D` or production art assets must use bottom-center alignment, sitting flush on the root baseline.

## 5. Environment Collision Rule
- **Visual != Collision**: Tall items like trees, signs, and market stalls should only collide based on their grounded base (the area a player cannot physically step into).

## 6. Tall Object Rule
- Canopies, roofs, and overhangs are permitted to visually extend above the player without generating physics blocking volumes up high.

## 7. Door / Passage Rule
- Normal passages/doors in HOLUF are locked at `32px` wide.
- A `24px` player footprint comfortably traverses a `32px` gap. No collider shrinking or squeeze mechanics are necessary or allowed.

## 8. Collision Movement
- Handled exclusively via `move_and_slide()` under `CharacterBody2D.MOTION_MODE_FLOATING`.
- Sliding along diagonal/corner walls occurs naturally via the engine's built-in physics resolution.

## 9. Spawn Contract
- `SpawnMarker` nodes store the root/feet baseline. 
- Markers must be placed such that the bounding box `[-12..12, -16..0]` does not intersect solid terrain.

## 10. Save / Load Contract
- Saved position directly maps to the `CharacterBody2D` root position.
- No `±8` or related coordinate migration logic should be implemented in `SaveManager`.

## 11. Battle Return Contract
- Coordinate preservation for battle transitions retains the exact root coordinate safely.

## 12. Encounter Distance
- The Encounter system depends on actual post-collision displacement. Sliding along walls counts correctly; pushing blindly against flat surfaces yields no distance.

## 13. Interaction Boundary
- `InteractionDetector` functions independently of the solid footprint. Size/layer configurations remain unaltered here.

## 14. NPC Boundary
- M69 establishes the *player* collision logic. Mass conversion of NPC collision shapes is deferred to explicit NPC milestones.

## 15. Region Boundary
- Region-specific static collision (e.g. final Elaris maps) belongs in separate regional collision passes.

## 16. Camera Boundary
- `Camera2D` framing rules (zoom, limits, offset) remain the domain of M70.

## 17. Art Boundary
- No Aren art, placeholders, or `AnimatedSprite2D` configurations were integrated in this pass. Prototype `Polygon2D` is retained.
