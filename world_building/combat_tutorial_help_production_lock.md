# M75.5 Combat Tutorial / Help Guide Production Lock

## Design Principle
The Help Guide system is designed as a strict, non-persistent, context-driven reference tool. It is an infrastructure gate (M75.5) that provides the content and presentation mechanics without prescribing exactly *when* the tutorials appear (which is reserved for M89).

## Architecture & Integration
- **`CombatHelpContent`**: A minimal stateless `RefCounted` data provider that houses the raw text for each core and special mechanic.
- **`CombatHelpGuide`**: A unified UI component supporting two distinct modes:
  1. **Full Guide**: Accessible via the Pause Menu. Shows a sidebar of all unlocked topics and allows free browsing.
  2. **Contextual Mode**: Accessible via the `show_context_tutorial(topic_id)` API. Strips away the sidebar, forcing focus on a specific mechanic (e.g., triggered on the first encounter of a mechanic).
- **Input Gating**: When the Help Guide is active during battle, all underlying modal inputs (command selection, boost toggling, battle speed) are safely blocked. The guide fully consumes input to prevent state leaks.
- **State Preservation**: Opening the guide in battle occurs during specific decision states (`PLAYER_COMMAND`, etc.) and does *not* consume a turn, alter Battle Points, or mutate any gameplay resource.

## Content & Evidence Rules
The text contained within the guide is strictly tethered to the current runtime evidence:
- **ATTACK**: Explicitly described as a physical attack checking Defense.
- **BOOST**: Accurate description of BP generation (starts after the first turn) and limitations.
- **FLEE**: Accurate description of its limits (fails consume turn, blocked in some battles) without exposing internal debug or exact RNG variables (e.g., 70%).
- **BEAST**: Described objectively as a character-specific special ability with a strict once-per-battle limit.

## Restrictions
- **No Lore / Codex**: The help system contains zero world-building lore or codex entries.
- **No Tutorial Dump**: The system is designed for piece-meal contextual injection, explicitly avoiding front-loaded tutorial dumping.
- **No Save Data Mutation**: The guide does not interact with the save system or bump the save version.
- **No Autoloads**: It is strictly instantiated as a child UI node when needed.
