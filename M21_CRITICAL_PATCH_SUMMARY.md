# M21 CRITICAL PATCH — Summary

**Date:** 2026-08-13  
**Milestone:** 21 (Items & Inventory)  
**Priority:** CRITICAL

---

## Issues Fixed

### 1. **Reserve Party Members Receiving Battle EXP** ❌ → ✅
**Problem:** Reserve party members were receiving 75% of battle EXP, which was unintended.

**Solution:**
- Changed `RESERVE_EXP_RATE` from `0.75` → `0.0` in `PartyManager`
- Removed reserve EXP loop from `grant_rewards()`
- **Result:** Only Active party members (4 max) receive 100% battle EXP each

---

### 2. **HP/MP Not Persisting Between Battles** ❌ → ✅
**Problem:** Characters always started battles at full HP/MP, making healing items useless between battles.

**Solution:**
- Added `current_hp` and `current_mp` to `character_progress` Dictionary in `PartyManager`
- Modified `Combatant._init()` to read from persistent state instead of always using max values
- Added `sync_battle_state()` function to write battle HP/MP back after combat
- Called sync in `BattleController._process_victory_rewards()` before granting EXP

**Result:** HP/MP now persists across:
- Battle → World → Battle transitions
- Party swaps (damaged character stays damaged in reserve)
- Item usage (healing persists)

---

### 3. **Level Up Restoring HP/MP to Full** ❌ → ✅
**Problem:** Level up was auto-healing characters, making it a free heal mechanic.

**Solution:**
- Removed `needs_full_heal` flag logic from `Combatant._init()`
- Modified `_process_exp()` to only **clamp** HP/MP to new max (not restore to full)
- If character had 50/100 HP at level 1, they'll have 50/150 HP at level 2 (not 150/150)

**Result:** Level ups no longer provide free healing

---

## Files Modified

### `scripts/party/party_manager.gd`
- Changed `RESERVE_EXP_RATE` from 0.75 → 0.0
- Added `current_hp` and `current_mp` to character initialization
- Removed reserve EXP grant loop
- Changed level up to clamp HP/MP instead of restore
- Added `sync_battle_state(char_id, hp, mp)` function

### `scripts/battle/combatant.gd`
- Modified `_init()` to read persistent HP/MP from `PartyManager.character_progress`
- Removed old `needs_full_heal` logic
- Added safety clamp to ensure values don't exceed effective max

### `scripts/battle/battle_controller.gd`
- Added `sync_battle_state()` call in `_process_victory_rewards()` for all players
- Syncs HP/MP back to PartyManager before EXP/Gold distribution

---

## Testing

### Automated Test Script
Run `test_m21_critical_patch.gd` to validate:
1. ✓ RESERVE_EXP_RATE = 0.0
2. ✓ Persistent HP/MP fields exist
3. ✓ HP/MP initialized correctly
4. ✓ HP/MP persistence works
5. ✓ sync_battle_state() function works
6. ✓ Level up does NOT restore HP/MP
7. ✓ Only Active party receives battle EXP

### Manual Testing Checklist
- [ ] Start battle with full HP/MP
- [ ] Take damage, win battle
- [ ] Start new battle — HP/MP should be at damaged values
- [ ] Use Potion/Ether items in battle
- [ ] Win battle, return to world
- [ ] Start new battle — healed values should persist
- [ ] Swap damaged character to Reserve
- [ ] Battle with new Active party
- [ ] Swap damaged character back — should still be damaged
- [ ] Level up while damaged — should NOT heal to full
- [ ] Check Reserve party EXP after battle — should be 0

---

## Breaking Changes

### Save Data Compatibility
⚠️ **BREAKING:** Old saves will NOT have `current_hp`/`current_mp` fields.

**Migration Strategy:**
- New characters auto-initialize with max HP/MP
- Existing saves: Add migration code to check for missing fields and initialize them

### Gameplay Impact
- **Healing items now essential** for sustained exploration
- Reserve characters no longer level passively (must be rotated into Active party)
- Level ups are no longer free heals (strategic resource management)

---

## Design Rationale

### Why Remove Reserve EXP?
1. **Party rotation incentive:** Players must actively rotate characters to level them
2. **Strategic depth:** Choice of Active party matters more
3. **Reduces passive power creep:** No free levels for benched characters

### Why Persist HP/MP?
1. **Makes items meaningful:** Healing items have lasting value
2. **Exploration risk/reward:** Players must manage resources between battles
3. **Strategic party swaps:** Damaged characters can be benched to preserve healthier ones

### Why No Level Up Heal?
1. **Prevents heal exploitation:** Can't grind for free heals
2. **Consistent with item economy:** Healing must be earned through items
3. **Maintains tension:** Level ups are stat boosts, not emergency heals

---

## Future Considerations

### Potential Features
- **Inn/Rest System:** Full party heal at safe points
- **Revival Items:** Items to restore KO'd characters
- **Auto-heal in World:** Slow HP/MP regeneration while exploring
- **Reserve Training:** Alternate EXP source for reserve characters (quests, training grounds)

### Known Limitations
- No HP/MP display in World scene (only visible in Battle)
- No warning when entering battle with low HP/MP
- No auto-swap if Active party member is KO'd

---

## Validation Status

✅ **All automated tests passing**  
✅ **Code review complete**  
⏳ **Manual gameplay testing required**  
⏳ **Balance testing in progress**

---

## Rollback Plan

If issues arise, revert these commits:
1. Restore `RESERVE_EXP_RATE = 0.75`
2. Remove `current_hp`/`current_mp` persistence
3. Restore level up full heal behavior

Files to revert: `party_manager.gd`, `combatant.gd`, `battle_controller.gd`

---

**End of M21 CRITICAL PATCH Summary**
