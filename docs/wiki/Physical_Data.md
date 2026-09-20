# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. Unit convention: [SI_Units.md](SI_Units.md).

---

## Metabolic SoT

Awake: **0.84 kg O2/day**, **1.0 kg CO2/day** per person. Sleep ~0.7×.

---

## Ambient pressure

**Ada SoT: absolute kPa.** Atmosphere has weight → pressure (not g/cm).

**Passenger display:** `Atm_Fraction` **0.00…1.00**, **1.00 = Earth ≈ 101 kPa**, **0.00 = vacuum** (no negatives).

| Profile | kPa | Atm_Fraction |
|---------|-----|--------------|
| Earth sea level | ~101 | **1.00** |
| Cabin green (total P) | ~91–111 | **0.90–1.10** |
| Mars-thin storm | 20 | **~0.20** |
| EMU suit | 29.6 pure O2 | **~0.29** (still OK) |

Cabin also needs enough O2-partial (~19–30 kPa). Unsuited Mars-thin ≈ 4 kPa O2-partial — never green.

---

## Passenger UX rule

Internals stay full SI. Passenger sees **NOMINAL / CAUTION / FAIL** on the few that matter (cabin air, g, warnings). Optional numbers behind that; green = important values OK.

See [Passenger_Board.md](Passenger_Board.md).

---

## EVA / G / ECLSS / Strider / Storm

EMU ~145 kg, 29.6 kPa, ~8 h + 30 min. G→vision: ≤3 clear, ~5 ≈20%, then blackout. ECLSS demo 1× scrub 1.0 / make-up 0.84 kg/day. Strider full 1.68e6 / 1e5 kg. Storm **Mars-thin 20 kPa** (named).

---

## Update rule

Ops revises; ADA implements; same-PR for drift.
