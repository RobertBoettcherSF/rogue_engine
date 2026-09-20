# rogue_engine

Clean-room **Ada 2022** engine for a turn-based post-apocalyptic survival roguelike.

**License:** MIT (see [LICENSE](LICENSE)). All code and docs stay MIT; art assets are MIT or CC0 only. No third-party product names in documentation.

Built step by step as strongly typed modules with contracts and a growing embedded test suite (`tests.adb`).

## Goals

- **Simulation-first:** the world rules live in Ada packages (grid, actors, inventory, time). Graphics are a thin, swappable layer — ASCII now, tiles later — without rewriting the sim.
- **Content-driven:** tiles, items, maps, and factions will live in data files (JSON/TOML) so content authors do not compile Ada.
- **Honest weight:** backpack **total load** = sum of container (**hull mass + content mass**). Contents are Solid / Liquid / Gas / Plasma; hulls track integrity (0 = ruptured). Comfortable carry = Strength × 1 kg; hard cap 2×.
- **Proof where it pays:** SPARK-first on core sim invariants; plain Ada for loaders, UI, and content glue so features are not blocked by prove bars.

## Status

| Step | Package | Notes |
|------|---------|--------|
| 1 | `Game_Grid` | Points, terrain, 24×24 chunks, Chebyshev distance, LOS blocking |
| 2 | `Game_Actors` | Tagged actors, AP, health, adjacent `Move_To` |
| 3 | `Game_Items` | Backpack load; hull+content mass; temps °C; seal→access; can opener + drill sample + process; plasma rupture = game over; 5/10 kg carry |
| Next | Turn clock | Priority queue / AP tick scheduling |

**Tests:** `make test` — currently **76** assertions (Game_Grid + Game_Actors + Game_Items containers), zero warnings under `-gnatwa`.

## Architecture (planned)

```
┌──────────────────────────────────────────────┐
│  Front end (ASCII → 32px tiles → sprites)   │
├──────────────────────────────────────────────┤
│  Content schemas (JSON/TOML) + wiki lint    │
├──────────────────────────────────────────────┤
│  Ada sim core (SPARK-friendly packages)     │
│  Game_Grid · Game_Actors · Weight · …       │
└──────────────────────────────────────────────┘
```

Wiki pages should be generated or linted from the same schemas so lore cannot drift from game data.

## Build & test

**Prerequisites:** GNAT / gprbuild (Ada 2022)

```bash
make test
```

Clean with `make clean`. Flags: `-gnatwa -gnat2022`.

## Contributing

Engine work lands on `main` as complete packages (`*.ads` / `*.adb`), `tests.adb` updates, and README notes for each step. Prefer contracts (`Pre` / `Post` / `Global`) on public APIs.

## License

MIT — see [LICENSE](LICENSE).
