# HOLUF — World Transition Pipeline (M67)

## 1. Existing Transition Architecture Audit
- **TransitionManager:** An Autoload (`transition_manager.tscn`) exists and successfully handles fade-to-black, input disabling during transition, and `get_tree().change_scene_to_file()`.
- **GameManager:** Handles `player_return_position` (a hardcoded `Vector2`) and prevents duplicate transitions via an `is_transitioning` flag.
- **SaveManager:** Supports pending loads (`_has_pending_load`) safely integrated into `main.gd`.
- **Main Scene (`main.tscn`):** Acts as the root node hosting both `Player` and `World` concurrently. Currently, `world.tscn` is hardcoded as an instantiated child.
- **Deficit:** The project lacks a dynamic map-swapping architecture inside `main.tscn` and relies on raw `Vector2` coordinates rather than robust named spawn markers for locations.

## 2. Existing Battle Transition Compatibility Audit
- **Current Behavior:** World → Battle uses `TransitionManager.transition_to_scene("res://scenes/battle/battle.tscn")`. Battle → World returns to `main.tscn` and restores the player via `GameManager.player_return_position`.
- **Safety:** The `GameManager.is_transitioning` flag successfully prevents double-triggering. The state is clean and separated.
- **Rule:** Future world location transitions must NOT break or alter this battle transition flow. They may share `TransitionManager`, but world transitions must introduce a robust Spawn ID system instead of relying purely on `Vector2` coordinates.

## 3. Transition Terminology
- **LOCATION:** A meaningful explorable place.
- **LOCATION BOUNDARY:** The conceptual boundary between two meaningful locations.
- **ENTRANCE/EXIT:** A player-facing entry/departure point.
- **TRANSITION ZONE:** A runtime trigger (e.g., `Area2D`) representing a legitimate location boundary.
- **DESTINATION:** The target location/scene file.
- **SPAWN POINT:** A named `Marker2D` identifier in the destination (e.g., `south_gate`, `interior_door`).
- **RETURN POINT:** The logical counterpart used when returning.
- **TRANSITION REQUEST:** A single requested location change guarded by state.

## 4. Valid vs Invalid Transitions (Seamless Place Rule)
**ONE CONTIGUOUS PLACE = ONE CONTIGUOUS PLAYER EXPERIENCE.**
- **VALID:** Town → Route, Route → Dungeon, Exterior → meaningful Interior, Region → Region, special narrative separation.
- **INVALID:** Market → Plaza in the same city, Residential → Commercial District, Harbor → Main Street, one side of the same street to another. 
- *Note: Technical scene organization (e.g., child scenes or TileMapLayers) must NOT dictate player-visible fades. A city must remain seamless.*

## 5. Transition Runtime Architecture (Contract)
When the first region maps are produced (M76+), the transition system must implement:
1. **TransitionZone (Area2D Component):** Exports `destination_scene_path: String` and `target_spawn_id: String`.
2. **SpawnMarker (Marker2D Component):** Exports `spawn_id: String`.
3. **Main Scene Dynamic Loading:** `main.tscn` must be updated to dynamically instantiate the `destination_scene_path` instead of hardcoding `world.tscn`.
4. **GameManager Expansion:** Must store `target_spawn_id` alongside `player_return_position`.

## 6. Destination Spawn Architecture
- A transition must NOT rely on fragile hardcoded `Vector2` coordinates.
- **Strategy:** Target locations must contain `SpawnMarker` nodes. Upon scene load, the map initialization logic searches for the marker matching `GameManager.target_spawn_id` and teleports the player there *before* the fade-in completes.

## 7. Spawn Orientation Handling
- If the M63 player controller supports directional facing (e.g., `Vector2.DOWN`), `SpawnMarker` components may optionally export an arrival `facing_direction`.
- *Status:* DEFERRED to implementation integration. Do not invent a facing system if unsupported by the current player controller.

## 8. Safe Arrival Placement & Ping-Pong Protection
- **Safe Placement:** `SpawnMarker` must be placed with a safe offset buffer, ensuring the player does not spawn directly inside collision or overlapping an encounter trigger.
- **Ping-Pong Prevention:** The player must not immediately trigger a return transition upon spawning.
- **Strategy:** The destination marker must be placed safely beyond the return `TransitionZone`'s collision shape. The player must actively walk into the zone to trigger it.

## 9. Duplicate Request Protection
- **Strategy:** Use `TransitionManager._is_transitioning` and `GameManager.is_transitioning` (already implemented) to guard against multiple overlapping `Area2D` collisions, repeated inputs, or multi-frame physics triggers. Only the first valid request is processed.

## 10. Fade / Input Safety
- **Visuals:** Short fade out → scene switch → spawn player → short fade in. Elaborate VFX are deferred to later polish milestones.
- **Input:** `get_tree().root.gui_disable_input = true` and viewport input handling (already in `TransitionManager`) must remain active during the entire fade lifecycle to prevent rogue inputs.

## 11. Failure Handling
- A bad destination (missing scene, invalid spawn ID) must fail safely.
- **Strategy:** If the target scene or `SpawnMarker` cannot be found, an explicit developer error must be printed via `push_error()`, and the fade must reverse to return control to the player. No permanent black screens. No silent teleports to `Vector2.ZERO`.

## 12. Save / Autosave Boundary
- **Integration with M60.5:** Not every tiny interior transition warrants an autosave.
- Checkpoint-worthy transitions (e.g., Region → Region, major story progression) may hook into `SaveManager.request_autosave()` upon safe arrival.
- Regular doors/interiors should not trigger autosaves unless designated by the design. The existing safe public API must be used.

## 13. Story-Lock Boundary (M71)
- `TransitionZone` components should support an `is_locked` boolean or a generic condition check.
- Story logic (M71) determines *if* a zone is locked, while the generic system only checks the flag. Do not hardcode quest names into the generic transition script.

## 14. Interior, Region, and Dungeon Standards
- **Interiors:** Exterior entrance → transition → named interior spawn. Not every decorative house gets an interior.
- **Regions:** Elaris → Lorel transitions are technically supported by this pipeline, but no Elaris/Lorel routes are to be designed in M67.
- **Dungeons:** Support Route → Dungeon, but avoid transition spam between ordinary rooms if the dungeon is conceptually one continuous space.

## 15. Technical Organization vs Player Experience
- If future architecture streams or instantiates child scenes while keeping continuous player movement, that is NOT a player-visible M67 transition. M67 handles hard, meaningful location changes.

## 16. Authoring Workflow & M68+ Handoff
1. **M66** defines a legitimate location boundary.
2. Map author places a `TransitionZone` (exit) and a `SpawnMarker` (return).
3. Map author links the `destination_scene_path` and `target_spawn_id`.
4. Round-trip safety and Re-entry safety are validated.
- **M68-M70:** Handle final player movement, collision, and camera framing.
- **M76+:** Owns actual Elaris map production.
