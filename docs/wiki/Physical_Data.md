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

## EVA suit

EMU ISS: **~145 kg**, **29.6 kPa** 100% O2, **~8 h** + **30 min**. Orlan: **~110 kg**, **40 kPa**, **~7 h**. Worn = `Mass_Kilograms` + AP penalty.

### Wrist cuff / passenger board

Mode-switched readouts: see [Passenger_Board.md](Passenger_Board.md). SI: **g** (×g₀), **MET** (s), **P** (kPa), O2/CO2 as partial-pressure or %.

### G-load → Vision_Clarity (DS-locked, +Gz sustained approx.)

| `G_Load` | Vision |
|----------|--------|
| ≤ **~3 g** | Clear |
| **~3.5–4.5 g** | Tunnel / greyout |
| **~5 g** | **~20%** readable (near G-LOC) |
| higher / sustained | Blackout — no voluntary glance |

Varies with duration and G-suit. Dense rates drop first as clarity falls; red alarms still push.

---

## Tiangong-like cabin

~101 kPa; O2 partial ~19–30 kPa; CO2 ≤0.4 / ≤3 kPa; ~20–25 C; RH ~50–65%.

---

## ECLSS

CDRA-class ~6 kg CO2/day; OGA ~2.3–9.3 kg O2/day; demo 1× scrub 1.0 / make-up 0.84.

---

## Strider

Full 1,680,000 / 100,000 kg; demo 50,000 / 500 kg.

---

## Airlock / storm / Titan

Both-open forbidden. Titan ~1.47–1.50 bar, ~94 K.

---

## Update rule

Ops revises; ADA implements; same-PR for drift.
