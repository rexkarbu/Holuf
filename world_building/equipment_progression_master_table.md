# HOLUF Equipment Progression + Regional Gear Master Table — M75.75

## 1. Purpose
This document establishes the canonical equipment progression design for HOLUF's ±10-hour campaign. It locks the weapon progression for all 10 playable characters and the framework for Head, Body, and Accessory gear. This is a DESIGN/MASTER-TABLE source of truth to guide future resource generation.

## 2. Canon / Implementation Baseline
- **Combat Formula**: Normal attacks use ATK vs DEF. Magic attacks (if applicable) use MAG vs MDEF. Weapons provide flat stat bonuses.
- **Current System**: 4 Slots (Weapon, Head, Body, Accessory). Compatibility is checked via `CharacterIdentity.WeaponType` and `CharacterData.allowed_weapon_types`. Non-weapon gear is universal.
- **Campaign Length**: ±10 hours, targeting Lv 20-22 at the final boss without grinding.

## 3. Current Prototype Equipment Classification
Existing prototype `.tres` files in `data/equipment/` are classified as follows (do NOT delete them):
- `training_sword.tres` → **REPURPOSE** (Starter weapon for Aren)
- `training_bow.tres` → **REPURPOSE** (Starter weapon for Aelia)
- `leather_cap.tres` → **REPURPOSE** (Early Head gear)
- `leather_armor.tres` → **REPURPOSE** (Early Body gear)
- `health_charm.tres` → **REPURPOSE** (Starter/Early Accessory)
- `copper_ring.tres` → **REPURPOSE** (Early Accessory)

## 4. Playable Weapon Compatibility Matrix
*Note: Currently all `.tres` files have empty `[]` for unrestricted fallback. This table reflects the canonical identity to be enforced.*

| Character | Primary Role | Allowed Weapon Types | Shared Family? | Combat-Stat Emphasis |
| :--- | :--- | :--- | :--- | :--- |
| **Aren** | Balanced Physical | SWORD | No | ATK, HP |
| **Aelia** | Magic Tempo | BOW, MAGICBOOK | Yes (Bow with Sylven) | MAG, MP, SPD |
| **Lyra** | Fast Debuff | DAGGER | No | SPD, ATK |
| **Doran** | Heavy Physical | CLAYMORE | No | ATK (Heavy) |
| **Neria** | Primary Sustain | SPEAR, STAFF | Yes (Spear with Kaelis) | MAG, MP, MDEF |
| **Torga** | Defensive Bruiser | AXE | No | HP, DEF, ATK |
| **Katsura**| Precision Counter | KATANA | No | ATK, SPD |
| **Kaelis** | Fast Burst | SPEAR | Yes (Spear with Neria) | ATK, SPD |
| **Sylven** | Tactical Ranged | BOW | Yes (Bow with Aelia) | ATK, SPD |
| **Orin** | Sustained Bruiser| LONGSWORD | No | ATK, HP, DEF |

## 5. Equipment Progression Philosophy
- **Restrained Scaling**: Final weapons should not invalidate character base stats. A Lv20 character naturally has ~35-45 ATK; a final weapon granting +35 ATK appropriately doubles their output without creating an astronomical number.
- **Readable Stats**: Weapons focus on 1 primary stat (e.g., ATK or MAG) and optionally 1 secondary stat (e.g., SPD or DEF).
- **Identity Preservation**: Equipment reinforces the character's role (e.g., Doran gets massive ATK with negative SPD, Torga gets DEF, Lyra gets SPD).

## 6. Tier Framework
| Tier | Level Band | Story Band | Description |
| :--- | :--- | :--- | :--- |
| **STARTER** | Lv 1-2 | Prologue (Elaris) / Join | Basic starting gear, no real economy cost. |
| **EARLY** | Lv 3-7 | Lorel / Alexandria | First major upgrades. Modest stat bumps. |
| **MID** | Lv 8-12 | Mongreaux | Noticeable power jump. Specialized secondary stats appear. |
| **LATE** | Lv 13-17 | Kamikoto | Powerful standard gear. Final purchasable tier. |
| **FINAL** | Lv 18-22 | Aetherion / Endgame | Signature weapons. Character-exclusive or highly specialized. |

## 7. Stat Budget Framework
Expected approximate stat allocations for Weapons (Primary Stat: ATK or MAG):
- **STARTER**: +3 to +5
- **EARLY**: +7 to +12
- **MID**: +14 to +20
- **LATE**: +22 to +28
- **FINAL**: +32 to +40
*Secondary stats (SPD, DEF, etc.) consume a portion of this budget conceptually (e.g., Doran's Claymore might have +45 ATK but -5 SPD).*

## 8. Price / Economy Framework
*Economy Assumption*: Players will organically find 30-40% of their gear via chests/story. Buying everything for 10 characters is economically impossible without grinding.
- **STARTER**: 0 Gold (Equipped on join)
- **EARLY**: 150 - 250 Gold
- **MID**: 600 - 900 Gold
- **LATE**: 1500 - 2500 Gold
- **FINAL**: Not purchasable

## 9. Acquisition Rules
Allowed labels: `STARTING`, `SHOP`, `CHEST`, `QUEST`, `BOSS`, `STORY`, `OPTIONAL SECRET`.

## 10. Complete Weapon Master Table

| ID | Display Name | Weapon Type | Intended Char(s) | Sig? | Tier | Story Band | ATK | MAG | DEF | MDEF | SPD | HP | MP | Price | Source | Region | Unique? | Final? | Runtime? | Notes |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `wp_swd_01` | Iron Broadsword | SWORD | Aren | No | STARTER | Elaris | +4 | 0 | 0 | 0 | 0 | 0 | 0 | 0 | STARTING | Elaris | No | No | Yes | Replaces training_sword. |
| `wp_swd_02` | Smuggler's Edge | SWORD | Aren | No | EARLY | Lorel | +9 | 0 | 0 | 0 | +1 | 0 | 0 | 200 | SHOP | Lorel | No | No | Yes | - |
| `wp_swd_03` | Knight's Vanguard | SWORD | Aren | No | MID | Mongreaux | +16 | 0 | +3 | 0 | 0 | 0 | 0 | 750 | SHOP | Mongreaux | No | No | Yes | Defensive bruiser edge. |
| `wp_swd_04` | Tsukishiro Blade | SWORD | Aren | No | LATE | Kamikoto | +24 | +5 | 0 | 0 | +2 | 0 | 0 | 1800 | SHOP | Kamikoto | No | No | Yes | Boosts his Fire utility. |
| `wp_swd_05` | Ignition Core | SWORD | Aren | Yes | FINAL | Aetherion | +35 | +12 | +5 | 0 | 0 | +30 | 0 | - | CHEST | Aetherion | Yes | Yes | Yes | Aren's signature. |
| `wp_bow_01` | Hunting Bow | BOW | Aelia | No | STARTER | Elaris | +3 | +2 | 0 | 0 | +1 | 0 | 0 | 0 | STARTING | Elaris | No | No | Yes | Replaces training_bow. |
| `wp_mag_01` | Apprentice Tome | MAGICBOOK| Aelia | No | EARLY | Alexandria | 0 | +10 | 0 | +2 | +2 | 0 | +10| 220 | SHOP | Alexandria | No | No | Yes | Aelia pivots to Magicbook here. |
| `wp_mag_02` | Scholar's Lexicon | MAGICBOOK| Aelia | No | MID | Mongreaux | 0 | +18 | 0 | +4 | +3 | 0 | +20| 800 | SHOP | Mongreaux | No | No | Yes | Tempo/MP focus. |
| `wp_mag_03` | Windweaver Codex | MAGICBOOK| Aelia | Yes | FINAL | Aetherion | +5 | +38 | 0 | +10| +6 | 0 | +40| - | STORY | Aetherion | Yes | Yes | Yes | Aelia's signature magic. |
| `wp_dag_01` | Coastal Dirk | DAGGER | Lyra | No | EARLY | Lorel | +8 | 0 | 0 | 0 | +3 | 0 | 0 | 0 | STARTING | Lorel | No | No | Yes | Lyra join weapon. |
| `wp_dag_02` | Valkenheim Stiletto | DAGGER | Lyra | No | EARLY | Alexandria | +11| 0 | 0 | 0 | +5 | 0 | 0 | 250 | SHOP | Alexandria | No | No | Yes | Pure speed/attack. |
| `wp_dag_03` | Assassin's Fang | DAGGER | Lyra | No | MID | Mongreaux | +17| 0 | 0 | 0 | +7 | 0 | 0 | 850 | CHEST | Mongreaux | Yes | No | Yes | High SPD mid-game spike. |
| `wp_dag_04` | Silent Step | DAGGER | Lyra | Yes | FINAL | Aetherion | +32| 0 | 0 | 0 | +12| 0 | 0 | - | CHEST | Aetherion | Yes | Yes | Yes | Lyra's signature. |
| `wp_cla_01` | Heavy Iron | CLAYMORE | Doran | No | EARLY | Lorel | +12| 0 | -2 | 0 | -3 | +10| 0 | 0 | STARTING | Lorel | No | No | Yes | Doran join weapon. |
| `wp_cla_02` | Breaker's Slab | CLAYMORE | Doran | No | MID | Mongreaux | +22| 0 | -3 | 0 | -4 | +25| 0 | 900 | SHOP | Mongreaux | No | No | Yes | Massive ATK, slows him down. |
| `wp_cla_03` | Juggernaut | CLAYMORE | Doran | Yes | FINAL | Aetherion | +42| 0 | -5 | 0 | -5 | +50| 0 | - | BOSS | Aetherion | Yes | Yes | Yes | Doran's signature burst. |
| `wp_stf_01` | Healer's Branch | STAFF | Neria | No | MID | Mongreaux | +2 | +14| 0 | +8 | 0 | 0 | +15| 0 | STARTING | Mongreaux | No | No | Yes | Neria join weapon. |
| `wp_stf_02` | Silverwood Staff | STAFF | Neria | No | LATE | Kamikoto | +5 | +22| 0 | +12| 0 | 0 | +25| 1600 | SHOP | Kamikoto | No | No | Yes | Solid healing boost. |
| `wp_stf_03` | Ocean's Mercy | STAFF | Neria | Yes | FINAL | Aetherion | +10| +35| +5 | +20| +2 | 0 | +45| - | QUEST | Aetherion | Yes | Yes | Yes | Neria's signature. |
| `wp_axe_01` | Mercenary Axe | AXE | Torga | No | MID | Mongreaux | +15| 0 | +10| 0 | -2 | +20| 0 | 0 | STARTING | Mongreaux | No | No | Yes | Torga join weapon. |
| `wp_axe_02` | Ironclad Cleaver | AXE | Torga | No | LATE | Kamikoto | +21| 0 | +15| 0 | -2 | +40| 0 | 1700 | SHOP | Kamikoto | No | No | Yes | Defense focus. |
| `wp_axe_03` | Earthshatter | AXE | Torga | Yes | FINAL | Aetherion | +33| 0 | +25| +10| -3 | +80| 0 | - | CHEST | Aetherion | Yes | Yes | Yes | Torga's signature. |
| `wp_kat_01` | Tsukishiro Steel | KATANA | Katsura| No | LATE | Kamikoto | +24| 0 | +3 | 0 | +4 | 0 | 0 | 0 | STARTING | Kamikoto | No | No | Yes | Katsura join weapon. |
| `wp_kat_02` | Winter's Edge | KATANA | Katsura| Yes | FINAL | Kamikoto | +36| +8 | +5 | 0 | +8 | 0 | 0 | - | OPTIONAL | Kamikoto | Yes | Yes | Yes | Secret Kamikoto reward. |
| `wp_spr_01` | Imperial Lance | SPEAR | Kaelis | No | LATE | Kamikoto | +26| 0 | 0 | 0 | +6 | 0 | 0 | 0 | STARTING | Kamikoto | No | No | Yes | Kaelis join weapon. |
| `wp_spr_02` | Storm Piercer | SPEAR | Kaelis | Yes | FINAL | Aetherion | +38| 0 | 0 | +5 | +10| 0 | 0 | - | CHEST | Aetherion | Yes | Yes | Yes | Kaelis signature burst. |
| `wp_bow_02` | Tactical Recurve | BOW | Sylven | No | LATE | Kamikoto | +22| 0 | 0 | 0 | +5 | 0 | 0 | 0 | STARTING | Kamikoto | No | No | Yes | Sylven join weapon. |
| `wp_bow_03` | Gale Whisperer | BOW | Sylven | Yes | FINAL | Aetherion | +34| +10| 0 | 0 | +8 | 0 | 0 | - | STORY | Aetherion | Yes | Yes | Yes | Sylven's signature. |
| `wp_lsw_01` | Flame-Forged Blade| LONGSWORD| Orin | No | LATE | Kamikoto | +27| +8 | +6 | 0 | -1 | +25| 0 | 0 | STARTING | Kamikoto | No | No | Yes | Orin join weapon. |
| `wp_lsw_02` | Phoenix Heart | LONGSWORD| Orin | Yes | FINAL | Aetherion | +37| +15| +12| +8 | 0 | +60| +10| - | BOSS | Aetherion | Yes | Yes | Yes | Orin's signature. |

## 11. Character Progression Summary
| Character | Allowed Weapons | Starter / Join | Early Upgrade | Mid Upgrade | Late Upgrade | Final Weapon | Final Acquisition |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Aren** | SWORD | Iron Broadsword | Smuggler's Edge | Knight's Vanguard | Tsukishiro Blade | Ignition Core | Chest (Aetherion) |
| **Aelia** | BOW, MAGICBOOK | Hunting Bow (Bow) | Apprentice Tome | Scholar's Lexicon | (None) | Windweaver Codex | Story (Aetherion) |
| **Lyra** | DAGGER | Coastal Dirk | Valkenheim Stiletto | Assassin's Fang | (None) | Silent Step | Chest (Aetherion) |
| **Doran** | CLAYMORE | Heavy Iron | (None) | Breaker's Slab | (None) | Juggernaut | Boss (Aetherion) |
| **Neria** | SPEAR, STAFF | Healer's Branch | (None) | (Join Tier) | Silverwood Staff | Ocean's Mercy | Quest (Aetherion) |
| **Torga** | AXE | Mercenary Axe | (None) | (Join Tier) | Ironclad Cleaver | Earthshatter | Chest (Aetherion) |
| **Katsura** | KATANA | Tsukishiro Steel | (None) | (None) | (Join Tier) | Winter's Edge | Optional Secret |
| **Kaelis** | SPEAR | Imperial Lance | (None) | (None) | (Join Tier) | Storm Piercer | Chest (Aetherion) |
| **Sylven** | BOW | Tactical Recurve | (None) | (None) | (Join Tier) | Gale Whisperer | Story (Aetherion) |
| **Orin** | LONGSWORD | Flame-Forged Blade| (None) | (None) | (Join Tier) | Phoenix Heart | Boss (Aetherion) |

## 12. Head Gear Table
*Restrained defensive/utility table for universal use.*

| ID | Display Name | Tier | Band | Stats | Price | Source | Region | Unique? | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `hd_01` | Travelers Hat | STARTER | Prologue | +1 DEF, +1 MDEF | 0 | STARTING | Elaris | No | Basic headwear. |
| `hd_02` | Leather Cap | EARLY | Lorel | +3 DEF, +2 MDEF | 100 | SHOP | Lorel | No | Standard physical defense. |
| `hd_03` | Scholar's Circlet | EARLY | Alexandria | +1 DEF, +4 MDEF, +5 MP | 120 | SHOP | Alexandria | No | Magic/MP focus. |
| `hd_04` | Steel Helm | MID | Mongreaux | +7 DEF, +3 MDEF | 350 | SHOP | Mongreaux | No | Heavy physical mitigation. |
| `hd_05` | Silk Ribbon | MID | Mongreaux | +2 DEF, +8 MDEF, +1 SPD| 380 | CHEST | Mongreaux | No | Speed/MDEF pivot. |
| `hd_06` | Kamikoto Mask | LATE | Kamikoto | +10 DEF, +10 MDEF | 800 | SHOP | Kamikoto | No | High balanced defenses. |
| `hd_07` | Aether Crown | FINAL | Aetherion | +15 DEF, +20 MDEF, +20 MP | - | CHEST | Aetherion | Yes | Ultimate magic defense. |

## 13. Body Gear Table
*Primary defensive progression.*

| ID | Display Name | Tier | Band | Stats | Price | Source | Region | Unique? | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `bd_01` | Cotton Tunic | STARTER | Prologue | +3 DEF, +2 MDEF, +10 HP | 0 | STARTING | Elaris | No | Basic bodywear. |
| `bd_02` | Leather Armor | EARLY | Lorel | +8 DEF, +4 MDEF | 180 | SHOP | Lorel | No | Physical survival. |
| `bd_03` | Mage's Robe | EARLY | Alexandria | +4 DEF, +10 MDEF, +20 MP | 200 | SHOP | Alexandria | No | Caster bodywear. |
| `bd_04` | Chainmail | MID | Mongreaux | +16 DEF, +8 MDEF | 600 | SHOP | Mongreaux | No | Frontline bulk. |
| `bd_05` | Lunar Cloak | LATE | Kamikoto | +12 DEF, +22 MDEF, +2 SPD| 1400 | SHOP | Kamikoto | No | MDEF and speed. |
| `bd_06` | Plate of the Guard| LATE | Kamikoto | +25 DEF, +12 MDEF, -1 SPD| 1500 | SHOP | Kamikoto | No | Highest physical armor. |
| `bd_07` | Aegis Mantle | FINAL | Aetherion | +32 DEF, +32 MDEF, +50 HP | - | CHEST | Aetherion | Yes | Ultimate universal armor. |

## 14. Accessory Table
*Build adjustment. Stat bundles kept modest.*

| ID | Display Name | Tier | Band | Stats | Price | Source | Region | Unique? | Purpose |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `ac_01` | Health Charm | EARLY | Lorel | +30 HP | 150 | SHOP | Lorel | No | Survivability. |
| `ac_02` | Copper Ring | EARLY | Lorel | +3 ATK | 150 | SHOP | Lorel | No | Flat offense. |
| `ac_03` | Mind Stone | EARLY | Alexandria | +20 MP, +3 MAG | 250 | SHOP | Alexandria | No | Caster sustain. |
| `ac_04` | Swift Anklet | MID | Mongreaux | +4 SPD | 500 | CHEST | Mongreaux | Yes | Crucial queue manipulation. |
| `ac_05` | Defender's Crest | MID | Mongreaux | +8 DEF, +8 MDEF, +20 HP | 600 | SHOP | Mongreaux | No | Defensive bulk. |
| `ac_06` | Oni Badge | LATE | Kamikoto | +8 ATK, +5 SPD | 1000 | CHEST | Kamikoto | Yes | Aggressive physical burst. |
| `ac_07` | Aether Pendant | FINAL | Aetherion | +15 MAG, +40 MP, +5 MDEF | - | BOSS | Aetherion | Yes | Ultimate mage accessory. |

## 15. Regional Shop / Reward Summary
*Design intent only. No shop `.tres` implemented.*

| Region | Story Band | Normal Weapon Availability | Armor Availability | Accessory Availability | Expected Price Band | Notable Non-Shop Rewards |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Elaris** | Prologue | None (Starter Gear only) | None | None | - | None |
| **Lorel** | Arc 1 | Basic physical (Aren/Lyra) | Leather (DEF) | HP/ATK | 100 - 250 G | None |
| **Alexandria**| Arc 2 | Dagger, Magicbook | Mage (MDEF/MP) | MAG/MP | 200 - 300 G | None |
| **Mongreaux** | Arc 3 | Heavy physical (Aren/Doran), Magicbook | Chainmail (Heavy DEF)| SPD, Bulk | 350 - 900 G | Assassin's Fang (Chest), Swift Anklet (Chest) |
| **Kamikoto** | Arc 4 | Mid-Late gear for everyone | Late-game Armor | Physical Burst | 800 - 1800 G | Winter's Edge (Secret), Oni Badge (Chest) |
| **Aetherion** | Arc 5 | NONE (No generic shops here) | NONE | NONE | - | ALL FINAL WEAPONS |

## 16. Join Equipment Rules
Every character joins with valid, immediately usable equipment tailored to their expected story timing.
- **Aren / Aelia**: Start with basic `STARTER` items.
- **Lyra / Doran**: Join in Lorel equipped with `EARLY` gear.
- **Neria / Torga**: Join in Mongreaux equipped with `MID` gear.
- **Katsura / Kaelis / Sylven / Orin**: Join in Kamikoto equipped with `LATE` gear.
No player is forced to immediately spend gold simply to make a new recruit viable.

## 17. Final Weapon Rules
- Every character receives a final/signature weapon in Aetherion (or Kamikoto secret for Katsura).
- These weapons provide the largest single stat bumps but are NOT mandatory to clear the final boss.
- Obtained via a mix of exploration (Chests), lore secrets (Story/Quest), and mini-boss drops (Boss).

## 18. Shared Weapon Family / Character Exclusivity Rule
- **Bow**: Shared by Aelia (Magic Tempo) and Sylven (Tactical Ranged). Aelia receives Magicbooks mid-game, effectively diverging their weapon paths, although Sylven's Bows focus purely on ATK/SPD.
- **Spear**: Shared by Neria (Sustain) and Kaelis (Fast Burst). Neria's path diverges into Staffs mid-game for healing, while Kaelis retains purely physical/speed Spears.
- **Character Exclusivity**: Final weapons like `Windweaver Codex` (Aelia) or `Storm Piercer` (Kaelis) currently have generic `WeaponType` restrictions. 
  - **FUTURE SCHEMA REQUIREMENT**: `EquipmentData` will eventually need an explicit `allowed_character` restriction to prevent Kaelis from equipping Neria's signature staff if the enum overlaps, or Sylven from equipping Aelia's signature bow.

## 19. Missable-Safety Rule
- Standard progression weapons are purchasable or heavily telegraphed.
- Signature/Final weapons placed in Aetherion or Kamikoto must NOT be permanently missable through abrupt one-time story lockouts.

## 20. Runtime Schema Gaps / Future Implementation Requirements
The current `EquipmentData` class perfectly supports flat-stat assignments (`bonus_atk`, `bonus_max_hp`, etc.) and `slot_type`.
**Gaps (Design-Only Metadata in this Table):**
- `Tier`, `Story Band`, `Price`, `Acquisition Type`, `Region`, `Unique Flag`, `Final Weapon Flag`.
- **Action**: Do NOT add these fields to `EquipmentData.gd` in M75.75. They are for level design and shop implementation tracking.

## 21. Numerical Sanity Check
- **ATK Scaling**: A Lv20 Doran (~40 Base ATK) with `Juggernaut` (+42 ATK) reaches ~82 ATK. This respects the ×2 Boost and Broken multipliers without generating 9,999 damage unboosted.
- **DEF Scaling**: A Lv20 Torga (~45 Base DEF) with `Aegis Mantle` (+32 DEF) and `Ironclad Cleaver` (+15 DEF) reaches ~92 DEF. With his 25% Guard mitigation, he is highly durable but boss strong attacks (35% HP equivalent) will still chip him safely.
- **MP Economy**: Aelia's `Windweaver Codex` grants +40 MP, providing ~3 additional heavy spells (12-15 MP), perfectly enabling late-game pacing.

## 22. 10-Hour Scope Check
- **Total Unique Weapons**: 29
- **Total Head Gear**: 7
- **Total Body Gear**: 7
- **Total Accessories**: 7
- **Total Items**: 50. This is exceptionally realistic for a 10-hour RPG, providing meaningful choices without shop/inventory bloat.

## 23. Implementation Handoff
- Do NOT mass-create `.tres` files for this table yet.
- Do NOT refactor `EquipmentManager` to parse a massive ID list yet.
- This document stands as the definitive lock for all weapon scaling, character loadouts, and shop distributions moving into regional production milestones.

## 24. Locked M75.75 Decisions
- Neria diverges to Staffs.
- Aelia diverges to Magicbooks.
- Aetherion has NO regional shops.
- Join gear is provided completely free of charge.

## 25. Deferred Items
- Any passive proc/affix ideas (e.g. "Chance to burn", "BP Regen") are explicitly deferred. The system remains purely flat-stat.
