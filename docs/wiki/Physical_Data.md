# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. Unit convention: [SI_Units.md](SI_Units.md).

SI-audit: EMU/Orlan **pass**; ECLSS **pass**.

---

## Metabolic SoT

| State | O2 | CO2 |
|-------|----|-----|
| Awake | **0.84 kg/day/person** | **1.0 kg/day/person** |
| Sleep | **~0.59 kg/day** (~0.7×) | ~0.7× |

---

## Mass / carry

Comfortable carry @ Strength 4–6: **5 kg** (`Mass_Grams` backpack only).

---

## Ambient pressure (Ada SoT + passenger display)

**Ada stores absolute kPa.** Atmosphere has weight; that appears as pressure (force/area), not g/cm.

**Passenger display scale:** `Atm_Fraction` **0.00 … 1.00** with **1.00 = Earth sea level ≈ 101 kPa**. **0.00 = vacuum** (no negatives).

| Profile | kPa | Atm_Fraction | Notes |
|---------|-----|--------------|-------|
| Earth sea level | **~101** | **1.00** | Reference |
| Cabin **green** total P | **~91–111** | **0.90–1.10** | Still need enough O2-partial |
| Tiangong-like cabin | **~101** | **~1.00** | O2-partial ~19–30 kPa |
| Mars-thin storm exterior | **20** | **~0.20** | Never green unsuited |
| EMU suit loop | **29.6** | **~0.29** | Pure O2 → still healthy |

Unsuited healthy also needs O2-partial roughly **19–30 kPa** (or air-mix band ~16–24 kPa effective). Suit green is suit-loop, not tile air.

---

## EVA suit

EMU ISS: **~145 kg**, **29.6 kPa** 100% O2, **~8 h** + **30 min**. Orlan: **~110 kg**, **40 kPa**, **~7 h**. Worn = `Mass_Kilograms` + AP penalty.

Wrist / board: see [Passenger_Board.md](Passenger_Board.md).

### G-load → Vision_Clarity

| `G_Load` | Vision |
|----------|--------|
| ≤ **~3 g** | Clear |
| **~3.5–4.5 g** | Tunnel / greyout |
| **~5 g** | **~20%** readable |
| higher | Blackout |

---

## ECLSS

CDRA-class ~6 kg CO2/day; OGA ~2.3–9.3 kg O2/day; demo 1× scrub 1.0 / make-up 0.84.

---

## Strider

Full 1,680,000 / 100,000 kg; demo 50,000 / 500 kg.

---

## Airlock / storm / Titan

Both-open forbidden.

**Mars-thin** exterior **20 kPa** (`Mars_Thin_Exterior_Pressure`; `Storm_Outside_Pressure` alias). Earth-mix ⇒ O2-partial **≈ 4 kPa** — unsuited outdoor always unsurvivable; suit-loop / cabin only.

Titan: ~1.47–1.50 bar, ~94 K.

---

## Update rule

Ops revises; ADA implements; same-PR for drift.
