# Wrist map (terminal `./play`)

Pure Ada terminal — no GUI toolkit. Same UI on **any surface** (Earth / Mars / Titan / …); only the **world profile** changes (P, mix, g₀, tiles).

## v0 (lean)

| Feature | Behavior |
|---------|----------|
| Map | ASCII overmap; `@` = you |
| Coords | `LEVEL / X / Y` on cuff |
| Cursor | Pan with movement keys |
| Course | Preview route → confirm |
| Sidebar | Monitor vitals NOMINAL/CAUTION/FAIL + **goal / guidance** line |

## Later

`/` search; FUTURE ANSI colors; richer overmap layers.

## World-agnostic

Grid + breathe (`P×O₂%`) + suit + wrist-map are shared. Scenario packs supply ambient / g₀ / tiles — see [Physical_Data.md](Physical_Data.md) world table.
