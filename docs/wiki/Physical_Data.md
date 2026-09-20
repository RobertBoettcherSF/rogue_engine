# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables. Cite sources in commit messages when numbers change.

Owner: Operations Manager. Consumers: `Game_Environment`, `Game_Actors`, `Game_Items` (mass), future `Game_Scenario`.

---

## Mass / carry (locked calibration)

| Symbol | Value | Notes |
|--------|-------|-------|
| Comfortable carry @ Strength 4–6 | **5 kg** | Player felt ~5 kg as capacity |
| Example load that bites | **10 kg** potatoes | Already over-encumbered, not “normal” |
| Unit | grams or `Mass_Grams` | Prefer integer grams in SPARK core |

Strength→kg curve: mid Strength (4–6) ≈ 5 kg comfortable; each Strength step scales carry; over-encumbrance applies move/AP penalties (Weight epic).

---

## Bunker air (human)

| Quantity | Baseline | Game use |
|----------|----------|----------|
| O₂ fraction (safe band) | 18.5–23% vol | Keep `O2_Percent` in band; leave = hypoxia |
| O₂ consumption (resting design) | **0.5 L/min/person** | Mine refuge design rate; ~720 L/day ≈ 0.72 m³/day |
| CO₂ danger | rises **before** O₂ runs out | Scrub / vent; tissue O₂ drops when room air bad |
| Room volume | scenario data (m³) | Small console room: start ~12–20 m³ unless Spec says otherwise |
| Bunker depth | **4 floors** | `Bunker_Floor_Depth` |

Sources: MineARC refuge O₂ metering (0.5 L/min); NIOSH/MSHA closed-shelter CO₂-first failure mode.

Tissue oxygenation (0–100%) is the **player vitality** for humans — not HP flavored as flesh.

---

## Airlock (double door)

| Rule | Value |
|------|-------|
| Doors | Inner + outer; **both-open forbidden** (invariant) |
| Cycle | Equalize chamber to target side, then open matching door |
| Purge model | Contaminant halves per full volume exchange (ideal mix) |
| Design exchanges | **≤4** volume exchanges for “effective” purge (refuge airlock lit.) |
| Cycle time (play) | Order **1–5 minutes** wall / proportional AP — Spec may shorten for turns |
| Pressures | Bunker ≈ Earth 101.3 kPa; storm side uses outdoor table below |

Sources: NIOSH airlock purge studies (exchange ratio ≤4 typical).

---

## Outdoor storm (Earth dust, Mars-like hostility)

The **setting is Earth**, but outdoor hostility tracks Mars global-dust-storm *feel* (visibility, cold, dark midday, aurora flag). Do **not** use true Mars 610 Pa as the only Earth outdoor pressure unless the scenario is literally Mars.

### Reference: Mars GDS (Curiosity / MSL 2018)

| Quantity | Approx |
|----------|--------|
| Mean Mars surface P | **~610–636 Pa** |
| Peak optical depth (Gale) | ~8.5 |
| Visibility at peak | **&lt; ~3 km** (rim ~30 km normally visible) |
| Air/ground diurnal range | collapses (~70 K → ~30–36 K air) |
| Day max / night min | day cooler, night warmer under dust |

Sources: Guzewich et al. 2019 GRL; MSL REMS MY34 papers; arXiv:1910.00986 visibility.

### Earth-analog storm for default bunker+rover scenario

| Quantity | Suggested typed default | Notes |
|----------|-------------------------|-------|
| Outdoor pressure | **low but breathable-hostile** — e.g. 70–85 kPa crashed local, **or** sealed rover cabin separate from thin exterior | Prefer cabin vs exterior split |
| Temperature | cold; rover thermal sinks when hull open |
| Visibility | **0** on ground cam; satellite still coarse |
| Lighting | dark despite radio “midday” |
| Aurora | boolean / intensity over dust |
| Wind force | high dust load; avoid Hollywood “knock over rover” unless mass×drag justified |

Mars thin-air note (NASA): even strong Martian winds exert little Earth-like force — if we ever set true Mars exterior, **do not** overstate kinetic shove.

---

## Titan-style flight-control scenario (optional start)

| Quantity | Approx |
|----------|--------|
| Surface pressure | **~1.47–1.50 bar** (Huygens ~1.467 bar) |
| Surface temperature | **~94 K** (−179 °C) |
| Atmosphere | N₂-rich + CH₄; haze; not breathable |

Sources: Titan atmosphere summaries; Huygens HASI landing site.

Use only when `Game_Scenario` selects Titan / orbital / landing ops — not mixed into bunker+rover defaults.

---

## Container integrity (not actor HP)

Already shipped in `Game_Items`: hull integrity **0–100%**; open ≤50; rupture at 0. Mass/carry stays separate from integrity.

---

## Update rule

1. Ops revises this page when research or playtests shift baselines.
2. ADA implements / adjusts contracts from this page + Spec cards.
3. If Ada constants diverge, either fix code or amend this page in the same PR.
