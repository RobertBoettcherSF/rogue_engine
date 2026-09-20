# Packages (Ada 2022)

| Package | Role |
|---------|------|
| `Game_Grid` | Points, terrain, 24×24 chunks, Chebyshev distance, LOS |
| `Game_Actors` | `Human_Actor` (O₂, hunger/thirst/fatigue, sleep, autopilot breathe) · `Robot_Actor` (power/hull/thermal) · AP · adjacent move |
| `Game_Items` | Backpack load; container hull+content; Sip/Bite consumables; can opener / drill / process; plasma breach |
| `Game_Dream_RSI` | Discovery tree; replay sim; improve exploration policy; redeploy |
| `Game_Environment` | Bunker depth, airlock, outdoor storm, satellite frame, aurora |
| `Game_Atmosphere` | Tile atmosphere; O₂-partial = P×O₂%; cabin vs storm exterior |
| `Game_Turn` | Turn / wall-minute clock; AP grant; walk cost |
| `Game_Demo` | Demo harness: walk, eat/drink, tick breathe, sleep/dream, remote Strider |
| `Game_ECLSS` | Cabin ECLSS tick (Ops-locked metabolic/scrubber/OGA); SPARK FUTURE candidate |
| `Game_Suit` | EVA EMU 145 kg `Mass_Kilograms` worn (not Strength); 29.6 kPa/100% O2 healthy; Orlan alt |
| `Game_Strider` | Vehicle `Mass_Kilograms` / kW; full-class wiki constants; demo chassis 5e4 kg |
| `Game_Ops_Room` | 5×4 @ 1 m, per-tile height, ~44 m³ air |
| `Game_Scenario` | Starts; `Linked_Outdoor_Role` includes **Strider** |

## Game_Ops_Room
5×4 @ 1 m tiles (~20 m²), every cell has `Height` (cm). Center console island + operator seat + airlock door cell. Air volume ~44 m³.

## Game_Scenario
`Load_Scenario` / `Apply_Start` for `Bunker_Rover_Storm` (default outdoor **Strider**) and `Titan_Flight_Control`. See [Scenario](Scenario.md) and [Strider](Strider.md).


## SPARK assurance ladder

**Ada-only this phase.** SPARK L2–L4 proof is **FUTURE**. Packages are labeled for later climb; do **not** run or require `gnatprove` yet. Ada `Pre`/`Post`/`Global` contracts remain as documentation.

**FUTURE L2–L4 candidates** (comments in `.ads` only):

| Package | Why |
|---------|-----|
| `Game_Actors` (breathe) | Tissue O2 / hypoxia |
| `Game_Suit` | Seal, suit O2-partial, life support |
| `Game_Environment` (airlock) | Both-open forbidden |
| `Game_ECLSS` | Cabin scrubber / O2 make-up |
| `Game_Strider` | Payload trivial / mass class |
| `Game_Items` (containment/plasma) | If life-critical path |
