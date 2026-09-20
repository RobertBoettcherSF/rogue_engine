# Physical Data (Ops-owned)

Unit convention: [SI_Units.md](SI_Units.md).

---

## Lean world profiles (scenario data, one breathe law)

Same engine: `O2_partial ≈ P × O2_fraction`. Suit/cabin when exterior is not breathable.

| World | Ambient P | Mix / note | Breathable unsuited? | Surface g₀ |
|-------|-----------|------------|----------------------|------------|
| Earth cabin | **~101 kPa** | air | yes | **1.00** |
| Earth-storm feel (legacy demo) | **20 kPa** Mars-thin named | air-like mix | **no** (~4 kPa O2-partial) | 1.00 |
| Mars exterior | **~0.6 kPa** | mostly CO₂ | **no** (suit) | **~0.38** |
| Titan exterior | **~147 kPa** | N₂+CH₄ | **no** (suit) | **~0.14** |

Cabin green display: Atm_Fraction **0.90–1.10** (Earth=1.00). Passenger: NOMINAL/CAUTION/FAIL plain text; FUTURE colors.

**Note:** Demo “Mars-thin 20 kPa” is a hostile Earth-storm stand-in, not true Mars ~0.6 kPa. True Mars/Titan are scenario packs.

---

## Metabolic / ECLSS / suit / strider

Awake 0.84 kg O2 + 1.0 kg CO2 /day. ECLSS demo 1× scrub 1.0 / make-up 0.84. EMU ~145 kg, 29.6 kPa pure O2. Strider full 1.68e6 / 1e5 kg.

G→vision: ≤3 clear → ~5 ≈20% → blackout.

---

## Update rule

Ops revises; ADA implements; same-PR for drift.
