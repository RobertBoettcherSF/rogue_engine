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
| Sleep | **~0.59 kg/day** (~0.7× awake) | scale ~0.7× | |

Equivalent awake O2 volume at STP (~1.429 kg/m3): **~0.41 L/min**. Old bunker 0.5 L/min retired for ECLSS consistency.

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

### Wrist / cuff terminal

Thin display over typed state. Mode-switched:

| Mode | Readouts |
|------|----------|
| Unsuited (cabin / rocket cabin air) | cabin P (kPa), O2%/CO2%, effective O2-partial, temp, scrubber/O2 status, warnings |
| Suited (sealed) | suit P, O2 time left (+ reserve), thermal, seal OK, battery — **not** exterior tile air |
| Optional rocket lines | cabin ΔP to outside, MET/clock |

**High thrust / high-g:** voluntary wrist glance is not free. Raise `Thrust_g` → higher AP cost and/or fail chance on `Can_Raise_Arm`. Critical alarms still **push** (tone + auto cuff line) without a full look. Soft coast = normal glance.

---

## Tiangong-like cabin

| Quantity | Locked |
|----------|--------|
| Total P | **~101 kPa** |
| O2 partial | **~19–30 kPa** |
| CO2 long-term / emergency | **≤0.4 kPa** / **≤3 kPa** |
| Temperature | **~20–25 C** |
| RH | **~50–65%** |

---

## ECLSS rates

| System | Capacity |
|--------|----------|
| CO2 removal (CDRA-class) | **~6 kg CO2/day** |
| O2 generation (OGA range) | **~2.3–9.3 kg O2/day** |
| Demo 1× cell | scrub **1.0 kg CO2/day**; make-up **0.84 kg O2/day** |

---

## Strider

Full: empty **1,680,000 kg**, payload **100,000 kg** (trivial). Demo: **50,000 / 500 kg**. `Mass_Kilograms`. Strider-link in this Ada phase.

---

## Airlock / storm / Titan

Both-open forbidden. Storm cabin vs exterior. Titan ~1.47–1.50 bar, ~94 K.

---

## Update rule

1. Ops revises numbers. 2. ADA implements. 3. Same-PR fix for drift.
