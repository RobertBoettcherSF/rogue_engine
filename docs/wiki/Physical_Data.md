# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables. Cite sources in commit messages when numbers change.

Owner: Operations Manager. Consumers: `Game_Environment`, `Game_Actors`, `Game_Items`, `Game_Scenario`, `Game_Ops_Room`, `Game_Strider`.

Unit convention: [SI_Units.md](SI_Units.md).

---

## Mass / carry (human)

| Symbol | Value | Notes |
|--------|-------|-------|
| Comfortable carry @ Strength 4–6 | **5 kg** | Player felt ~5 kg as capacity |
| Example load that bites | **10 kg** potatoes | Already over-encumbered, not normal |
| Unit | grams / `Mass_Grams` | Integer grams for food, drink, personal carry |

---

## Strider scale (vehicle)

Use `Mass_Kilograms` (or megagrams), **not** human `Mass_Grams` capped at 1 t.

| Quantity | Full class | Demo stand-in |
|----------|------------|---------------|
| Empty mass | **1,680,000 kg (1,680 t)** | **50,000 kg (50 t)** |
| Payload class | **100,000 kg (100 t)** | **500 kg** |
| Payload / empty | **~5.95%** | 1% |
| Step | ~12 m | 1 m tile |
| Cruise / hard speed | ~13 / ~21 m/s | turn/AP limited |
| Nameplate / overload power | 14 / 19 MW | kW budget |
| Snow wade | ~5 m | scenario scaled |

**Locked behavior:** for a full-class strider, **100 t is trivial/light-class payload**. Ada should expose a typed predicate such as `Payload_Is_Trivial`; 100,000 kg must pass, while a larger threshold fails. Demo scaling is about 1/34 empty mass and is documented, not silently treated as full class.

---

## Bunker air (human)

| Quantity | Baseline | Game use |
|----------|----------|----------|
| O2 fraction (safe band) | 18.5–23% vol | Keep `O2_Percent` in band; leave = hypoxia |
| O2 consumption (resting design) | **0.5 L/min/person** | ~720 L/day |
| Sleep O2 draw | ~**0.35 L/min/person** | Demo target |
| CO2 danger | rises **before** O2 runs out | Scrub / vent |
| Bunker depth | **4 floors** | `Bunker_Floor_Depth` |

### Floor m2 vs air volume m3

| Space | Floor | Clear height | Air volume |
|-------|-------|--------------|------------|
| Small sealed nook (optional) | ~6–9 m2 | ~2.2 m | ~12–20 m3 |
| Default ops room | **5x4 m = 20 m2** | **2.2 m** | **~44 m3** (~44,000 L) |

Autopilot breathe uses current tile/cell absolute pressure times O2 fraction. Bunker example: 101 kPa x 21% ≈ 21 kPa O2 partial pressure. Tissue oxygenation drops outside roughly 16–24 kPa or when CO2 climbs first.

---

## Airlock

Both-open is forbidden. Cycle chamber to target pressure before matching door opens. Effective purge should use no more than four volume exchanges; gameplay cycle is roughly 1–5 minutes or proportional AP.

---

## Outdoor storm

Default Earth analog should split sealed cabin (~90–101 kPa) from hostile exterior (~70–85 kPa), unless an explicit Mars-thin profile is selected.

**Open code drift:** unnamed 20 kPa exterior is not the documented Earth default. Name it Mars-thin or align it to Earth analog.

Other defaults: cold, ground visibility 0, dark at radio midday, aurora, coarse satellite overhead.

---

## Titan-style scenario

Surface pressure ~1.47–1.50 bar; temperature ~94 K; N2-rich + CH4, not breathable. Kelvin is the physics source of truth.

---

## Update rule

1. Ops revises numbers from research/playtests.
2. ADA adjusts contracts from this page + Specs.
3. Code/wiki divergence is fixed in the same PR.
