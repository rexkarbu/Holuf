# Holuf

Holuf is a top-down 2D RPG built with Godot 4. This project focuses on building a solid, data-driven RPG foundation with modular systems for world exploration, quests, and turn-based combat.

## Features

### World & Exploration
* **Top-down Movement**: Smooth player movement with collisions.
* **Camera System**: Dynamic camera that follows the player seamlessly.
* **Interactive NPCs**: Talk to NPCs (like the Elder) to trigger conversations and quests.
* **Dialogue System**: Data-driven multi-line dialogue system supporting branching choices. Dialogue dynamically changes based on quest progression.


### Quest System
* **Data-driven Quests**: Quests are defined using custom Godot Resources (`QuestData`).
* **Objective Tracking**: Triggers in the world (e.g., entering the Old Ruins) seamlessly update quest objectives.
* **Persistent State**: Quest states (Active, Completed) dictate NPC behaviors and dialogue trees.

### Turn-Based Combat
* **Encounter Zones**: Trigger battles by stepping into specific encounter areas.
* **Seamless Transitions**: Transition managers smoothly move the player from the World Scene to the Battle Scene and back, retaining their exact position and game state.
* **Round System & Speed Queue**: Turn order is dynamically determined at the start of each round based on the combatants' Speed stat.
* **Command Menu**: Classic RPG command menu featuring Attack, Skill, and Defend.
* **Defend Mechanic**: Reduces incoming damage by 50% for the duration of the turn.
* **MP System**: Magic Points integration with a robust validation system.
* **Multiple Enemies & Target Selection**: Battle logic supports facing multiple enemies at once with a dynamic UI for target selection.
* **Damage Types & Weakness Discovery**: Attacks have elements/types. Hitting a weakness applies a 1.25x damage multiplier and reveals it on the UI permanently.
* **Shield & Break System**: Enemies have Shield Points. Hitting a weakness reduces the shield. Breaking the shield stuns the enemy (skips their turn) and applies a Break Damage Scaling depending on their tier.
* **Random Break Bonus**: Triggering a Break randomly applies a bonus effect (Armor Shatter, Disorient, or Deep Stagger).

### Skill System
* **Modular Skills**: Skills are built as custom Resources (`SkillData`) making it easy to create new abilities without touching the core code.
* **Scaling & Targets**: Supports Physical/Magic scaling and Self/Enemy targeting.
* **Implemented Skills**:
  * **Fire Slash**: A physical-scaling fire attack.
  * **Heal**: A magic-scaling recovery skill.

### Party System (Core)
* **Active & Reserve Roster**: Full robust Party Manager supporting up to 4 Active Members and multiple Reserve Characters.
* **Persistent State**: The Party Manager operates as an Autoload, keeping the party composition persistent across all scene transitions.
* **Dynamic Menu**: Dedicated Party UI accessible in the World for swapping active members seamlessly without duplicate characters.

### Equipment System
* **4-Slot Core**: Characters can equip items into Weapon, Head, Body, and Accessory slots.
* **Persistent Ownership**: Seamless integration with the Inventory Manager. Equipping an item takes it from the inventory, and unequipping returns it.
* **Non-destructive Stat Calculation**: Equipment stat bonuses (ATK, DEF, MAG, MDEF, SPD, Max HP, Max MP) are calculated dynamically on-demand, without permanently mutating the character's base combat stats.
* **Weapon Restriction System**: A robust compatibility filter built into `CharacterData` (via `allowed_weapon_types`). Characters can only equip weapons that match their allowed proficiencies.

### Character Progression & Combat Data
* **EXP & Leveling**: Data-driven level up system where leveling up naturally increases Max HP, Max MP, and core stats based on individual growth curves.
* **Persistent HP & MP**: Current HP and MP are saved persistently across battles and world exploration.
* **Reserve EXP Penalty**: Members in the Reserve Party do not receive EXP from battles.
* **10-Character Support**: Foundation for a fully playable 10-character roster, successfully migrated to Godot Resource (`.tres`) formats. Features flexible scaling from 1 to 4 active party members simultaneously in Battle without relying on a hardcoded protagonist.

### Game Design & Lore (Pre-Production Locked)
* **Comprehensive Game Design Document**: The project includes a fully locked design bible detailing the world map (Asterra), 7 distinct nations (Lorel, Alexandria, Mongreaux, etc.), and narrative arcs.
* **Scope-Managed Narrative**: The storyline is strictly scoped for a ~10-hour experience with defined pacing limits per arc to prevent scope creep.
* **Character Roster**: Fully fleshed out identities, skill kits, and backgrounds for all 10 playable characters.
* **Combat Philosophy**: Well-defined numerical guardrails ensuring combat remains tactical (Break & Boost driven) without relying on infinite scaling, massive HP sponges, or mandatory grinding.

## Architecture Highlights
* **Autoloads**: Utilizes `GameManager`, `QuestManager`, `DialogueManager`, `TransitionManager`, and `PartyManager` to maintain persistent states across scene changes.
* **Resource-based Data**: Characters, Skills, Dialogues, Quests, and Combatants all utilize Godot `.tres` resources for quick iteration in the Inspector.
* **State Machines**: Battle flow is strictly controlled via an Enum-based State Machine to prevent input bugs and ensure sequential logic.

## Built With
* [Godot Engine 4](https://godotengine.org/)
* GDScript
