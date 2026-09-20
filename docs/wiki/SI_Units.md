# SI / units convention

One-page source of truth for physical base units and allowed aliases in `rogue_engine`. Playability clamps are fine; **units and order-of-magnitude** must still match [Physical_Data.md](Physical_Data.md).

Owner: **Data Scientist** (convention) + **Operations Manager** (numbers). Consumer: **ADA (SPARK)** Ada contracts.

---

## Base units (prefer in SPARK core)

| Quantity | Base unit | Ada naming hint | Notes |
|----------|-----------|-----------------|-------|
| Mass | gram (g) | `Mass_Grams` | Integer grams. Strength × 1000 g ≈ kg comfortable carry (shipped). |
| Length | metre (m) | Prefer `Height_mm` / `Length_mm` if integers | Tile height should be SI when added. |
| Area | square metre (m²) | `Floor_Area_m2` (scenario / wiki) | **Floor footprint ≠ air volume.** |
| Volume | litre (L) or m³ | `Volume_Liters` (1000 L = 1 m³) | Litres for integer Ada; document m³ in wiki. |
| Pressure | kilopascal (kPa) | `Abs_Pressure_kPa` | Absolute, not gauge. 101 kPa ≈ Earth sea level. |
| Temperature | kelvin (K) physics SoT; °C telemetry alias | One shared Celsius subtype for Earth-band play | Titan ~94 K (−179 °C) needs Kelvin or a wide °C range. |
| Time | second (s) | Wall / cycle time | Action points are **game**, not SI. |
| Visibility / distance | metre (m) | `Visibility_Meters` | Storm ground cam may be 0 m. |

---

## Allowed aliases

- **°C** — hull / content / robot thermal telemetry (Earth-band scenarios).
- **kPa** — all typed pressures in core (not bar / atm in Ada; conversions stay in wiki).
- **%** — O₂ / CO₂ volume fraction, tissue oxygenation, hull integrity, power — **game scalars**, not SI.

---

## Explicit non-SI / game scalars

`Integrity_Percent`, `Power_Percent`, `Tissue_Oxygenation`, action points, tile indices — not physical units. Keep them clearly named so they never collide with mass / pressure / temperature.

`Chunk_Extent` (24) is **tile count**, not metres.

---

## Floor m² vs volume m³

Physical_Data’s **12–20** figure is **air volume (m³)**, not floor area.

Example: **5 × 4** tiles at **1 m** pitch with **2.2 m** ceiling ≈ **44 m³** — valid ops / console room. Always list **floor m²** and **volume m³** as separate columns so Spec and code do not fight.

---

## Open drifts (align code ↔ wiki; no Ada change in this page alone)

1. **Storm outdoor pressure** — `Game_Environment.Storm_Outside_Pressure` = **20 kPa**; Physical_Data Earth-analog suggests **70–85 kPa** (or cabin vs exterior split).
2. **Celsius subtypes** — three ranges today (`Celsius_Degrees` −273…10 000; Environment `Celsius` −100…80; robot `Thermal_C` −100…200). Consolidate or keep Kelvin for cold scenarios (Titan).
3. **Grid height** — `Game_Grid.Tile` has no SI length / height yet; when added, prefer millimetres (or metres) per tile.

---

## Update rule

1. Ops revises Physical_Data numbers; Data Scientist revises this convention when base units change.
2. ADA implements / adjusts contracts from Spec + these pages.
3. If Ada constants diverge, fix code or amend the wiki **in the same PR**.
