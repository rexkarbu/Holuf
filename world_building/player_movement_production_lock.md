# HOLUF Player Movement Production Lock — M68

This document serves as the canonical lock for Player Movement constraints and behavior as of M68.

## 1. Movement Model
- Uses top-down `CharacterBody2D`.
- Displacement is executed via `move_and_slide()`.
- Explicitly configured with `CharacterBody2D.MOTION_MODE_FLOATING` to disable platformer gravity, floor-snapping, or slope detection.

## 2. Input
- Uses `Input.get_vector("move_left", "move_right", "move_up", "move_down")`.
- Supports WASD and Arrow Keys via standard InputMap.
- Preserves analog stick magnitude natively without artificial clamping or snapping.

## 3. Speed
- Maximum movement speed is strictly `150.0` px/s.
- No sprint, dash, stamina, or acceleration features are introduced.

## 4. Diagonal Rule
- Input normalization is handled by `get_vector`, preventing any diagonal speed advantage (i.e. maximum velocity remains ~150 px/s on keyboards).

## 5. Facing
- Tracks four canonical states: `down`, `up`, `right`, `left`.
- Default facing is `down`.
- Resolution uses the dominant-axis rule: `abs(direction.x) > abs(direction.y)` determines horizontal vs vertical.
- Vertical axis (`y`) serves as the deterministic tie-break for exact diagonal ties.
- Retains the last recorded facing direction when the player is idle, allowing for stable idle animations.

## 6. Movement Lock
- Player `velocity` is strictly constrained to `Vector2.ZERO` when `is_locked` is true.

## 7. Encounter Distance
- The EncounterManager accumulates distance using actual post-move displacement (`walked = global_position.distance_to(old_pos)`).
- This prevents theoretical through-wall movement from increasing the encounter distance counter.

## 8. Art Boundary
- M68 establishes an art-agnostic movement model.
- No final Aren production sprite is integrated.
- Previously created Aren placeholder art assets are NOT production-ready and must not be used.
- Future animated sprite integrations will consume the `facing` and movement state initialized here.

## 9. Collision Boundary
- Final collision shapes and footprints remain deferred to M69. Current footprints are known prototypes.

## 10. Camera Boundary
- Final camera behavior (smoothing, bounds, zoom) remains deferred to M70.

## 11. Regression Requirements
- Tested to ensure zero disruption to M67 Transition behavior (`SpawnMarker` usage, arrivals).
- Tested to ensure exact save/load positions and battle return positions.
- Interaction logic (dialogue lock) and encounter logic remain intact.
