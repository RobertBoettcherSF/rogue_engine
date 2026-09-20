# rogue_engine

Ada 2022 turn-based survival roguelike engine (clean-room, MIT).

Built step-by-step as strongly typed engine modules with contracts and a growing `tests.adb` suite.

## Step 1 - `Game_Grid`

2D map grid core:

- `Point` with strong `Coordinate` axes
- `Terrain_Type` / `Tile` / fixed 24x24 `Chunk`
- Chebyshev (roguelike) distance
- Adjacent line-of-sight blocking (walls and closed doors block; open doors do not)

## Build & test

Requires GNAT / gprbuild (Ada 2022).

```bash
make test
```

Flags: `-gnatwa -gnat2022` (zero warnings expected).

## License

MIT - see [LICENSE](LICENSE).
