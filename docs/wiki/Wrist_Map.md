# Wrist map (terminal `./play`)

Pure Ada terminal — no GUI toolkit. Same UI on **any surface** (Earth / Mars / Titan / …); only the **world profile** changes (P, mix, g₀, outdoor breathable).

## v0 (lean)

| Feature | Behavior |
|---------|----------|
| Map | ASCII overmap; `@` = you |
| Coords | `LEVEL / X / Y` on cuff (surface LEVEL=0; bunker negative floor) |
| Cursor | Pan with `wasd` / `hjkl` (`+`) |
| Course | `W` preview → confirm; `.` steps along; length in **m** (1 tile = 1 m) |
| Sidebar | Monitor vitals NOMINAL/CAUTION/FAIL + **goal / guidance** + course m |
| Profile | Keys `1`–`4` swap Earth-cabin / Mars-thin-demo / Mars / Titan — **same UI** |

## Later

`/` search; FUTURE ANSI colors; richer overmap layers.

## World-agnostic

Grid + breathe (`P×O₂%`) + suit + wrist-map are shared. Scenario packs supply ambient / g₀ / tiles — see [Physical_Data.md](Physical_Data.md) world table. SI: [SI_Units.md](SI_Units.md).
