# HOLUF Equipment Progression + Regional Gear Master Table — M75.75

## 1. Purpose
This document establishes the canonical equipment progression design for HOLUF's ±10-hour campaign. It locks the weapon progression for all 10 playable characters and the framework for Head, Body, and Accessory gear. This is a DESIGN/MASTER-TABLE source of truth to guide future resource generation.

## 2. Canon / Implementation Baseline
- **Combat Formula**: Normal attacks use ATK vs DEF. Magic attacks (if applicable) use MAG vs MDEF. Weapons provide flat stat bonuses.
- **Current System**: 4 Slots (Weapon, Head, Body, Accessory). Compatibility is checked via `CharacterIdentity.WeaponType` and `CharacterData.allowed_weapon_types`. Non-weapon gear is universal.
- **Campaign Length**: ±10 hours, targeting Lv 20-22 at the final boss without grinding.

## 3. Current Prototype Equipment Classification
Existing prototype `.tres` files in `data/equipment/` are classified as follows (do NOT delete them):

| Resource | Classification | Currently Registered? | Future Master-Table Mapping |
| :--- | :--- | :--- | :--- |
| `training_sword.tres` | REPURPOSE | Yes | Starter weapon for Aren (`wp_swd_01`) |
| `training_bow.tres` | REPURPOSE | Yes | Starter weapon for Aelia (`wp_bow_01`) |
| `leather_cap.tres` | REPURPOSE | Yes | Early Head gear (`hd_02`) |
| `leather_armor.tres` | REPURPOSE | Yes | Early Body gear (`bd_02`) |
| `health_charm.tres` | REPURPOSE | No | Starter/Early Accessory (`ac_01`) |
| `copper_ring.tres` | REPURPOSE | Yes | Early Accessory (`ac_02`) |

## 4. Playable Weapon Compatibility Matrix
*Note: All 10 current party production `.tres` files have been directly audited. Their `allowed_weapon_types` are empty, meaning they fall back to unrestricted equip. This table distinguishes intended design from current reality.*

| Character | Primary Intended Weapon Identity | Canonical / Design Weapon Types | Current `allowed_weapon_types` | Current Runtime Restriction Status | Shared Intended Family | Combat-Stat Emphasis |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Aren** | Balanced Physical | SWORD | `[]` | UNRESTRICTED FALLBACK | No | ATK, HP |
| **Aelia** | Magic Tempo | BOW, MAGICBOOK | `[]` | UNRESTRICTED FALLBACK | Yes (Bow with Sylven) | MAG, MP, SPD |
| **Lyra** | Fast Debuff | DAGGER | `[]` | UNRESTRICTED FALLBACK | No | SPD, ATK |
| **Doran** | Heavy Physical | CLAYMORE | `[]` | UNRESTRICTED FALLBACK | No | ATK (Heavy) |
| **Neria** | Primary Sustain | SPEAR, STAFF | `[]` | UNRESTRICTED FALLBACK | Yes (Spear with Kaelis) | MAG, MP, MDEF |
| **Torga** | Defensive Bruiser | AXE | `[]` | UNRESTRICTED FALLBACK | No | HP, DEF, ATK |
| **Katsura**| Precision Counter | KATANA | `[]` | UNRESTRICTED FALLBACK | No | ATK, SPD |
| **Kaelis** | Fast Burst | SPEAR | `[]` | UNRESTRICTED FALLBACK | Yes (Spear with Neria) | ATK, SPD |
| **Sylven** | Tactical Ranged | BOW | `[]` | UNRESTRICTED FALLBACK | Yes (Bow with Aelia) | ATK, SPD |
| **Orin** | Sustained Bruiser| LONGSWORD | `[]` | UNRESTRICTED FALLBACK | No | ATK, HP, DEF |

## 5. Equipment Progression Philosophy
- **Restrained Scaling**: Final weapons should not invalidate character base stats. A Lv20 character naturally has natural stats defined by their growth curve; final weapons appropriately scale their output without creating an astronomical number.
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
*Economy Assumption*: A meaningful portion of upgrades should come from exploration/story rewards so the player is not expected to purchase every upgrade.
- **STARTER**: 0 Gold (Equipped on join)
- **EARLY**: 150 - 250 Gold
- **MID**: 600 - 900 Gold
- **LATE**: 1500 - 2500 Gold
- **FINAL**: Not purchasable

## 9. Acquisition Rules
Allowed labels: `STARTING`, `SHOP`, `CHEST`, `QUEST`, `BOSS`, `STORY`, `OPTIONAL SECRET`.

## 10. Complete Weapon Master Table

| ID | Display Name | Weapon Type | Intended Char(s) | Sig? | Tier | Story Band | ATK | MAG | DEF | MDEF | SPD | HP | MP | Price | Source | Region | Unique? | Final? | Flat Stats Supported Today? | Notes |
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
| `wp_kat_02` | Winter's Edge | KATANA | Katsura| Yes | FINAL | Kamikoto | +36| +8 | +5 | 0 | +8 | 0 | 0 | - | OPTIONAL SECRET | Kamikoto | Yes | Yes | Yes | Secret Kamikoto reward. |
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
| **Aetherion** | Arc 5 | NONE (No generic shops here) | NONE | NONE | - | Most final weapons; Katsura final is an optional Kamikoto secret |

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
- **Character Exclusivity**: Final weapons currently only restrict by `WeaponType`.
  - **FUTURE SCHEMA REQUIREMENT**: `EquipmentData` will eventually need an explicit `allowed_character_ids: Array[String]` restriction to prevent cross-equipping signature weapons within shared families.
  - **Example 1**: Neria's intended types include SPEAR. Without character exclusivity, she could legally equip Kaelis's signature `Storm Piercer`.
  - **Example 2**: Aelia's intended types include BOW. Without character exclusivity, she could legally equip Sylven's signature `Gale Whisperer`.

## 19. Missable-Safety Rule
- Standard progression weapons are purchasable or heavily telegraphed.
- Signature/Final weapons placed in Aetherion or Kamikoto must NOT be permanently missable through abrupt one-time story lockouts.

## 20. Runtime Schema Gaps / Future Implementation Requirements
The current `EquipmentData` class perfectly supports flat-stat assignments (`bonus_atk`, `bonus_max_hp`, etc.) and `slot_type`.

**DESIGN-ONLY METADATA (Documented here, NOT in code):**
- Tier, Story Band, Price, Acquisition Type, Region, Unique Flag, Final Weapon Flag.

**FUTURE RUNTIME BEHAVIOR / FIELD NEEDED:**
- Actual per-character intended weapon restrictions (currently all are unrestricted `[]`).
- Character-signature exclusivity (e.g., `allowed_character_ids: Array[String]`) where shared weapon types require it.
- Scalable equipment registry/loading in `EquipmentManager`.

## 21. Numerical Sanity Check
Calculated using actual in-engine `CombatantData` growth formulas (`Base + Growth × (Level - 1)`).
- **Doran Physical Offense**: Doran naturally reaches 80 ATK at Lv20 (Base 23 + Growth 3 × 19). With `Juggernaut` (+42 ATK), he reaches 122 ATK. This is an ~52% increase from gear, respecting the ×2 Boost and Broken multipliers without generating 9,999 damage unboosted.
- **Aelia Magic Offense / MP**: Aelia naturally reaches 59 MAG and 156 MP at Lv20. With `Windweaver Codex` (+38 MAG, +40 MP), she reaches 97 MAG and 196 MP. The MAG boost is roughly 64% of her base, providing a powerful signature spike, while the +40 MP ratio is consistent with late-game skill costs.
- **Torga Defense / HP**: Torga naturally reaches 312 HP and 60 DEF at Lv20 (Base 22 + Growth 2 × 19). With `Aegis Mantle` (+32 DEF, +50 HP) and `Ironclad Cleaver` (+15 DEF), he reaches 362 HP and 107 DEF. This combination of HP and DEF makes him highly durable; exact damage survivability is deferred to later battle playtest.
- **Lyra / Kaelis Speed Sanity**: Kaelis naturally reaches 59 SPD at Lv20, and Lyra reaches 60 SPD. Their final weapons give +10 SPD and +12 SPD respectively, pushing them to 69 and 72 SPD. Doran remains at 8 SPD natively, with `Juggernaut` giving -5 SPD (3 SPD effective). Torga is at 9 SPD naturally. The equipment reinforces the intended speed hierarchy without flattening the queue.
- **Neria Sustain**: Neria naturally reaches 161 HP, 171 MP, 58 MAG, and 59 MDEF at Lv20. `Ocean's Mercy` provides +45 MP and +35 MAG, significantly enhancing her sustain and output.
- **Orin Physical Durability**: Orin naturally reaches 268 HP and 55 DEF at Lv20. `Phoenix Heart` gives +60 HP and +12 DEF, increasing his bruiser sustain properly.

## 22. Economy Sanity Check
**DESIGN TARGET**: The player is not expected to buy every item.
**AFFORDABILITY**: To be validated later when regional encounter/shop/reward Gold income is fully authored.

Representative Calculations (assuming Mid/Late game shop prices):
- **A. One meaningful weapon upgrade for a 4-person active party:** 
  Buying `Knight's Vanguard` (750G), `Scholar's Lexicon` (800G), `Breaker's Slab` (900G), and `Assassin's Fang` (850G) = **3,300 Gold**.
- **B. Several defensive upgrades for the active party:**
  Buying 4x `Steel Helm` (350G × 4 = 1400G) and 4x `Chainmail` (600G × 4 = 2400G) = **3,800 Gold**.
- **C. Attempting to buy every normal purchasable upgrade in Kamikoto (Late Game):**
  Weapons (1800+1600+1700 = 5100G) + Head (800G × 10 = 8000G) + Body (1500G × 10 = 15000G) = **28,100 Gold**.
This internal curve demonstrates that outfitting a select core party is reasonably attainable, while a "buy everything" approach scales steeply, correctly incentivizing exploration for chest rewards.

## 23. 10-Hour Scope Check
- **Total Unique Weapons**: 30
- **Total Head Gear**: 7
- **Total Body Gear**: 7
- **Total Accessories**: 7
- **Total Items**: 51. This is exceptionally realistic for a 10-hour RPG, providing meaningful choices without shop/inventory bloat.

## 24. Equipment Manager Registry Current State
Current `EquipmentManager` uses a small hardcoded registry array:
`var ids = ["training_sword", "training_bow", "leather_cap", "leather_armor", "copper_ring"]`
Note that `health_charm.tres` exists in the filesystem but is **NOT** currently registered at runtime.
Future equipment resource production will require a scalable registry/loading system before mass `.tres` creation occurs. Do NOT add all 30 weapon IDs manually.

## 25. Implementation Handoff
- Do NOT mass-create `.tres` files for this table yet.
- Do NOT refactor `EquipmentManager` to parse a massive ID list yet.
- This document stands as the definitive lock for all weapon scaling, character loadouts, and shop distributions moving into regional production milestones.

## 26. Locked M75.75 Decisions
- Neria diverges to Staffs.
- Aelia diverges to Magicbooks.
- Aetherion has NO regional shops.
- Join gear is provided completely free of charge.

## 27. Deferred Items
- Any passive proc/affix ideas (e.g. "Chance to burn", "BP Regen") are explicitly deferred. The system remains purely flat-stat.
