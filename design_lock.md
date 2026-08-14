# Holuf — Pre-M35 Design Lock

**Purpose:** Master implementation guardrail + source-of-truth index for Holuf.

This file is the **entry point for AI coding agents**.  
It does **not** replace the detailed modular design documents already stored in the project.

If implementation conflicts with a locked design decision:
> **Stop and report the conflict. Do not silently redesign the game to fit the existing code.**

---

# 0. Source-of-Truth Structure

Holuf uses **modular design documents**, not one giant GDD.

## Story Source
Use:
- `story/prologue.md`
- `story/story_arc_1.md`
- `story/story_arc_2.md`
- `story/story_arc_3.md`
- `story/story_arc_4.md`
- `story/story_final_arc.md`
- `story/the_architect_finalpass.md`

## Character Source
Use:
- `identity_character/character_final_pass.md`
- `identity_character/Aren_1.md`
- `identity_character/Aelia_2.md`
- `identity_character/lyra_3.md`
- `identity_character/doran_4.md`
- `identity_character/neria_5.md`
- `identity_character/torga_6.md`
- `identity_character/katsura_7.md`
- `identity_character/kaelis_8.md`
- `identity_character/sylven_9.md`
- `identity_character/orin_10.md`

## Character Combat Source
Use:
- `identity_character/character_combat_pass.md`
- `identity_character/skill_kit_pass.md`
- `identity_character/beast_system.md`

## World Source
Use:
- `world_building/elaris.md`
- `world_building/lorel.md`
- `world_building/alexandria.md`
- `world_building/mongreaux.md`
- `world_building/kamikoto.md`
- `world_building/valeria.md`
- `world_building/averon.md`
- `world_building/ravaryn.md`
- `world_building/kharuun.md`
- `world_building/aetherion.md`
- `world_building/king_vaelor.md`

## Combat Source
Use:
- `combat_philosophy_final_pass.md`
- `numerical_balance_pass.md`

## Scope Source
Use:
- `10_hour_scope_pass.md`

---

# 1. Consistency Documents Are Audits, Not Canon Sources

Files such as:

- `identity_character/Character_Consistency_Pass.md`
- `world_building/story_consistency_pass.md`
- `world_building/world_consistency_pass.md`

are **audit/check documents**.

They may detect contradictions, but they are **not the final source-of-truth**.

When an audit leads to a design decision:
> copy/update that final decision into the relevant story/world/character/combat source document.

Do not leave a final canon change only inside a consistency-pass file.

---

# 2. Status Vocabulary

## FINAL / LOCKED
Cannot be redesigned or changed without explicit design approval.

## FINAL CONCEPT / WORKING NAME
Mechanic/story/world function is locked, but displayed name may still change.

## V1 BASELINE
Approved starting balance values. May be tuned after real playtesting.

## DEFERRED
Intentionally not finalized. AI must not invent a permanent final answer.

---

# 3. Project Direction — LOCKED

- Godot 4.x
- 2D turn-based RPG
- top-down world
- main story target ~10 hours
- active party 1–4, max 4
- total playable roster = 10
- no playable character #11 in Final Arc

Core combat identity:
**Weakness + Break + Boost + speed queue + party composition + persistent HP/MP resource management**

---

# 4. Core Theme — LOCKED

**Freedom by Choice**

- King Vaelor = **Order Without Choice**
- Lucien Varell / The Architect = **Freedom Without Choice**
- Aren = **Freedom by Choice**

---

# 5. Story Route — LOCKED

Prologue Elaris  
→ Lorel  
→ Alexandria  
→ Mongreaux  
→ Kamikoto  
→ Aetherion  
→ Ending

Main story does not directly visit:
- Valeria
- Averon
- Ravaryn
- Kharuun

Mystery escalation must remain:

1. unexplained displacement,
2. artificial spatial pattern,
3. intentional targeting,
4. Elaris test + Vaelor involvement,
5. Lucien’s full plan / Grand Transposition.

Do not reveal late-game answers early without approval.

---

# 6. World — LOCKED

Macro-region:
**Asterra**

Major landmasses:
- Ardoria
- Elaris
- Kharuun
- Aetherion

Nine countries:
1. Elaris
2. Lorel
3. Alexandria
4. Mongreaux
5. Kamikoto
6. Valeria
7. Averon
8. Ravaryn
9. Kharuun

Aetherion is **not a country**.

Locked principle:
**Race ≠ nationality.**

---

# 7. Playable Roster — LOCKED

| Character | Age | Race | Origin | Weapon | Element |
|---|---:|---|---|---|---|
| Aren | 20 | Human | Elaris | Sword | Raw + Fire |
| Aelia | 19 | Human | Elaris | Magicbook | Wind |
| Lyra | 22 | Elf | Lorel | Dagger | Ice |
| Doran | 25 | Human | Alexandria | Claymore | Fire |
| Neria | 21 | Human | Mongreaux | Staff | Water |
| Torga | 27 | Beast | Kharuun | Axe | Earth |
| Katsura | 24 | Human | Kamikoto | Katana | Ice |
| Kaelis | 23 | Human | Valeria | Spear/Lance | Lightning |
| Sylven | 26 | Elf | Averon | Bow | Wind |
| Orin | 30 | Beast | Ravaryn | Longsword | Fire |

Do not:
- change race,
- change origin,
- change weapon,
- change element,
- change age,
- remove playable characters,
- add playable character #11,

without explicit design approval.

---

# 8. Combat Roles — LOCKED

- Aren — reliable balanced physical DPS
- Aelia — magic tempo/support
- Lyra — fast debuffer/skirmisher
- Doran — heavy Broken-window finisher
- Neria — primary healer/sustain
- Torga — defensive bruiser / guard-counter
- Katsura — precision/counter
- Kaelis — initiative burst
- Sylven — tactical ranged utility
- Orin — sustained offensive bruiser

Do not solve technical difficulty by changing these identities.

---

# 9. Break — LOCKED

Weakness:
- damage ×1.25
- BREAK -1 exactly

Non-weak:
- no Break reduction

Trigger hit reaching BREAK 0:
- does not receive Broken multiplier

Broken:
- skips one enemy scheduled action
- remains Broken during player attack window
- recovers at following scheduled enemy turn

Broken multiplier:
- Normal: 1.30
- Mini-boss: 1.20
- Boss: 1.10

Break Bonus:
- Armor Shatter — 40%
- Disorient — 35%
- Deep Stagger — 25%

Deep Stagger:
- Normal/Mini-boss: extra offensive player action window
- Boss: no extra action; +0.05 Broken multiplier

Boost never increases hit count or Break reduction.

---

# 10. Boost — LOCKED

Battle start:
- BP1 per active character

Max:
- BP3

Natural turn 2+:
- +1 BP at valid scheduled natural-turn start

No BP from:
- KO skipped turn
- Deep Stagger extra action
- attacking
- taking damage
- round progression
- queue manipulation

Boost multipliers:
- 0 = 1.00
- 1 = 1.25
- 2 = 1.50
- 3 = 2.00

Spend BP only after successful action.

Boost does not:
- add hit count
- change MP cost
- extend buff/debuff duration
- create extra targets

---

# 11. Defend / Persistence / Flee — LOCKED

Defend:
- 50% incoming damage reduction
- lasts until character’s next natural turn begins

HP/MP:
- persist after battle
- persist after victory
- persist after level-up
- persist after party swap

Items:
- Potion +50 HP
- Spirit Tonic +20 MP
- starting inventory 5 / 3
- stack limit 99

Flee:
- 70% normal success rate
- failure consumes action

---

# 12. Enemy HUD — LOCKED

Do not show:
- HP number
- HP bar

Show:
- name
- BREAK
- discovered weakness
- active effects

Health state:
- Healthy
- Wounded
- Critical

---

# 13. BEAST — LOCKED FOUNDATION

Playable users:
- Torga
- Orin

Command:
**BEAST**

Rules:
- 1 use per Beast character per battle
- consumes MP
- can use Boost
- no extra Beast gauge
- no persistent summon
- no summon HP
- no summon turn queue
- follows normal weakness/Break/affinity
- swap does not refresh use
- KO/revive does not refresh if already used
- multi-phase boss does not refresh
- new battle resets use

Torga:
- Earth defensive manifestation direction

Orin:
- Fire sustained-offense/self-sustain manifestation direction

**Beast Manifestation** = WORKING term.

Deferred:
- final manifestation names
- exact MP cost
- exact coefficient
- exact utility values
- final VFX/animation

BEAST implementation must be handled as a **separate implementation task**, not bundled into roster migration.

---

# 14. Skill Kits — LOCKED FUNCTIONS

Each playable character targets approximately:
**6 meaningful normal skills**

Torga/Orin additionally get BEAST.

Approved kit functions are stored in:
`identity_character/skill_kit_pass.md`

Elemental spell family names are LOCKED:

- Pyris / Pyria / Pyralis / Pyralia
- Aquis / Aquia / Aqualis / Aqualia
- Cryis / Cryia / Cryalis / Cryalia
- Fulgis / Fulgia / Fulgalis / Fulgalia
- Aeris / Aeria / Aeralis / Aeralia
- Terris / Terria / Terralis / Terralia

Most martial skill names remain **WORKING NAMES** unless explicitly promoted to final canon.

Do not:
- add dozens of extra skills,
- invent character-specific gauges,
- redesign character combat roles.

---

# 15. Numerical Balance — V1 BASELINE

Source:
`numerical_balance_pass.md`

Balance numbers are approved **starting values**, not immutable canon.

Hard constraints are relative identity:

- Doran = among highest ATK, among lowest SPD
- Torga = highest durability
- Lyra/Kaelis = very fast
- Aelia/Neria = strongest magic profiles
- Aren = balanced
- Orin = high ATK + durable sustained profile

Target encounter pacing:
- regular battle: ~2–4 natural rounds
- elite: ~3–6
- boss: ~6–10
- no mandatory grinding
- Final Boss expected roughly Lv20–22

Do not call numerical balance “final” until it has been playtested.

---

# 16. Lucien Varell / The Architect — LOCKED

- Name: **Lucien Varell**
- Title: **The Architect**
- Human
- age 46
- origin Mongreaux
- former Academy Mongreaux spatial researcher/theorist

Core ideology:
Birthplace, nation, and inherited structures constrain freedom.

Core contradiction:
Attempts to create freedom by removing consent.

He is:
- calm
- intelligent
- persuasive
- controlled
- not sadistic
- not secretly related to Aren/Aelia
- not controlled by Spatial Core
- not a chosen/royal bloodline twist

**Grand Transposition** = WORKING NAME; concept is locked.

Final Phase 2:
Lucien voluntarily links himself to the Spatial Core instead of stopping the plan.

---

# 17. King Vaelor — LOCKED

- King of Elaris at story start
- knowingly approved the experiment
- knew citizens would be test subjects
- supplied population/family/residential data
- enabled access/anchors/protection
- expected technology/resources/economic/political benefit
- did not know Lucien’s full Grand Transposition plan
- believed citizens could eventually be returned
- secretly evacuated to Aetherion before mass teleport
- evacuation cinematic is revealed late, not in Prologue
- not a boss
- not playable
- no instant redemption
- survives
- detained
- stripped of kingship
- never returns to power
- faces tribunal/trial

Exact tribunal name and legal sentence:
**DEFERRED**

---

# 18. Lloyd — LOCKED

- story NPC companion
- never playable
- guilt arc about following orders without enough questioning
- confronts Vaelor in Aetherion
- dies saving Aren from collapsing structure
- death is a conscious protective choice
- death is not punishment or atonement

Do not turn Lloyd into playable character or boss.

---

# 19. Main-Story Scope — LOCKED TARGET

Target pacing:
- Prologue: 35m
- Lorel: 80m
- Alexandria: 90m
- Mongreaux: 100m
- Kamikoto: 150m
- Aetherion: 120m
- Ending: 25m

Target total:
~10 hours

This is a pacing target, not a hard timer.

Production rule:
> World lore may be larger than playable content.

Do not build every country/capital simply because it exists in world-building documents.

---

# 20. Implementation Document Bundles

Use `design_lock.md` on every important implementation task.

Then add only the documents relevant to that task.

## A. Roster Migration

Send:
- `design_lock.md`
- `identity_character/character_final_pass.md`
- relevant individual character files

Add:
- `numerical_balance_pass.md` only if base combat stats are required

Implement:
- final identities
- CharacterData / CombatantData migration
- resource rename/reference cleanup
- validation of all 10 characters

Do not implement:
- BEAST
- broad combat refactor
- final skill kit
- story/cutscenes

---

## B. Skill Implementation

Send:
- `design_lock.md`
- `identity_character/skill_kit_pass.md`
- `combat_philosophy_final_pass.md`
- `numerical_balance_pass.md`

If needed:
- `identity_character/character_combat_pass.md`

Implement only the approved skill scope.

Numerical values from balance docs are V1 and must remain easy to tune.

---

## C. BEAST Implementation

Send:
- `design_lock.md`
- `identity_character/beast_system.md`
- `identity_character/character_combat_pass.md`

If skill/action data structure is relevant:
- `identity_character/skill_kit_pass.md`
- `numerical_balance_pass.md`

Required behavior:
- BEAST command visible only for eligible Beast characters
- per-character once-per-battle usage
- MP validation/consumption
- Boost integration
- correct battle reset rules

Do not create:
- permanent summon units
- Beast gauge
- summon HP/turn queue
- collection system

---

## D. Story / Cutscene Arc 4

Send:
- `design_lock.md`
- `story/story_arc_4.md`
- `story/the_architect_finalpass.md`
- `world_building/king_vaelor.md`

If scene references Kamikoto lore:
- `world_building/kamikoto.md`

Implement only the approved story/cutscene scope.

Do not reveal Arc 5 information earlier than the story source allows.

---

# 21. Recommended Implementation Order

After this design lock exists, implement one task at a time:

1. **Roster/resource migration**
2. Manual test
3. Fix regression
4. Commit/push stable checkpoint
5. **Skill data / skill implementation**
6. Manual test
7. Commit/push
8. **BEAST implementation**
9. Manual test
10. Commit/push
11. Story/cutscene implementation per arc when relevant

Do not batch all of these into one large task.

---

# 22. Development Workflow — LOCKED PROCESS

Use:

> **1 task → implement → manual test → fix → commit/push → next task**

Do not proceed to the next major implementation task while the current task has known regressions.

---

# 23. AI Coding Guardrail — REQUIRED

Include this in important coding prompts:

> **Do not redesign locked gameplay, story, world, or character decisions. If implementation reveals a conflict with a locked design decision, report the conflict instead of silently changing the design. Keep unrelated systems untouched.**

Also instruct:

> **Implement only the requested task. Do not pre-implement the next milestone or perform broad refactors unless required to complete the current task safely.**

Recommended coding model:
- **Gemini Pro**
- Fallback: **Gemini Flash**

Task difficulty should be stated in each implementation prompt.

---

# 24. File Naming Guidance

Prefer consistent lowercase snake_case filenames where practical.

Examples:
- `elaris.md`
- `lorel.md`
- `character_consistency_pass.md`

Do not perform mass renaming only for cosmetic reasons during unrelated implementation tasks.

If renaming:
- preserve references,
- preserve UID/resource identity where applicable,
- verify case-sensitive paths.

---

# 25. Current Implementation Boundary

Current active implementation:
**Roster/resource migration and validation**

Allowed:
- rename placeholder character resources to final character names
- remove obsolete DWARF/ONI references after checking dependencies
- populate all 10 final character identities
- use approved V1 CombatantData values
- update references safely
- verify all 10 resources load
- regression-test existing party/equipment/skill ownership behavior

Not in current task:
- BEAST implementation
- broad BattleController redesign
- complete skill implementation
- final balance tuning
- story/world redesign

Finish current task first.

---

# 26. Pre-M35 Readiness

Design foundations:
- Story backbone: LOCKED
- Story consistency: PASS
- World structure: LOCKED
- World consistency: PASS
- 10 playable characters: LOCKED
- Ages/races/origins/weapons/elements: LOCKED
- Character arcs: LOCKED
- Combat roles: LOCKED
- Break: LOCKED
- Boost: LOCKED
- Beast foundation: LOCKED
- Combat philosophy: LOCKED
- Skill-kit functions: LOCKED
- Numerical balance: V1 BASELINE
- Main-story scope: LOCKED TARGET
- Lucien Varell / The Architect: LOCKED
- King Vaelor fate: LOCKED
- Lloyd fate: LOCKED

**PRE-M35 DESIGN FOUNDATION: READY**

M35 should open only after the current roster/resource migration is:
1. completed,
2. manually tested,
3. regression-safe,
4. committed/pushed.
