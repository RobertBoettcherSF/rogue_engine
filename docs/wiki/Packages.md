# Packages (Ada 2022)

| Package | Role |
|---------|------|
| `Game_Grid` | Points, terrain, 24×24 chunks, Chebyshev distance, LOS |
| `Game_Actors` | `Human_Actor` (O₂ + bunker breathe) · `Robot_Actor` (power/hull/thermal) · AP · adjacent move |
| `Game_Items` | Backpack load; container hull+content; °C; seal→access; can opener / drill / process; plasma breach |
| `Game_Dream_RSI` | Discovery tree; replay sim; improve exploration policy; redeploy |
| `Game_Environment` | Bunker depth, airlock, storm, satellite frame, aurora |
| `Game_Scenario` | **Spec ready** — flexible starts (bunker+rover vs Titan-style); see [Scenario](Scenario.md) |

Factual constants: [Physical Data](Physical_Data.md) (Ops).

Next candidates: turn clock (AP / priority queue); siphon liquid / bleed gas; typed central console furniture.
