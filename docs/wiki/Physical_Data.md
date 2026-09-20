# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables. Cite sources in commit messages when numbers change.

Owner: Operations Manager. Consumers: `Game_Environment`, `Game_Actors`, `Game_Items` (mass), `Game_Scenario`, `Game_Ops_Room`.

Unit convention: [SI_Units.md](SI_Units.md).

---

## Mass / carry (locked calibration)

| Symbol | Value | Notes |
|--------|-------|-------|
| Comfortable carry @ Strength 4–6 | **5 kg** | Player felt ~5 kg as capacity |
| Example load that bites | **10 kg** potatoes | Already over-encumbered, not “normal” |
| Unit | grams / `Mass_Grams` | Integer grams in SPARK core |

Strength→kg curve: mid Strength (4–6) ≈ 5 kg comfortable; each Strength step scales carry; over-encumbrance applies move/AP penalties (Weight epic).

---

## Bunker air (human)

| Quantity | Baseline | Game use |
|----------|----------|----------|
| O₂ fraction (safe band) | 18.5–23% vol | Keep `O2_Percent` in band; leave = hypoxia |
| O₂ consumption (resting design) | **0.5 L/min/person** | Mine refuge design rate; ~720 L/day ≈ 0.72 m³/day |
| CO₂ danger | rises **before** O₂ runs out | Scrub / vent; tissue O₂ drops when room air bad |
| Bunker depth | **4 floors** | `Bunker_Floor_Depth` |

### Floor m² vs air volume m³ (do not conflate)

| Space | Floor | Clear height | Air volume |
|-------|-------|--------------|------------|
| Small sealed nook (optional) | ~6–9 m² | ~2.2 m | **~12–20 m³** |
| **Default ops / console room (shipped)** | **5×4 m = 20 m²** | **2.2 m** | **~44 m³** (~44 000 L) |

Always store **floor area** and **volume** as separate fields. Tile atmosphere for autopilot breathe uses the **volume + composition + pressure of the tile / room cell the actor occupies** (see Demo Spec).

Sources: MineARC refuge O₂ metering (0.5 L/min); NIOSH/MSHA closed-shelter CO₂-first failure mode.

Tissue oxygenation (0–100%) is the **player vitality** for humans — not HP flavored as flesh.

---

## Airlock (double door)

| Rule | Value |
|------|-------|
| Doors | Inner + outer; **both-open forbidden** (invariant) |
| Cycle | Equalize chamber to target side, then open matching door |
| Purge model | Contaminant halves per full volume exchange (ideal mix) |
| Design exchanges | **≤4** volume exchanges for “effective” purge |
| Cycle time (play) | Order **1–5 minutes** wall / proportional AP |
| Pressures | Bunker ≈ Earth **101.3 kPa**; storm side uses outdoor table below |

Sources: NIOSH airlock purge studies (exchange ratio ≤4 typical).

---

## Outdoor storm (Earth dust, Mars-like hostility)

The **setting is Earth**, but outdoor hostility tracks Mars global-dust-storm *feel* (visibility, cold, dark midday, aurora flag). Do **not** use true Mars 610 Pa as the only Earth outdoor pressure unless the scenario is literally Mars.

### Reference: Mars GDS (Curiosity / MSL 2018)

| Quantity | Approx |
|----------|--------|
| Mean Mars surface P | **~610–636 Pa** |
| Peak optical depth (Gale) | ~8.5 |
| Visibility at peak | **&lt; ~3 km** |
| Diurnal temp range | collapses under dust |

### Earth-analog storm — cabin vs exterior (locked intent)

Prefer a **split**:

| Layer | Pressure | Notes |
|-------|----------|-------|
| Sealed rover / cabin interior | ~90–101 kPa | Breathable if seals hold |
| Storm **exterior** (hostile) | **70–85 kPa** Earth crash **or** thinner if Spec marks “Mars-thin exterior” |

**Code drift (open):** `Game_Environment` currently uses **20 kPa** outdoor — that is Mars-thin hostility, **not** the Earth-analog 70–85 kPa band. Align to 70–85 kPa for Earth scenarios, or document an explicit `Mars_Thin_Exterior` profile at ~0.6–20 kPa. Do not leave unnamed 20 kPa as the default Earth storm.

Other exterior defaults: cold; visibility **0** on ground cam; dark despite radio midday; aurora flag; satellite coarse overhead.

---

## Titan-style flight-control scenario (optional start)

| Quantity | Approx |
|----------|--------|
| Surface pressure | **~1.47–1.50 bar** (Huygens ~1.467 bar) |
| Surface temperature | **~94 K** (−179 °C) |
| Atmosphere | N₂-rich + CH₄; haze; not breathable |

Temperature SoT is **kelvin** for cold scenarios; °C telemetry must use a wide enough subtype (see SI_Units).

---

## Container integrity (not actor HP)

Already shipped in `Game_Items`: hull integrity **0–100%**; open ≤50; rupture at 0. Mass/carry stays separate from integrity.

---

## Update rule

1. Ops revises this page when research or playtests shift baselines.
2. ADA implements / adjusts contracts from this page + Spec cards.
3. If Ada constants diverge, either fix code or amend this page in the same PR.
