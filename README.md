# rogue_engine

Clean-room **Ada 2022** engine for a **twofold** turn-based survival game: a human operator deep in a sealed bunker remote-running a rover through a Mars-like dust storm on Earth.

**License:** MIT (see [LICENSE](LICENSE)). Code and docs stay MIT; art assets MIT or CC0 only. No third-party product names in documentation.

Built step by step as strongly typed modules with contracts and a growing embedded suite (`tests.adb`). **Ada/SPARK first:** every design beat becomes typed packages, contracts, and tests — lore only counts once it is a package.

## Premise (sim-backed)

| Side | Where | Vitality |
|------|--------|----------|
| **Human** | Bunker, **4 floors** down; small sealed room air | **Tissue oxygenation** (not cartoon HP) |
| **Robot / rover** | Outside in dust storm | **Power / hull / thermal** (no lungs) |

Link: a **sealed double-door airlock** (never both open; chamber pressure cycles bunker ↔ storm). Outside: pressure crashed, cold, **visibility ~0**, blackout-dark though radio says midday, **aurora** over the storm; a **high satellite** still gives a coarse overhead picture. Player bunker room centers on a **mid-room console island** (headset ops).

## Goals

- **Ada/SPARK first:** typed state + `Pre` / `Post` / `Global` + tests for each beat.
- **Simulation-first:** world rules in Ada packages; graphics stay a thin, swappable layer (ASCII → tiles → sprites).
- **Content-driven:** tiles/items/maps/factions → JSON/TOML later so artists do not compile Ada.
- **Honest weight:** backpack load = Σ (hull mass + content mass); Solid / Liquid / Gas / Plasma; hull integrity 0–100% (≤50 opened, 0 ruptured); Strength×1 kg comfortable, 2× hard cap.
- **Proof where it pays:** SPARK-first on core invariants; plain Ada for loaders/UI/content glue.

## Status

| Step | Package | Notes |
|------|---------|--------|
| 1 | `Game_Grid` | Points, terrain, 24×24 chunks, Chebyshev distance, LOS |
| 2–4 | `Game_Actors` | `Human_Actor` (O₂ + `Bunker_Room` / `Breathe_In_Bunker`) · `Robot_Actor` (power/hull/thermal) · AP · adjacent `Move_To` |
| 3 | `Game_Items` | Backpack; hull+content mass; °C; seal→access; can opener / drill sample / process; plasma breach = heat + burn/shock + game over |
| 5 | `Game_Environment` | 4F depth · airlock · outdoor storm · satellite frame · aurora |
| Next | Turn clock | Priority queue / AP tick scheduling |
| Next | Matter tools | `Siphon_Liquid` / `Bleed_Gas` (solid drill already shipped) |
| Next | Player room | Central console object as typed bunker furniture |

**Tests:** `make test` — **101** assertions, zero warnings under `-gnatwa`.

## Architecture

```
┌────────────────────────────────────────┐
│  Front end (ASCII → 32px tiles → sprites)   │
│  orange/teal terminal palette               │
├────────────────────────────────────────┤
│  Content schemas (JSON/TOML) + wiki lint    │
├────────────────────────────────────────┤
│  Ada sim (SPARK-friendly)                   │
│  Game_Grid · Game_Actors · Game_Items       │
│  Game_Environment · (turn clock next)       │
└────────────────────────────────────────┘
```

Bunker ops (human + mid-room console) and storm rover stay one game linked by the airlock. Wiki should be generated or linted from the same schemas so lore cannot drift from data.

## Build & test

**Prerequisites:** GNAT / gprbuild (Ada 2022)

```bash
make test
```

Clean with `make clean`. Flags: `-gnatwa -gnat2022`.

## Contributing

Land complete packages on `main` (`*.ads` / `*.adb`), extend `tests.adb`, update this README per step. Prefer contracts on public APIs.

## License

MIT — see [LICENSE](LICENSE).
