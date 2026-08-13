class_name BoostMultiplier
extends Object

## M23 — Centralized Boost Multiplier values
## Prevents magic numbers scattered throughout BattleController

const BOOST_0: float = 1.00  # No boost
const BOOST_1: float = 1.25  # +25% damage/healing
const BOOST_2: float = 1.50  # +50% damage/healing
const BOOST_3: float = 2.00  # +100% damage/healing (double)

const MAX_BP: int = 3  # Maximum Boost Points

## Get multiplier for a given boost level (0-3)
static func get_multiplier(boost_level: int) -> float:
	match boost_level:
		0: return BOOST_0
		1: return BOOST_1
		2: return BOOST_2
		3: return BOOST_3
		_: return BOOST_0  # Fallback to no boost

## Clamp boost level to valid BP (0-3)
static func clamp_boost(boost_level: int, current_bp: int) -> int:
	return clamp(boost_level, 0, min(current_bp, MAX_BP))
