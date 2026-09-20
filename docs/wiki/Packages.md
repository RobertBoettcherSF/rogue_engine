# Packages (Ada 2022)

| Package | Role |
|---------|------|
| `Game_Grid` | Points, terrain, 24×24 chunks, Chebyshev distance, LOS |
| `Game_Actors` | `Human_Actor` (O₂ + bunker breathe) · `Robot_Actor` (power/hull/thermal) · AP · adjacent move |
| `Game_Items` | Backpack load; container hull+content; °C; seal→access; can opener / drill / process; plasma breach |
| `Game_Dream_RSI` | Discovery tree; replay sim; improve exploration policy; redeploy |
| `Game_Environment` | Bunker depth, airlock, outdoor storm, satellite frame, aurora |
| `Game_Ops_Room` | 5×4 @ 1 m (~20 m²) ops room; per-tile height; console island + seat + airlock door |
| `Game_Scenario` | `Load_Scenario` / `Apply_Start` for bunker+rover and Titan flight-control |

Next candidates: turn clock (AP / priority queue); siphon liquid / bleed gas.

See [Scenario](Scenario.md) and [Physical Data](Physical_Data.md).
