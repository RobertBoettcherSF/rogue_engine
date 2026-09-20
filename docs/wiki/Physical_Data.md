# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables. Cite sources in commit messages when numbers change.

Owner: Operations Manager. Consumers include `Game_Environment`, `Game_Actors`, `Game_Items`, `Game_Scenario`, `Game_Ops_Room`, `Game_Strider`, and suit/EVA packages.

Unit convention: [SI_Units.md](SI_Units.md).

SI-audit (Data Scientist): EMU / Orlan **pass**; ECLSS rates **pass** (metabolic SoT unified below).

---

## Metabolic SoT (single source)

Use **mass rates** for cabin/ECLSS ticks. Derived L/min must not fight kg/day.

| State | O2 consumption | CO2 production | Notes |
|-------|----------------|----------------|-------|
| Awake (default) | **0.84 kg/day/person** | **1.0 kg/day/person** | ISS planning / HEU |
| Sleep | **~0.59 kg/day** (~0.7× awake) | scale ~0.7× | Was 0.35 L/min mine-refuge figure — superseded for station tick |

Equivalent awake O2 volume at STP (~1.429 kg/m3): **~0.41 L/min** (not 0.5). Old bunker **0.5 L/min** ≈ 1.0 kg/day is retired for ECLSS consistency.

Demo cell make-up / scrub targets match 1× awake row.

---

## Mass / carry (human)

| Symbol | Value | Notes |
|--------|-------|-------|
| Comfortable carry @ Strength 4–6 | **5 kg** | Mid Strength baseline |
| Example load that bites | **10 kg** potatoes | Over-encumbered |
| Unit | grams / `Mass_Grams` | Food, drink, backpack only |

---

## EVA suit / helmet (IRL defaults)

Default: **ISS EMU-class**. Orlan alternate. Helmet+suit sealed before storm exit; outdoors breathe suit loop.

| Quantity | EMU (ISS) | Orlan |
|----------|-----------|-------|
| Total mass | **~145 kg** (PLSS+SAFER) | **~110 kg** |
| Suit-only | **~55 kg** | — |
| Operating P | **29.6 kPa** 100% O2 | **40 kPa** |
| Primary / reserve | **~8 h** / **~30 min** | **~7 h** |

Worn mass = `Mass_Kilograms` + AP/mobility penalty — **never** Strength 5 kg carry. Sealed 29.6 kPa pure O2 healthy as-is (no ×21%).

Wrist terminal: display over typed state (P, O2 time, CO2 flags, thermal, power, seals, tissue O2).

---

## Tiangong-like cabin

| Quantity | Locked |
|----------|--------|
| Total P | **~101 kPa** |
| O2 partial | **~19–30 kPa** |
| CO2 long-term / emergency | **≤0.4 kPa** / **≤3 kPa** |
| Temperature | **~20–25 C** |
| RH | **~50–65%** |

Volumes: station ~340/122 m3; Tianhe ~113/50–51 m3; demo ops room ~44 m3 work cell.

---

## ECLSS rates

| System | Capacity |
|--------|----------|
| CO2 removal (CDRA-class) | **~6 kg CO2/day** |
| O2 generation (OGA range) | **~2.3–9.3 kg O2/day** |
| Demo 1× cell | scrub **1.0 kg CO2/day**; make-up **0.84 kg O2/day** |

Cabin tick: add metabolic CO2/O2 draw × dt; scrub/make-up up to caps; flag wrist above 0.4 kPa CO2; emergency at 3 kPa.

---

## Strider

Full class: empty **1,680,000 kg**, payload **100,000 kg** (trivial). Demo: **50,000 kg** / **500 kg**. `Mass_Kilograms`. Strider-link in scope this Ada phase.

---

## Airlock / storm / Titan

Both-open forbidden. Storm: cabin vs exterior; name Mars-thin if ~20 kPa. Titan: ~1.47–1.50 bar, ~94 K.

---

## Update rule

1. Ops revises numbers. 2. ADA implements. 3. Same-PR fix for drift.
