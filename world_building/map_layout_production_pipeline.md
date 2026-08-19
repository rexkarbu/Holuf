# HOLUF — Map Layout Production Pipeline (M66)

## 1. Current Map Architecture Audit
- **Current Prototype:** The current `world.tscn` is a monolithic prototype environment. It uses `Polygon2D` whiteboxes for boundaries and paths, with manual `CollisionShape2D` nodes on `StaticBody2D` for environmental obstacles.
- **Size/Shape:** It functions as one large flat square, conceptually representing multiple zones but entirely continuous.
- **Triggers:** Various `Area2D` nodes act as encounter zones (`encounter_trigger.gd`), safe zones (`safe_zone.gd`), and narrative triggers (`old_ruins_trigger.gd`).
- **NPCs:** Hardcoded placement (e.g., `elder.tscn`) placed arbitrarily in the world node hierarchy.
- **Transitions:** No formal scene transition or mapping architecture exists yet; the player spawns directly where placed in the editor.
- **Camera:** Uses a basic attached `Camera2D` with limits loosely assuming the boundaries of the whitebox.
- **Compatibility with Seamless Place Philosophy:** The current approach of putting everything in one scene technically supports "Seamless", but it lacks the necessary scaling architecture. Future production maps will require a clean layout strategy without becoming bloated monolithic files, while retaining the seamless player experience. *(Note: Do not redesign gameplay in this section.)*

## 2. Map Unit Definitions
- **REGION:** A large story/world territory (e.g., Elaris, Lorel, Alexandria, Mongreaux, Kamikoto).
- **LOCATION:** A meaningful explorable place (e.g., city, settlement, route, dungeon, facility, interior).
- **DISTRICT / SUBAREA:** A visual/gameplay subsection inside a location. **Important:** DISTRICT != SEPARATE MAP. A district inside one seamless city should normally remain part of the same explorable location.
- **INTERIOR:** A building/internal space that may legitimately use a transition.
- **ROOM / CHAMBER:** Smaller enclosed space inside an interior/dungeon.

## 3. Seamless Place Rule — Production Standard
ONE CONTIGUOUS PLACE = ONE CONTIGUOUS EXPLORABLE MAP, whenever technically and production-wise practical.

**WHEN TO KEEP ONE CONTIGUOUS MAP:**
- Same city, same village, same settlement.
- Continuous exterior facility.
- Continuous outdoor dungeon when practical.

**WHEN A NEW LOCATION / TRANSITION IS JUSTIFIED:**
- Town → Route.
- Overworld exterior → Building interior.
- Route → Dungeon.
- Major dungeon floor change.
- Clearly separated geographic location (Region → Region).
- Special narrative/technical separation when justified.

**Explicitly prohibit splitting one city simply because:**
- The art changes.
- One district is richer, higher elevation, or a harbor.
- Editor organization would be easier. Technical convenience alone is not enough.

## 4. Contiguous Map Does Not Mean Flat Map
A seamless city may still contain different elevations, stairs, cliffs, ramps (where supported), narrow roads, plazas, harbors, gardens, upper/lower districts, walls, bridges, landmarks, and restricted zones.
- **Do NOT interpret seamless as one flat rectangle with everything visible.** Layout must use natural visual barriers and spatial composition.

## 5. Map Size Philosophy
Maps should be large enough to make places believable but small enough to avoid empty walking and production bloat for a ~10-hour RPG.
- Walking time must serve exploration, atmosphere, story, navigation, and encounters—not padding.
- Size categories conceptually: SMALL, MEDIUM, LARGE.
- **Do not lock arbitrary pixel/tile dimensions without production evidence.** Any future size must remain aligned to the 32x32 world grid.

## 6. Walking-Distance / Density Philosophy
Important destinations should be spaced intentionally. A player should not walk for long stretches through visually empty space unless that emptiness itself has narrative/environmental purpose. Establish principles for city, route, dungeon, and open-field density. **Do NOT invent exact seconds/meters as absolute canon unless supported.**

## 7. Path Hierarchy
- **PRIMARY PATH:** Main route players naturally read.
- **SECONDARY PATH:** Optional side route or alternate circulation.
- **SECRET / OPTIONAL PATH:** Subtle but fair exploration route.
- **DEAD END:** Only acceptable if it provides loot, story, visual payoff, NPC, secret, or intentional worldbuilding. Avoid meaningless dead ends. Paths must remain readable without giant floating objective markers.

## 8. City / Settlement Layout Language
A believable settlement may include: main entry, main road, plaza / social focus, residential clusters, commerce, government / civic landmark, service areas, harbor if applicable, exits, and optional alleys / side paths.
- **Do NOT create a universal mandatory city template.** Regions must retain distinct identities. The player should learn the city's shape through landmarks and paths.

## 9. Landmark-Based Navigation
Maps should be understandable through visible landmarks (e.g., tower, large tree, palace/residence, harbor, academy, factory, temple, gate, mountain feature, Mirror Gate structure).
- Use landmarks to help orientation. Avoid over-reliance on sign spam, UI markers, or identical streets.
- Classify as: PRIMARY LANDMARK, SECONDARY LANDMARK, LOCAL LANDMARK if helpful.

## 10. Caelora Compatibility — Do Not Design It Yet
**Current canon:** Elaris = isolated island/polity. Caelora = capital/main coastal city. Caelora contains the Royal Residence / Government Seat in a higher part of the city, and includes coastal/harbor identity.
- **M66 must define a pipeline capable of supporting this, but must NOT determine exact street layout, exact building positions, exact harbor shape, exact Royal Residence footprint, or exact map dimensions.** These are later Elaris production decisions (M76).

## 11. Region-Specific Layout Tendencies
- **ELARIS:** Small island / modest scale / coastal / socially close-knit.
- **LOREL:** Trade-oriented settlements / warmer commercial spaces.
- **ALEXANDRIA:** Structured engineering / institutional character.
- **MONGREAUX:** Broader/open geography with contrast between steppe/open space and educated/metropolitan areas.
- **KAMIKOTO:** Terrain/elevation and disciplined/traditional spatial identity where canon supports it.
- **AETHERION:** **NOT A COUNTRY.** Research / ruin / anomaly space. No normal civilian-city production assumptions.
- Where canon is insufficient: **DEFERRED**. Do not invent new geography.

## 12. World Routes
Routes should support directional progression, exploration pockets, encounter placement (later), landmarks, optional branches, and safe readable traversal. Avoid long corridor syndrome. Routes may bend, widen, narrow, branch, or include vertical variation. **Do NOT place encounters.**

## 13. Dungeon Layout Philosophy
Support main progression route, optional branches, shortcuts where appropriate, visual landmarks, combat space readability, and boss approach/staging where required. Avoid mazes for the sake of mazes, identical corridors, and excessive backtracking without payoff. **Do NOT design actual story dungeons or place bosses/puzzles.**

## 14. Interior Layout Philosophy
Interiors are allowed to be separate locations. An interior deserves a dedicated map when it is: an important home, a shop with a meaningful interior, an inn, a government building, an academy, a dungeon/facility, or a story location. Not every decorative building needs a full interior.

## 15. Building Exterior → Interior Relationship
Exterior dimensions and interior dimensions do NOT need literal 1:1 geometry, but they should not feel absurdly inconsistent. Establish a believable abstraction standard. Do NOT force huge interiors because an exterior sprite appears large.

## 16. Map Edge Philosophy
Use natural boundaries such as sea, cliff, dense forest, city wall, buildings, inaccessible terrain, terrain elevation, or story-appropriate barriers. Avoid invisible walls in visually open space whenever possible. M66 owns visual/layout intent only. M69 owns final collision.

## 17. Camera-Aware Layout
M66 must ensure layouts can support a follow camera. Avoid spaces that reveal huge voids outside map bounds, create excessively narrow corridors incompatible with viewport framing, require constant artificial camera teleporting, or expose unfinished off-map areas. M70 owns final camera behavior.

## 18. Viewport / Screen Composition
Define how maps should use screen-sized compositions, landmark reveals, entrance framing, plazas/open spaces, and tight spaces without designing around one static screen because camera movement is seamless. Do NOT change viewport settings.

## 19. Player / NPC Scale Awareness
Map corridors, doors, bridges, paths, and navigation spaces must be planned to read correctly against character scale (Base Tile = 32x32, Humanoid body frame = 32x48, Visual overflow up to ~48x64, Feet collision around ~24x16). Do NOT redefine M62 dimensions.

## 20. Walkable Width Language
Define functional spatial categories: NARROW, NORMAL, WIDE / PLAZA. Ensure routes visually support one character, NPC passing, party representation, and encounter staging (where required). Do not overbuild every street into a huge open field.

## 21. Occlusion / Tall Object Planning
Ensure layout does not create large walls of tree canopies, rows of roofs, or giant props that completely hide the player or navigation route. Use tall objects intentionally.

## 22. Exploration Reward Placement Zones
M66 defines WHERE layout should leave room for future treasure, side NPCs, optional scenes, secret paths, and environmental storytelling. **Do NOT create actual rewards/content, assign item IDs, or place chests.**

## 23. Story / Cutscene Space Allowance
Important story locations need sufficient stage space for player, NPC actors, movement, dialogue framing, and entrances/exits, without knowing final blocking yet. Do NOT create actual cutscenes.

## 24. Encounter Space Allowance
Ensure combat-enabled routes are not designed so tightly that future encounter zones become impossible. M72 owns encounter placement. **Do NOT place encounters.**

## 25. Ledge Compatibility
Reserve compatible geometry where later appropriate for elevation differences, cliff edges, and potential climb/drop sections. M73/M74 own ledge mechanics. **Do NOT place final climbable ledges or implement ledges.**

## 26. Transition Handoff to M67
M66 must identify a conceptual LOCATION BOUNDARY. M67 owns actual transition zones, entrances, exits, spawn mapping, fade behavior, return positions, and transition safety. M66 simply says: "this is a location boundary."

## 27. Scene / Technical Organization vs Player Experience
ONE CONTIGUOUS EXPLORABLE PLACE is a PLAYER-EXPERIENCE rule. If a later technical architecture can internally organize one seamless city using multiple child scenes/resources/layers WITHOUT visible transitions, that may be acceptable. The player must experience it as one continuous location. Do NOT require arbitrary loading/fade simply because the editor uses multiple reusable components.

## 28. Whitebox-First Workflow
Recommended sequence:
1. Canon/story requirements
2. Location purpose
3. Critical entrances/exits
4. Required landmarks
5. Primary route
6. Secondary/optional paths
7. District/subarea shape
8. Whitebox
9. Traversal review
10. Story-space review
11. Art handoff
12. Collision/camera/interaction passes later

## 29. Map Review Checklist
- Is this one conceptual location?
- If yes, is it contiguous?
- Are any transitions unnecessary?
- Is the main path readable?
- Are optional paths fair?
- Are landmarks useful?
- Is there excessive empty walking?
- Is the scale compatible with M62?
- Can camera framing work?
- Can future collision work naturally?
- Can story actors fit?
- Can encounters fit where required?
- Are map edges visually believable?
- Are tall assets likely to hide routes?
- Does the location feel region-specific?
- Does it fit the ~10-hour scope?

## 30. Region Production Handoff
- **M66:** Map Layout Production Pipeline
- **M67:** World Transition / Entrance / Exit Pipeline
- **M68:** Final Player Movement Against Production Art
- **M69:** Final Player Collision Against Production Art
- **M70:** Final Camera Behavior
- **M71:** Story / Event Trigger Pipeline
- **M72:** Encounter Placement Pipeline
- **M73/M74:** Ledge mechanics
- **M76:** Elaris Layout Lock
- **M77:** Elaris Tileset + Environment Art
- **M81:** Elaris Collision Pass
- **M82:** Elaris Camera Framing Pass

## 31. Important Scope Rule
M66 establishes HOW maps are designed. It does NOT design all maps. **Do NOT create layouts for Caelora, Elaris island, Lorel, Alexandria, Mongreaux, Kamikoto, Aetherion, dungeons, or routes.**

## 32. Do Not Lock Unsupported Numbers
Do NOT invent exact map pixel sizes, exact tile counts, walking seconds, street widths, city populations, district counts, building counts, or dungeon room counts unless canonical sources require them. Mark unresolved values: **DEFERRED TO REGION LAYOUT LOCK**.
