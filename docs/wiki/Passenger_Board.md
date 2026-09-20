# DEMO / UI Spec addendum: passenger board computer

Status: Spec ready (Ada phase; no screenshots until 50%).

Passenger-facing **board computer** = calm summary panel for someone who may be under high-g / low `Vision_Clarity` — **not** the pilot full glass (no engine mix, guidance loops, or dense telemetry).

## Passenger summary (meta values)

Prefer few large lines; non-critical lines drop first when `Vision_Clarity` is low (~20% readable).

| Priority | Readout | Typed source |
|----------|---------|--------------|
| 1 (always try) | **Cabin status** OK / CAUTION / FAIL | ECLSS + cabin P/O2/CO2 vs bands |
| 1 | **Warnings** (red push) | alarm queue |
| 1 | **G / Thrust** (current g) | `G_Load` / `Thrust_g` |
| 2 | **Mission clock / MET** | sim clock |
| 2 | **Cabin P (kPa)** | cabin absolute pressure |
| 2 | **O2 / CO2 state** (simple OK or %) | partial pressures |
| 3 | **Time to next event** (burn end, staging, dock) | scenario timeline |
| 3 | **ΔP cabin→outside** (if known) | hull sensors |
| drop first under dim | Detailed ECLSS rates, power bus, fuel %, attitude | pilot glass only |

Suited passenger: cuff stays suit-loop; board computer still shows **cabin** meta (are we holding?) unless Spec says vehicle is unpressurized.

Near-blackout: keep priority-1 lines; garble/omit 2–3; red warnings still push without a glance.

See also wrist rules in [Physical_Data.md](Physical_Data.md).
