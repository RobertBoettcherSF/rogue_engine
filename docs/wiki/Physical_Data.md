# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables. Cite sources in commit messages when numbers change.

Owner: Operations Manager. Consumers include `Game_Environment`, `Game_Actors`, `Game_Items`, `Game_Scenario`, `Game_Ops_Room`, `Game_Strider`, and suit/EVA packages.

Unit convention: [SI_Units.md](SI_Units.md).

SI-audit (Data Scientist): EMU / Orlan table **pass**.

---

## Mass / carry (human)

| Symbol | Value | Notes |
|--------|-------|-------|
| Comfortable carry @ Strength 4–6 | **5 kg** | Mid Strength baseline |
| Example load that bites | **10 kg** potatoes | Over-encumbered |
| Unit | grams / `Mass_Grams` | Food, drink, backpack only |

---

## EVA suit / helmet (IRL defaults)

Default play profile: **ISS EMU-class**. Orlan-class is an alternate profile. Helmet locked + suit sealed required before storm-side airlock exit. While sealed outdoors, breathe from **suit loop**, not tile air.

### ISS EMU-class (default)

| Quantity | Value | Source notes |
|----------|-------|--------------|
| Suit assembly mass (no PLSS) | **~55 kg** (122 lb) | NASA EMU fact sheet |
| Total mass PLSS + SAFER (ISS) | **~145 kg** (319 lb) | NASA EMU fact sheet |
| Total mass PLSS + SAFER (Shuttle ref.) | **~125 kg** (275 lb) | NASA EMU fact sheet |
| Operating pressure | **29.6 kPa** (4.3 psi) | **100% O2** |
| Primary life support | **~8 h** nominal | PLSS |
| Emergency O2 reserve | **~30 min** | Secondary Oxygen Pack |
| Prebreathe / cabin step-down | Required bunker air → 29.6 kPa O2 | DCS risk; demo may shorten with Spec flag |

### Orlan-class (alternate)

| Quantity | Value | Source notes |
|----------|-------|--------------|
| Suit mass | **~110 kg** | Orlan-MKS published specs |
| Operating pressure | **40 kPa** (0.04 MPa) | Absolute in-suit |
| Autonomous EVA | **~7 h** | |

### Game rules (SI-locked)

1. Don suit + lock helmet before opening outer airlock to storm.
2. **Worn suit mass is `Mass_Kilograms` with mobility/AP penalty — never human Strength carry.**
3. Sealed EMU loop: **29.6 kPa at 100% O2** healthy as-is — **do not** multiply by 21%.
4. Tile air only when helmet unlocked indoors.
5. Life-support timer: primary → emergency reserve → hypoxia.

### Wrist / cuff terminal (display layer)

Thin UI over typed state: suit P, O2 time left, CO2/caution, thermal, power, seals, tissue O2. No ECG for v0.

---

## Tiangong-like cabin (Earth-analogue station module)

Play profile for station-like rooms (not a full CSS twin). DS-proposed bands locked for Ada cabin defaults:

| Quantity | Locked |
|----------|--------|
| Total pressure | **~101 kPa** |
| O2 partial | **~19–30 kPa** |
| CO2 long-term | **≤ 0.4 kPa** |
| CO2 emergency | **≤ 3 kPa** |
| Temperature | **~20–25 C** |
| Relative humidity | **~50–65%** |
| Gas mix | O2/N2 near sea-level |

Volumes (public CSS): station ~340 / ~122 m3 pressurised/habitable; Tianhe ~113 / ~50–51 m3. Demo ops room (~44 m3) = work cell.

Alternate CMSE Shenzhou published cabin band (reference only): total **91 ± 10 kPa**, O2 partial **20–26 kPa**.

---

## ECLSS scrubber / O2 make-up rates (locked for cabin tick)

Per-person metabolic baselines (literature / ISS planning):

| Quantity | Rate |
|----------|------|
| CO2 production | **~1.0 kg/day/person** (~1 HEU) |
| O2 consumption | **~0.84 kg/day/person** |

Station-class hardware capacity (ISS public; CSS regen meets ~100% O2 / purify demand for crew — use ISS rates until finer CSS kg/day publish):

| System | Capacity | Notes |
|--------|----------|-------|
| CO2 removal (1 CDRA dual-bed class) | **~6 kg CO2/day** (~6 HEU) | ISS CDRA; ~1 kg/day per person-eq |
| O2 generation (OGA selectable) | **~2.3–9.3 kg O2/day** | ISS OGA 5.1–20.4 lb/day; nominal ~3 crew |
| Demo single-crew work cell | Scrub **~1.0 kg CO2/day**; make-up **~0.84 kg O2/day** | Match 1 occupant; scale ×N crew |

### Ada cabin tick intent

Each sim tick while ECLSS online:
1. Add crew CO2 mass from metabolic rate × dt.
2. Remove CO2 up to scrubber capacity × dt (cap at cabin CO2 inventory).
3. Remove O2 from crew draw; inject O2 make-up up to generator capacity × dt.
4. Hold total P near target by N2/O2 policy (simple: restore O2 first, then pad N2 if Spec says).
5. If scrubber offline, CO2 climbs toward emergency 3 kPa; wrist flags caution above 0.4 kPa.

Offline / failed ECLSS: sealed room drifts like mine refuge — CO2 fails before O2 in many cases.

---

## Strider scale (vehicle)

| Quantity | Full class | Demo stand-in |
|----------|------------|---------------|
| Empty mass | **1,680,000 kg** | **50,000 kg** |
| Payload | **100,000 kg** (trivial / ~6%) | **500 kg** |
| Step | ~12 m | 1 m tile |
| Power | 14 MW / 19 MW overload | kW budget |

`Payload_Is_Trivial` must accept 100,000 kg on full class. Use `Mass_Kilograms`.

---

## Bunker air (human)

| Quantity | Baseline |
|----------|----------|
| O2 safe band (air-mix) | 18.5–23% vol |
| Resting O2 draw | **0.5 L/min/person** |
| Sleep O2 draw | **~0.35 L/min/person** |
| Default ops room | 20 m2 × 2.2 m ≈ **44 m3** |
| Bunker depth | 4 floors |

Unsuited breathe: effective O2 = P × O2 fraction; healthy ~16–24 kPa.

---

## Airlock

Both-open forbidden. Outer storm exit requires sealed suit+helmet when exterior unsurvivable.

---

## Outdoor storm

Prefer cabin vs exterior split. Name Mars-thin if using ~20 kPa exterior.

---

## Titan-style scenario

~1.47–1.50 bar; ~94 K; not breathable.

---

## Update rule

1. Ops revises numbers from research/playtests.
2. ADA implements from Spec + this page.
3. Fix code/wiki drift in the same PR.
