**Milestone:** M76 — Elaris Layout Lock  
**Status:** DESIGN SPEC LOCKED / WHITEBOX PENDING  
**Production Phase:** Elaris Vertical Slice  
**Primary Location:** Caelora, capital of Elaris

This document is the final spatial/layout specification for M76.

It defines:

- Caelora macro layout
- elevation structure
- district functions
- Prologue traversal
- landmark/navigation logic
- optional exploration budget
- playable boundaries
- whitebox scale direction
- whitebox acceptance criteria

This document does NOT close M76 by itself.

M76 may only become CLOSED after:

1. the Caelora whitebox is implemented,
2. runtime traversal is validated,
3. the acceptance criteria A–T in this document PASS,
4. required manual traversal is completed.

---

# 1. M76 PURPOSE

M76 determines:

> What does Caelora physically look like as a playable place, and how does the player move through it during the Prologue?

This is primarily a LEVEL DESIGN / SPATIAL DESIGN milestone.

It is NOT:

- final environment art,
- final character art,
- final NPC art,
- final dialogue,
- final cutscene implementation,
- final collision polish,
- final camera polish,
- final encounter placement,
- final equipment placement.

Those belong to later milestones.

---

# 2. CORE SCOPE RULE

Caelora must remain compact.

The Prologue should broadly fit a roughly 30–60 minute experience depending on how much the player chooses to look around.

Caelora must NOT become:

- a mini open world,
- a multi-hour exploration region,
- a grinding hub,
- a large side-quest hub,
- a complete playable representation of the entire island of Elaris.

The player only needs enough Caelora to:

1. understand Aren's home,
2. understand his daily routine,
3. meet Glaisa and Lloyd,
4. experience Caelora as a living town,
5. encounter Aelia,
6. complete the first tutorial battle,
7. escort Aelia home,
8. experience the teleportation catastrophe.

The rest of Elaris exists canonically but is NOT required as playable M76 content.

---

# 3. WORLD / CANON CONTEXT

Elaris is a small island country.

Caelora is:

- its capital,
- its main administrative center,
- a coastal settlement,
- Aren and Aelia's home city.

Elaris is not geographically inaccessible by nature.

Its isolation is primarily political.

Caelora should therefore feel:

- small,
- familiar,
- socially close-knit,
- modest,
- locally functional,
- superficially safe,
- limited rather than ruined.

Caelora must NOT look like:

- a huge metropolis,
- a giant military fortress,
- an abandoned city,
- a rich international port,
- a massive fantasy capital.

---

# 4. GLOBAL MAP STRUCTURE

The locked macro structure of Caelora is:

```text
                       ROYAL RESIDENCE
                    / GOVERNMENT GROUNDS
                           LEVEL 3
                              │
                              │
                         upper road
                              │
                        CENTRAL PLAZA
                         + FOUNTAIN
                           LEVEL 2
                       /              \
                      /                \
             RESIDENTIAL              MARKET
               LEVEL 2                LEVEL 2
              /       \                   │
        Aren House   Aelia House      Quiet Alley
                       \                 /
                        \               /
                         \             /
                          GUARD POST
                            LEVEL 1
                               │
                               │
                             HARBOR
                            LEVEL 1
                          /           \
                    ROCKY COAST      BEACH
                                       │
                                 tiny optional secret

~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SEA ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
```

The map primarily reads vertically:

**North / Up**
→ Royal Residence / Government

**Center**
→ Central Plaza

**West / Left**
→ Residential

**East / Right**
→ Market

**South / Down**
→ Guard Post → Harbor → Sea

---

# 5. MACRO SCALE

Caelora must NOT be overly large.

The initial whitebox working range may begin around:

- **90–110 tiles wide**
- **100–120 tiles tall**

Using the locked 32×32 base grid, this is approximately:

- 2880–3520 px wide
- 3200–3840 px tall

IMPORTANT:

These are **WHITEBOX WORKING RANGES**, not permanent canon dimensions.

Do NOT lock exact final width/height until traversal testing proves the pacing works.

The layout should be adjusted if:

- walking feels padded,
- important locations feel too close,
- camera reveals too much,
- story staging does not fit,
- optional exploration becomes excessive.

---

# 6. LOCKED WORLD SCALE

Use the existing production scale.

- Base tile: **32×32 px**
- Standard humanoid body frame: **32×48 px**
- Visual overflow: up to approximately **48×64 px**
- Player/NPC feet collision: approximately **24×16 px**
- Normal door: approximately **32 px**
- Large formal door: approximately **64 px**
- Buildings: modular multiples of 32 px

Do NOT redefine these values in M76.

---

# 7. ELEVATION STRUCTURE

Caelora uses three major spatial elevation bands.

## LEVEL 3 — Upper Caelora

Contains:

- Royal Residence
- Government grounds
- formal courtyard
- small civic/garden area

This is the highest part of the city.

The terrain rises toward the north.

---

## LEVEL 2 — Central Caelora

Contains:

- Central Plaza
- Residential
- Market

These areas are approximately on the same primary elevation.

Minor:

- stairs,
- terrace changes,
- slopes,
- retaining walls

may exist later, but they should not turn Level 2 into multiple confusing height layers.

---

## LEVEL 1 — Coastal Caelora

Contains:

- Guard Post
- Harbor
- Beach

The player moves gradually downhill from the Central Plaza toward this area.

Caelora should therefore feel like:

```text
ROYAL
  ↓
CENTRAL CITY
  ↓
GUARD
  ↓
HARBOR / SEA
```

The elevation change should be readable without becoming mountainous.

---

# 8. COASTLINE STRUCTURE

The Harbor sits inside a small natural bay.

The coastline must NOT be a perfectly straight horizontal line.

Locked arrangement:

```text
                    HARBOR
                  __/     \__
           rocky coast    beach
                            \
                             \
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ SEA
```

## Harbor left side

The left side of Harbor is:

- rocky coast,
- low coastal cliff,
- rough natural terrain.

It is NOT another beach.

---

## Harbor right side

The Beach exists ONLY on the right side of Harbor.

Harbor and Beach are broadly on the same coastal elevation.

The Beach is connected directly to Harbor through a small coastal path.

---

# 9. CENTRAL PLAZA

Central Plaza is the primary navigation hub of Caelora.

It is:

- open,
- moderate in size,
- socially active,
- not enormous.

It must NOT feel like the plaza of a huge metropolis.

## Fountain

The center contains a fountain.

The fountain is the primary LOCAL NAVIGATION LANDMARK.

Around the fountain are several seating areas / benches.

Exact:

- bench count,
- bench positions,
- fountain dimensions

remain ART / WHITEBOX ITERATION decisions.

Do NOT lock arbitrary numbers here.

## Plaza directional logic

From the fountain:

```text
                   Royal
                     ↑
                     │
Residential ←     FOUNTAIN     → Market
                     │
                     ↓
                Guard Post
```

The player should quickly memorize this relationship.

---

# 10. RESIDENTIAL AREA

Residential is located to the left/west of Central Plaza.

Its tone is:

- quieter,
- more personal,
- narrower,
- more domestic than Market.

The area should contain:

- several normal homes,
- small yards or fences,
- domestic space,
- Aren House,
- Aelia House.

It is NOT:

- elite housing,
- slums,
- a huge housing district.

---

## 10.1 Aren and Aelia Houses

Aren House and Aelia House are located on DIFFERENT branches.

Locked concept:

```text
              RESIDENTIAL
              /         \
             /           \
       AREN HOUSE      AELIA HOUSE
```

They are:

- socially close,
- believable for childhood friends,
- not directly adjacent,
- not located at opposite extremes of the map.

Exact branch orientation remains flexible during whitebox construction.

---

## 10.2 Aren House

Aren House is a REQUIRED story location.

The game begins inside it.

A simple interior whitebox is required.

Suggested initial working range:

- approximately 16–20 × 12–16 tiles

This is NOT a final dimension.

The interior only needs enough space for:

- Aren's bedroom,
- small shared/common area,
- kitchen/dining area,
- exit.

Do NOT overbuild:

- multiple unnecessary bedrooms,
- a giant second floor,
- storage maze,
- decorative unused rooms.

---

## 10.3 Aelia House

Aelia House exterior is required.

The Prologue currently ends its Caelora route in front of Aelia House.

The interior is NOT required for M76.

There must be sufficient exterior staging space for:

- Aren,
- Aelia,
- some background residents,
- Aelia moving toward the entrance,
- Aren moving toward Aelia,
- final teleportation staging.

---

# 11. MARKET

Market is located to the right/east of Central Plaza.

It is a combination of:

- permanent small shops,
- several temporary/open stalls.

The Market must feel:

- locally active,
- modest,
- more crowded than Residential,
- commercially readable.

It must NOT feel like:

- an international bazaar,
- a huge trading hub,
- a densely packed metropolis market.

---

## 11.1 Market Shape

Locked form:

```text
Central Plaza
      →
commercial road
      →
road widens
      →
small market pocket
```

This allows:

- storefronts,
- stalls,
- NPC activity,
- service space

without creating a second Central Plaza.

---

# 12. QUIET ALLEY

The first tutorial battle is discovered through a Quiet Alley located beside / behind the Market.

It is NOT in the middle of Market activity.

The structure should read like:

```text
MARKET STREET
      │
      │
 narrow alley
      │
      ▼
 small staging pocket
```

Aren hears a disturbance before seeing the full situation.

The alley entrance should feel narrow.

The interior staging pocket must have enough space for:

- Aren,
- Aelia,
- two aggressors,
- pre-battle dialogue,
- post-battle dialogue.

It must NOT become a huge arena.

The actual battle uses HOLUF's battle system; the world-space pocket only supports story staging.

---

# 13. GUARD POST

Guard Post is located south/downhill from Central Plaza and before Harbor.

It consists of:

- one main medium-small building,
- one small courtyard.

It is NOT:

- a fortress,
- a castle,
- a major military headquarters.

The courtyard is a REQUIRED story staging space.

Aren meets Lloyd here.

The Guard Post interior is NOT required for this Prologue flow.

---

# 14. HARBOR

Harbor is small and controlled.

It contains approximately:

- one main pier,
- one smaller fishing/utility pier,
- one small harbor work area.

Exact pier dimensions remain flexible.

Harbor activity should communicate:

- local fishing,
- limited authorized cargo,
- some workers,
- some guards,
- significant unused/quiet space.

It is NOT abandoned.

It is also NOT a bustling international port.

The isolation of Elaris should be visible through low activity rather than complete abandonment.

---

# 15. BEACH

Beach is located to the right of Harbor.

It is:

- small,
- optional,
- quiet,
- atmospheric.

The Beach is NOT:

- a large exploration map,
- an encounter zone,
- a grinding area,
- a side-quest hub.

Its endpoint should use a natural boundary such as:

- rocky terrain,
- cliff,
- vegetation,
- natural coastline formation.

Do NOT use a visible open-road invisible wall.

---

# 16. ROYAL RESIDENCE / GOVERNMENT AREA

Royal Residence occupies the highest part of Caelora.

It should be a compact prestigious government residence.

Locked components:

- main residence building,
- small formal courtyard,
- limited garden/civic grounds,
- gate / controlled entrance.

It must NOT become:

- a giant castle,
- a fortress,
- a giant royal garden,
- a multi-map palace complex.

---

## 16.1 Player access

During the Prologue, the player may approach the front/gate area.

The player cannot enter the residence interior.

Restriction must be represented naturally through:

- gate,
- guards,
- controlled grounds,
- wall/fencing,
- closed official entrance.

Do NOT use a naked invisible wall.

---

## 16.2 Visual Landmark

Royal Residence is the PRIMARY CITY LANDMARK.

From Central Plaza:

- part of the building / roof / silhouette should be readable.

As the player climbs:

- more of the building is revealed.

Do NOT reveal the entire residence completely from all areas of Caelora.

---

# 17. VISUAL CONTINUATION ROADS

Caelora's playable area represents only part of the full city.

Two primary visual continuation roads are locked:

## Left of Residential

A road visually continues toward additional non-playable Caelora.

## Right of Market

A road visually continues toward additional non-playable Caelora.

These roads:

- are NOT scene transitions,
- are NOT playable routes,
- exist to make Caelora feel larger than the playable slice.

Boundary treatment may use:

- street bends,
- building mass,
- fencing,
- terrain,
- vegetation,
- foreground blocking.

Invisible collision may exist behind the visual boundary.

Do NOT allow the player to hit an invisible wall in the middle of a clearly open road.

---

# 18. LANDMARK-BASED NAVIGATION

Caelora should remain understandable without aggressive UI navigation.

## Navigation hierarchy

### PRIMARY CITY LANDMARK

Royal Residence

Meaning:

- North / upper Caelora.

### PRIMARY LOCAL LANDMARK

Central Fountain

Meaning:

- Center of Caelora.

### SOUTHERN ORIENTATION

Harbor / Sea

Meaning:

- Lower/coastal Caelora.

### LOCAL LANDMARK

Guard Post

Meaning:

- Approaching the coast.

---

# 19. DISTRICT VISUAL LANGUAGE

Even during whitebox, spatial composition should allow later art to distinguish areas.

## Residential

Should read through:

- narrower streets,
- houses,
- smaller domestic spaces,
- calmer composition.

## Market

Should read through:

- slightly wider road,
- storefront space,
- stall space,
- denser activity.

## Plaza

Should read through:

- open central space,
- fountain,
- seating.

## Harbor

Should read through:

- open sky,
- water,
- pier space,
- reduced building density.

Do NOT depend on text labels such as:

- RESIDENTIAL
- MARKET
- HARBOR

for normal player navigation.

---

# 20. PROLOGUE MAIN ROUTE

The final locked Prologue flow is:

```text
AREN HOUSE
│
├─ Glaisa wakes Aren
├─ Player gains control in Aren's bedroom
├─ Player walks to dining/common area
├─ Breakfast: Aren + Glaisa
└─ Glaisa asks Aren to deliver food to Lloyd
        │
        ▼
RESIDENTIAL
        │
        ▼
CENTRAL PLAZA
        │
        ▼
descending road
        │
        ▼
GUARD POST
│
├─ Lloyd is in courtyard
├─ Aren gives Lloyd the food
├─ brief father/son beat
└─ Aren begins normal guard patrol
        │
        ▼
CENTRAL CAELORA
        │
        ▼
MARKET
        │
        ▼
Aren hears a disturbance
        │
        ▼
QUIET ALLEY
│
├─ Aren approaches
├─ discovers Aelia + two aggressors
├─ brief confrontation
└─ tutorial battle begins
        │
        ▼
POST-BATTLE
│
├─ Aren checks on Aelia
└─ offers to escort her home
        │
        ▼
MARKET
        │
        ▼
CENTRAL PLAZA
│
└─ conversation beat around fountain
        │
        ▼
RESIDENTIAL
        │
        ▼
AELIA HOUSE
│
├─ final conversation
├─ Aelia begins moving toward her door
├─ atmosphere changes
├─ sky darkens
├─ distant northern phenomenon appears
├─ residents react
├─ light reaches Elaris
├─ Aren and Aelia move toward one another
├─ Aren almost reaches Aelia's hand
├─ light consumes them
├─ WHITEOUT
└─ BLACK
        │
        ▼
UNKNOWN SOUTHERN MAINLAND BEACH
│
├─ Aren wakes alone
├─ no NPC present
├─ Aren looks for Aelia
├─ begins realizing his family / residents are missing
├─ player control returns
├─ very small beach traversal
└─ player begins moving inland
        │
        ▼
PROLOGUE END
        │
        ▼
ARC 1 / LOREL HANDOFF
```

---

# 21. FIRST PLAYER CONTROL

The player first gains control:

> Inside Aren's bedroom immediately after Glaisa wakes him.

The player then walks to the dining area.

This allows basic movement to be learned naturally before leaving the house.

Do NOT turn Aren House into a long tutorial dungeon.

---

# 22. BREAKFAST STRUCTURE

Breakfast includes only:

- Aren
- Glaisa

Lloyd has already left for work.

The scene exists to:

- establish normal family life,
- introduce Glaisa,
- provide the food-delivery objective,
- establish the day as initially ordinary.

Do NOT use this scene for heavy world exposition.

Final dialogue belongs to later story/dialogue production.

---

# 23. LLOYD / GUARD POST BEAT

Aren meets Lloyd in the Guard Post courtyard.

No Guard Post interior is required.

The food handoff should be:

- short,
- natural,
- family-oriented.

Lloyd then sends Aren on his normal patrol duty.

Patrol is NOT a special quest.

Do NOT use:

- Patrol Point 1,
- Patrol Point 2,
- Patrol Point 3,
- checklist-style MMO patrol structure.

---

# 24. PATROL ROUTE

After Guard Post, the patrol moves back toward:

- central Caelora,
- Market,
- Quiet Alley.

Aren hears the disturbance before seeing Aelia.

Locked sequence:

```text
Patrol
↓
Market area
↓
sound / disturbance cue
↓
player approaches
↓
Quiet Alley
↓
Aelia discovered
```

Do NOT immediately display an objective revealing that Aelia is in danger before Aren knows this.

---

# 25. TUTORIAL BATTLE DISCOVERY

Aren finds Aelia being harassed by two men.

A short confrontation occurs.

The tutorial battle begins.

M76 only reserves the spatial staging.

M89 owns the final battle/cutscene/tutorial implementation.

---

# 26. ESCORT AELIA HOME

After battle:

- player control returns,
- Aelia becomes a story follower,
- there is NO escort failure mechanic.

Aelia should NOT:

- have escort HP,
- cause mission failure when distant,
- require manual commands,
- behave like a fragile escort NPC.

Route:

```text
Quiet Alley
↓
Market
↓
Central Plaza
↓
Residential
↓
Aelia House
```

---

# 27. AREN + AELIA CONVERSATION PACING

Conversation occurs in a few short beats rather than constant dialogue.

One major conversation beat occurs near the Central Plaza fountain.

Topics gradually shift from:

1. the harassment incident,
2. everyday life,
3. Aren's desire to see the outside world,
4. Aelia's desire to study magic outside Elaris.

Final dialogue wording is NOT part of M76.

---

# 28. TELEPORTATION STAGING

Teleportation begins only after Aren and Aelia reach Aelia House.

There should be no major warning during the escort route.

Locked escalation:

```text
normal farewell
↓
Aelia moves toward door
↓
atmosphere changes
↓
sky darkens
↓
distant northern light appears
↓
nearby residents react
↓
phenomenon reaches Elaris
↓
Aren / Aelia move toward one another
↓
Aren almost reaches Aelia
↓
WHITEOUT
↓
BLACK
```

The phenomenon does NOT physically destroy:

- buildings,
- vegetation,
- animals,
- island terrain.

No antagonist appears.

No explanation of Aetherion / Lucien / teleportation technology occurs here.

---

# 29. AFTERMATH HANDOFF

After black:

- ocean ambience begins,
- Aren wakes alone on an unfamiliar southern mainland beach.

At first:

- no NPC is present,
- Aren does not know the location is Lorel,
- Aren does not understand the teleportation.

His immediate personal motivation becomes:

- find Aelia,
- find Lloyd,
- find Glaisa,
- find the people of Elaris,
- understand what happened.

Do NOT immediately turn this into:

- save the world,
- defeat the final villain,
- solve Grand Transposition.

The mainland beach belongs conceptually to the Lorel handoff.

M76 must NOT design the full Lorel region.

---

# 30. OPTIONAL EXPLORATION BUDGET

Caelora intentionally has very limited optional exploration.

Allowed optional spaces:

1. Royal Gate
2. Harbor
3. Beach
4. one small Residential side lane
5. one small Market side pocket

That is sufficient.

Do NOT continue adding optional streets during whitebox implementation.

---

# 31. BEACH SECRET

Caelora contains a maximum of ONE tiny optional secret.

Location:

- Beach.

The secret may later contain a small reward.

The reward must NOT be:

- unique permanent stat upgrade,
- important final equipment,
- mandatory skill,
- progression-critical item,
- major missable equipment.

Keep it lightweight.

Final item assignment belongs to later milestones.

---

# 32. NO GRINDING IN CAELORA

Caelora is NOT a grinding region.

Do NOT add:

- random encounters on city streets,
- respawning enemies,
- monster beach farming,
- Gold farming loops,
- dedicated EXP farming.

The tutorial battle is the main required combat event in Caelora.

Normal regional combat progression begins after the Prologue.

---

# 33. NO MAJOR SIDE QUESTS

Do NOT create:

- quest chains,
- quest board,
- large delivery side quests,
- optional dungeon,
- large NPC subplots.

Optional NPC interactions may exist later as brief worldbuilding.

The Prologue must remain focused.

---

# 34. ROAD WIDTH LANGUAGE

Initial whitebox guidance:

## Quiet / Residential road

Approximately:

- 3–4 walkable tiles

## Standard city road

Approximately:

- 4–5 walkable tiles

## Plaza → Guard primary road

Approximately:

- 5–6 walkable tiles

## Market main street

Approximately:

- 5–7 walkable tiles

## Quiet Alley entrance

Approximately:

- 2–3 walkable tiles

These are working guidelines.

Adjust when runtime traversal proves necessary.

Do NOT treat them as immutable canon.

---

# 35. PROVISIONAL AREA SIZE RANGES

Use only as whitebox starting ranges.

| Area                      | Starting Whitebox Range |
| ------------------------- | ----------------------- |
| Royal/Government grounds  | ~26–32 × 18–22 tiles    |
| Central Plaza             | ~20–26 × 16–20          |
| Residential playable core | ~30–38 × 28–34          |
| Market playable core      | ~30–38 × 26–32          |
| Guard Post + courtyard    | ~18–22 × 16–20          |
| Harbor ground             | ~28–36 × 18–24          |
| Beach                     | ~22–30 × 14–18          |
| Quiet Alley staging       | ~10–14 × 8–12           |
| Aren House interior       | ~16–20 × 12–16          |

These numbers may change during whitebox traversal review.

Do NOT call a deviation a design violation if the change improves pacing while preserving the locked spatial relationships.

---

# 36. WHITEBOX ART RULE

M76 whitebox should use primitives / placeholders.

Examples:

- Polygon2D,
- ColorRect-like debug shapes where appropriate,
- placeholder TileMap/TileMapLayer if already production-compatible,
- simple labels/markers,
- primitive collision.

Do NOT begin M77 art work inside M76.

No:

- final buildings,
- final trees,
- final road textures,
- final coast art,
- final props,
- final NPC sprites,
- final Aren/Aelia sprites.

M76 tests SPACE, not visual polish.

---

# 37. CRITICAL STORY STAGING SPACES

Whitebox must explicitly reserve usable space for:

1. Aren House interior
2. Guard Post courtyard
3. Quiet Alley staging pocket
4. Central Fountain conversation area
5. Aelia House front / teleportation staging

If any one of these cannot support its story beat, the whitebox is NOT acceptable.

---

# 38. CAMERA-AWARE COMPOSITION

The existing production camera behavior must remain the baseline.

Do NOT redesign camera architecture simply to make a bad layout work.

The whitebox should support:

- partial Royal Residence reveal,
- Central Plaza orientation,
- gradual sea reveal,
- building-mass occlusion,
- Harbor opening into wider visual space.

From Central Plaza, the player should NOT see:

- Aren House,
- Aelia House,
- entire Market,
- Guard Post,
- Harbor,
- Beach

all simultaneously.

Use:

- building mass,
- road bends,
- terrain,
- elevation

to create spatial reveals.

---

# 39. SEAMLESS CITY RULE

Caelora exterior is ONE continuous playable location.

There must be NO loading/fade between:

- Residential,
- Central Plaza,
- Market,
- Guard Post,
- Harbor,
- Beach,
- Royal Gate exterior.

Valid transitions include:

- outdoor → Aren House interior,
- outdoor → another meaningful building interior if later required,
- story teleportation → mainland beach.

District boundaries are NOT map transitions.

---

# 40. PLAYABLE BOUNDARIES

## Residential west/left

Use:

- road bend,
- buildings,
- vegetation,
- terrain

to imply continuation.

Collision may exist behind visual coverage.

## Market east/right

Same principle.

## Royal north

Use:

- controlled government gate,
- guards,
- walls/fencing.

## Harbor south

Use sea.

## Harbor west

Use rocky coastal terrain.

## Beach east/right

Use natural rocky/cliff/vegetation endpoint.

Do NOT use unexplained open-space invisible walls.

---

# 41. WHITEBOX TRAVERSAL ACCEPTANCE GATE

All criteria A–T must PASS before M76 can close.

## A. Macro Layout Readability

PASS if:

- Plaza reads as center.
- Residential = left.
- Market = right.
- Government = north/up.
- Guard/Harbor = south/down.

FAIL if:

- map feels like disconnected boxes,
- player repeatedly becomes disoriented.

---

## B. Aren House → Guard Post Route

PASS if:

- route is readable,
- not overly long,
- introduces Residential and Fountain naturally,
- permits minor optional deviation.

FAIL if:

- overly long,
- too maze-like,
- excessively linear corridor,
- impossible to understand without large marker.

---

## C. Fountain Navigation

PASS if:

- Fountain becomes a reliable mental anchor.

FAIL if:

- hidden,
- visually insignificant,
- not useful for orientation.

---

## D. Royal Residence Landmark / Reveal

PASS if:

- partially readable from Plaza,
- clearer when climbing.

FAIL if:

- completely visible everywhere,
- impossible to see until immediately in front.

---

## E. Sea / Harbor Reveal

PASS if:

- sea becomes progressively visible when descending.

FAIL if:

- entire Harbor is visible immediately from Plaza,
- coastal reveal feels spatially disconnected.

---

## F. Residential Traversal

PASS if:

- intimate,
- readable,
- Aren/Aelia branches distinct,
- not maze-like.

FAIL if:

- oversized,
- confusing,
- excessive dead ends.

---

## G. Market Traversal

PASS if:

- wider/more active than Residential,
- pocket works without becoming another Plaza,
- Quiet Alley remains accessible.

FAIL if:

- Market becomes huge,
- too many branches,
- indistinguishable from Residential.

---

## H. Quiet Alley Staging

PASS if:

- entrance feels narrow,
- interior staging fits Aren/Aelia/two aggressors.

FAIL if:

- alley is too open,
- characters overlap,
- staging pocket feels like giant arena.

---

## I. Escort Route

PASS if:

- Quiet Alley → Market → Fountain → Residential → Aelia House feels natural,
- route provides room for dialogue beats.

FAIL if:

- too short,
- padded,
- awkwardly loops,
- follower path is unreliable.

---

## J. Aelia House Staging

PASS if:

- exterior supports farewell and teleportation blocking.

FAIL if:

- too cramped,
- camera cannot frame characters/phenomenon.

---

## K. Guard Courtyard

PASS if:

- Aren/Lloyd interaction fits comfortably,
- courtyard still feels small/modest.

FAIL if:

- military parade ground scale,
- too cramped.

---

## L. Harbor / Beach Flow

PASS if:

- Harbor readable from Guard area,
- Beach connection natural,
- both compact.

FAIL if:

- Harbor oversized,
- Beach becomes long empty walk.

---

## M. Optional Exploration Budget

PASS if:

- optional exploration remains limited to locked spaces.

FAIL if:

- additional districts/streets continue being added.

---

## N. Dead-End Quality

PASS if every meaningful dead end has:

- NPC,
- environmental payoff,
- story function,
- view,
- secret,
- or believable visual continuation.

FAIL if:

- long path ends at meaningless wall.

---

## O. Visual Reveal / Building Mass

PASS if:

- map has spatial depth,
- districts are not all visible simultaneously.

FAIL if:

- Caelora reads as one flat open rectangle.

---

## P. Elevation Readability

PASS if:

- player feels movement upward toward Royal,
- downward toward sea.

FAIL if:

- all levels feel physically identical.

---

## Q. Character-Scale Compatibility

PASS if:

- paths,
- doors,
- alley,
- courtyard,
- plaza

work with current 32×48 humanoid and ~24×16 feet collision scale.

FAIL if:

- player constantly snags,
- spaces are absurdly oversized.

---

## R. Camera Compatibility

PASS if:

- existing production camera can frame all critical spaces.

FAIL if:

- M70 needs architecture changes solely to rescue the layout.

---

## S. Story / Optional Route Safety

PASS if:

- optional movement cannot break story triggers,
- player cannot enter staging areas from invalid sides,
- escort path remains safe.

FAIL if:

- exploration lets player bypass story ordering.

---

## T. Prologue Pacing

PASS if:

- Caelora feels like Aren's home,
- the city feels sufficiently lived-in,
- Prologue does not become a multi-hour region.

FAIL if:

- walking dominates the opening,
- exploration overwhelms story progression.

---

# 42. REQUIRED MANUAL TEST

M76 requires one focused manual traversal after whitebox implementation.

This manual test is REQUIRED because these cannot be proven reliably from static inspection alone:

- perceived travel distance,
- navigation clarity,
- plaza scale,
- Market/Residential distinction,
- escort route feel,
- landmark readability,
- Harbor/Beach pacing,
- camera reveal quality.

Do NOT close M76 before this traversal is complete.

---

# 43. MANUAL TEST ROUTE

Tester should perform:

## Run A — Direct Story Route

1. Start inside Aren House.
2. Leave house.
3. Travel through Residential.
4. Reach Central Plaza.
5. Reach Guard Post.
6. Begin patrol.
7. Travel to Market.
8. Approach Quiet Alley.
9. Simulate/post tutorial progression.
10. Travel Quiet Alley → Market → Plaza → Residential → Aelia House.

Check:

- clarity,
- distance,
- pacing.

---

## Run B — Optional Exploration

From the normal story route, briefly inspect:

1. Royal Gate.
2. Residential side lane.
3. Market side pocket.
4. Harbor.
5. Beach.
6. Beach secret location.

Check that the optional content remains compact.

---

## Run C — Navigation Memory

After basic familiarity:

- return to Fountain,
- navigate to Residential without marker,
- return to Fountain,
- navigate to Market,
- navigate toward Guard Post,
- navigate toward Royal Gate.

PASS if orientation remains intuitive.

---

# 44. M76 SCOPE PROHIBITIONS

M76 must NOT:

- create final tileset art,
- create final environment sprites,
- create final Aren art,
- create final Aelia art,
- create final NPC art,
- create final weapon art,
- mass-create equipment resources,
- write final Prologue dialogue,
- implement final teleport VFX,
- design full Lorel,
- create new Elaris settlements,
- create optional dungeon,
- create grinding area,
- add major side quests,
- redesign player movement,
- redesign camera architecture,
- redesign collision architecture,
- rewrite battle systems,
- redesign save/load.

If a layout problem requires changes to one of those systems, STOP and report it rather than silently changing unrelated architecture.

---

# 45. PROLOGUE STORY UPDATE NOTE

The current detailed M76 direction expands the opening sequence to:

```text
Aren wakes at home
→ breakfast with Glaisa
→ delivers food to Lloyd
→ begins patrol
→ discovers Aelia
```

This is more detailed than the older Prologue summary that begins with Aren already patrolling.

The final canonical Prologue document must eventually be synchronized with this newer locked direction so the repository does not maintain two contradictory opening versions.

Do NOT rewrite the entire Prologue during whitebox construction unless explicitly scoped.

---

# 46. ART HANDOFF TO M77

M76 hands M77:

- fixed district relationships,
- elevation hierarchy,
- road hierarchy,
- coastline structure,
- landmark hierarchy,
- building-mass zones,
- story staging spaces,
- natural map boundaries,
- optional exploration zones.

M77 then owns:

> Elaris Tileset + Environment Art

M77 may decide:

- final terrain appearance,
- architecture appearance,
- road texture,
- coast texture,
- vegetation,
- building visual style,
- props,
- decorative environment composition.

M77 must NOT casually alter M76's locked spatial relationships without reopening layout review.

---

# 47. M76 CLOSURE RULE

M76 can become:

**M76 — CLOSED / PASS**

only when:

- whitebox exists,
- all critical areas are represented,
- direct story traversal works,
- optional exploration remains within scope,
- acceptance criteria A–T PASS,
- manual whitebox traversal PASS,
- no unrelated systems were silently redesigned.

Until then:

**M76 remains OPEN / WHITEBOX PENDING.**

---

# 48. FINAL M76 LAYOUT LOCK SUMMARY

Caelora is a compact, seamless coastal capital built on three broad elevation levels.

At its highest point stands the Royal Residence / Government Seat.

Below it lies Central Plaza with a fountain that functions as the city's main navigation landmark.

Residential lies to the west/left and contains separate branches for Aren House and Aelia House.

Market lies to the east/right and uses a commercial street that widens into a small market pocket.

A Quiet Alley beside/behind Market hosts the first story confrontation with Aelia and two aggressors.

South of Central Plaza, terrain descends toward the Guard Post, then Harbor.

Harbor is a small restricted/local port inside a natural bay.

Rocky coast occupies Harbor's left side.

A small Beach exists only to Harbor's right and contains the Prologue's only tiny optional secret.

Caelora gives the player limited freedom but remains strongly story-directed.

The primary Prologue route is:

Aren House
→ Residential
→ Central Plaza
→ Guard Post
→ Patrol
→ Market
→ Quiet Alley
→ Tutorial Battle
→ Market
→ Central Plaza
→ Residential
→ Aelia House
→ Teleportation
→ Unknown Mainland Beach
→ Lorel handoff.

Caelora must feel like a believable home that the player understands before it is suddenly emptied of its people.

The design priority is not size.

The priority is:

**familiarity, readability, story pacing, and emotional contrast.**

```


```
