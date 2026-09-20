# Packages (Ada 2022)

| Package | Role |
|---------|------|
| `Game_Grid` | Points, terrain, 24×24 chunks, Chebyshev distance, LOS |
| `Game_Actors` | `Human_Actor` (O₂ + bunker breathe) · `Robot_Actor` (power/hull/thermal) · AP · adjacent move |
| `Game_Items` | Backpack load; container hull+content; °C; seal→access; can opener / drill / process; plasma breach |
| `Game_Dream_RSI` | Discovery tree; replay sim; improve exploration policy; redeploy |
| `Game_Environment` | Bunker depth, airlock, storm, satellite frame, aurora |
| `Game_Ops_Room` | Typed mid-room layout; floor tiles; height; air volume |
| `Game_Scenario` | Flexible starts (bunker+rover vs Titan-style) — **shipped** |

Factual constants: [Physical Data](Physical_Data.md). Units: [SI Units](SI_Units.md). Playable demo Spec: [Demo](Demo.md).

Next candidates: turn clock; siphon liquid / bleed gas; DEMO walk/eat/breathe/sleep-dream loop.
