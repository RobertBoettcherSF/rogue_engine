# Environment

- **Bunker depth:** 4 floors (`Bunker_Floor_Depth`)
- **Bunker room air:** O₂%, CO₂%, pressure kPa, volume — feeds `Breathe_In_Bunker`
- **Airlock:** inner / outer doors; `Cycle_To_Bunker` / `Cycle_To_Storm`; both-open forbidden
- **Outdoor storm:** low pressure, cold, visibility 0, looks dark at midday radio time, aurora flag
- **Satellite picture:** overhead still; storm edge / aurora; ground detail hidden by dust

Source of truth: `game_environment.ads` / `.adb` and human breathe path in `game_actors`
