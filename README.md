# rogue_engine

Ada 2022 turn-based survival roguelike engine (clean-room, MIT).

Built step-by-step as strongly typed engine modules with contracts and a growing `tests.adb` suite.

## Step 1 - `Game_Grid`

2D map grid core:

- `Point` with strong `Coordinate` axes
- `Terrain_Type` / `Tile` / fixed 24x24 `Chunk`
- Chebyshev (roguelike) distance
- Adjacent line-of-sight blocking (walls and closed doors block; open doors do not)

## Step 2 - `Game_Actors`

Tagged actor entities on the grid:

- `Action_Points` (-1000 .. 1000) with clamped adjustments
- `Health_Status` (Healthy, Wounded, Critical, Dead)
- `Actor` tagged record: position, speed, AP, health
- `Initialize` / `Adjust_Action_Points` / `Move_To` (Chebyshev-adjacent only)

## Build & test

Requires GNAT / gprbuild (Ada 2022).

```bash
make test
```

Flags: `-gnatwa -gnat2022` (zero warnings expected). Currently **30 tests** (18 Game_Grid + 12 Game_Actors).

## License

MIT - see [LICENSE](LICENSE).
