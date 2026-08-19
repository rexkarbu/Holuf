# HOLUF Drop-Down Ledge + Anti-Stuck Production Lock — M74

1. Purpose: M74 has two tightly related responsibilities: A) Drop-down ledge for one-way traversal (upper->lower). B) Ledge-specific anti-stuck refinement to harden M73/M74 ledge landing so an incorrectly blocked destination does not leave Player embedded in collision or permanently stuck.
2. M73 relationship: M74 supersedes only the invalid-landing runtime handling described in the M73 document. It does NOT invalidate M73's core climb architecture.
3. DropDownLedge ownership: Traversal logic relies on standard interactable system and is entirely isolated from other movement logic.
4. Deliberate E / Enter drop: Player must deliberately interact with a drop-down ledge.
5. No automatic walk-off: Normal movement toward the cliff remains physically blocked.
6. One-way upper→lower: DropDownLedge supports upper to lower traversal only.
7. ClimbableLedge lower→upper remains: M73 ClimbableLedge handles lower to upper.
8. Root/feet marker semantics: DropStart, DropEnd, ClimbStart, ClimbEnd represent Player ROOT positions.
9. DropStart: Upper point of interaction/origin.
10. DropEnd: Lower point of landing.
11. Barrier/interact/visual separation: A barrier blocks normal physics, interact shape detects input.
12. is_traversing_ledge ownership: Retained for tracking ledge state (no `is_locked` hijacking).
13. Tween ownership: `_ledge_tween` is explicitly tracked to avoid duplicate traversal calls.
14. Actual Player collider query: Uses actual production Player physical footprint (Shape2D) for clearance checks, preserving actual local offset.
15. Areas ignored in clearance test: Safe landing resolution ignores all Areas, testing only against solid world collision (bodies).
16. Clear authored destination = exact marker: If the authored marker is clear, it is used without offset.
17. Bounded directional escape: If blocked, the system searches farther in the same intended travel direction.
18. Default search step/distance: Configured with explicit production defaults (8.0 step, 32.0 max distance).
19. Blocked marker warning: If a safe directional fallback exists but the original is blocked, a warning is pushed.
20. No safe destination = reject traversal: Traversal is entirely rejected if no safe landing exists.
21. Original-position rollback: Stores original pre-traversal position to rollback if final collision mysteriously appears at Tween completion.
22. Traversal-start fallback: Secondary rollback option.
23. No global anti-stuck: Refinement is entirely limited to ledge traversal.
24. Zero encounter-distance contribution: Ledge traversal contributes ZERO to EncounterManager distance walked.
25. Camera behavior: Follows player naturally, zoom 1.0, speed 5.0, no teleport resets.
26. Save behavior: No traversal or ledge data is saved, normal coordinates apply.
27. Battle-return behavior: Resumes exactly on the lower root.
28. TransitionZone boundary: Ledges do not trigger zone transitions mid-tween.
29. EncounterTrigger boundary: Ledges do not trigger encounters mid-tween.
30. StoryTrigger authoring boundary: Do NOT place StoryTrigger directly across a climb/drop Tween path or exactly on a ledge landing.
31. No final art: Whitebox prototypes only.
32. No regional placement: Regional placement comes later.
33. Later regional handoff: Left for actual level design.
