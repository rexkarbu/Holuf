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

### Skill System
* **Modular Skills**: Skills are built as custom Resources (`SkillData`) making it easy to create new abilities without touching the core code.
* **Scaling & Targets**: Supports Physical/Magic scaling and Self/Enemy targeting.
* **Implemented Skills**:
  * **Fire Slash**: A physical-scaling fire attack.
  * **Heal**: A magic-scaling recovery skill.

## Architecture Highlights
* **Autoloads**: Utilizes `GameManager`, `QuestManager`, `DialogueManager`, and `TransitionManager` to maintain persistent states across scene changes.
* **Resource-based Data**: Characters, Skills, Dialogues, and Quests all utilize Godot `.tres` resources for quick iteration in the Inspector.
* **State Machines**: Battle flow is strictly controlled via an Enum-based State Machine to prevent input bugs and ensure sequential logic.

## Built With
* [Godot Engine 4](https://godotengine.org/)
* GDScript
