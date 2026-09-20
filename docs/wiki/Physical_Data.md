# Physical Data (Ops-owned)

Factual baselines for typed Ada contracts. **Code may clamp for playability**, but units and order-of-magnitude must match these tables. Cite sources in commit messages when numbers change.

Owner: Operations Manager. Consumers include `Game_Environment`, `Game_Actors`, `Game_Items`, `Game_Scenario`, `Game_Ops_Room`, `Game_Strider`, and suit/EVA packages.

Unit convention: [SI_Units.md](SI_Units.md).

---

## Mass / carry (human)

| Symbol | Value | Notes |
|--------|-------|-------|
| Comfortable carry @ Strength 4–6 | **5 kg** | Mid Strength baseline |
| Example load that bites | **10 kg** potatoes | Over-encumbered |
| Unit | grams / `Mass_Grams` | Food, drink, personal carry |

---

## EVA suit / helmet (IRL defaults)

Default play profile: **ISS EMU-class**. Orlan-class is an alternate profile. Helmet locked + suit sealed required before storm-side airlock exit. While sealed outdoors, breathe from **suit loop**, not tile air.

### ISS EMU-class (default)

| Quantity | Value | Source notes |
|----------|-------|--------------|
| Suit assembly mass (no PLSS) | **~55 kg** (122 lb) | NASA EMU fact sheet |
| Total mass PLSS + SAFER (ISS) | **~145 kg** (319 lb) | NASA EMU fact sheet |
| Total mass PLSS + SAFER (Shuttle ref.) | **~125 kg** (275 lb) | NASA EMU fact sheet |
| Operating pressure | **29.6 kPa** (4.3 psi) | 100% O2 |
| Primary life support | **~8 h** nominal (mission planning often ~6.5–8 h useful) | PLSS |
| Emergency O2 reserve | **~30 min** | Secondary Oxygen Pack |
| Prebreathe / cabin step-down | Required when going bunker ~101 kPa air to 29.6 kPa O2 | DCS risk; demo may shorten with explicit Spec flag |

### Orlan-class (alternate)

| Quantity | Value | Source notes |
|----------|-------|--------------|
| Suit mass | **~110 kg** | Orlan-MKS published specs |
| Operating pressure | **40 kPa** (0.04 MPa) | Absolute in-suit |
| Autonomous EVA | **~7 h** (some docs up to ~9 h warranty class) | |

### Game rules

1. Don suit + lock helmet before opening outer airlock to storm.
2. Suit mass counts toward carry / over-encumbrance (`Mass_Kilograms` for worn vehicle-scale load, or grams if you keep worn gear under human carry — prefer **kg** for full EMU ~145 kg).
3. Autopilot breathe uses suit absolute pressure and O2 fraction while sealed; tile air only when helmet unlocked indoors.
4. Life-support timer depletes; at 0 primary, only emergency reserve remains; at 0 reserve, hypoxia path.

---

## Strider scale (vehicle)

Use `Mass_Kilograms`, not human `Mass_Grams`.

| Quantity | Full class | Demo stand-in |
|----------|------------|---------------|
| Empty mass | **1,680,000 kg** | **50,000 kg** |
| Payload | **100,000 kg** (trivial / ~6% of empty) | **500 kg** |
| Step | ~12 m | 1 m tile |
| Power | 14 MW / 19 MW overload | kW budget |

`Payload_Is_Trivial` must accept 100,000 kg on full class.

---

## Bunker air (human)

| Quantity | Baseline |
|----------|----------|
| O2 safe band | 18.5–23% vol |
| Resting O2 draw | **0.5 L/min/person** |
| Sleep O2 draw | **~0.35 L/min/person** |
| Default ops room | 20 m2 floor x 2.2 m ≈ **44 m3** |
| Bunker depth | 4 floors |

Autopilot (unsuited): effective O2 = absolute P (kPa) x O2 fraction. Healthy band ~16–24 kPa; CO2 can fail first.

---

## Airlock

Both-open forbidden. Equalize chamber before matching door. Prefer ≤4 volume exchanges. Outer exit to storm requires sealed suit+helmet when exterior is unsurvivable on tile air.

---

## Outdoor storm

Prefer cabin vs exterior split. Unnamed **20 kPa** exterior is not the documented Earth default (70–85 kPa) unless marked Mars-thin. Storm tile air with Earth mix at 20 kPa ≈ 4 kPa O2-partial — unsurvivable without suit/cabin.

---

## Titan-style scenario

~1.47–1.50 bar surface; ~94 K; not breathable. Kelvin SoT.

---

## Update rule

1. Ops revises numbers from research/playtests.
2. ADA implements from Spec + this page.
3. Fix code/wiki drift in the same PR.
