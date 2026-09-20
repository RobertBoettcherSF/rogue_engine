# Environment

- **Bunker depth:** 4 floors (`Bunker_Floor_Depth`)
- **Bunker room air:** O₂%, CO₂%, pressure kPa, volume — feeds `Breathe_In_Bunker`
- **Airlock:** inner / outer doors; `Cycle_To_Bunker` / `Cycle_To_Storm`; both-open forbidden
- **Outdoor storm:** Mars-thin 20 kPa, cold, visibility 0, looks dark at midday radio time, aurora flag
- **Satellite picture:** overhead still; storm edge / aurora; ground detail hidden by dust

## Storm exterior (DS + ADA locked)

**Mars-thin 20 kPa:** `Mars_Thin_Exterior_Pressure := 20`; `Storm_Outside_Pressure` alias (same value). **Not** Earth dust-storm 70–85 kPa.

**Unsuited outdoor = hypoxia:** Earth-mix at 20 kPa ⇒ ≈ **4 kPa** O2-partial. See [Physical_Data](Physical_Data.md).

Source of truth: `game_environment.ads` / `.adb` and human breathe path in `game_actors`
