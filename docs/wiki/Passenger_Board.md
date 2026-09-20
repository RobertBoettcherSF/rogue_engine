# Passenger board computer

Calm passenger summary — not pilot glass. Ada phase; no screenshots until 50%.

## Pressure display

Ada SoT remains **absolute kPa**. Board may also show **Atm_Fraction 0.00…1.00** with **1.00 = Earth (~101 kPa)**.

| Band | Atm_Fraction | Meaning |
|------|--------------|--------|
| Cabin **green** (total P) | **0.90–1.10** | Near Earth; still check O2 |
| Mars-thin storm | **~0.20** | Red for unsuited lungs |
| EMU suit absolute | **~0.29** | OK if pure O2 loop |
| Vacuum | **0.00** | No negative |

First passenger line: **cabin air OK?** (P in green band + enough O2).

## Meta readouts

| Priority | Readout |
|----------|--------|
| 1 | Cabin OK / CAUTION / FAIL |
| 1 | Red warnings (push) |
| 1 | Current g |
| 2 | MET |
| 2 | Cabin P (kPa and/or Atm_Fraction) |
| 2 | O2 / CO2 simple OK or % |
| 3 | Time to next event; ΔP outside |
| drop first when dim | Fuel %, attitude, dense ECLSS rates |

## Vision from G

≤~3 g clear → ~3.5–4.5 tunnel → ~5 g ~20% → blackout. Keep priority-1; garble 2–3; red still pushes.

See [Physical_Data.md](Physical_Data.md).
