# rogue_engine

Clean-room **Ada 2022** engine for a **twofold** turn-based survival game: a human operator deep in a sealed bunker remote-running a **Strider** (outdoor walking machine) through a Mars-like dust storm on Earth.

**License:** MIT (see [LICENSE](LICENSE)). Code and docs stay MIT; art assets MIT or CC0 only. No third-party product names in documentation.

Built as strongly typed modules with contracts and embedded suites (`tests.adb`, `tests_ops_scenario.adb`, `tests_demo.adb`). **Ada-only this phase** (including later screenshots): SPARK L2–L4 is **labeled now; formal prove later** — no `gnatprove` required yet. Lore only counts once it is a package.

**Inventory SoT:** [docs/wiki/Packages.md](docs/wiki/Packages.md). Docs live under GitHub `docs/wiki/` only (not Trello).

## Premise (sim-backed)

| Side | Where | Vitality |
|------|--------|----------|
| **Human** | Bunker, **4 floors** down; ops-room seat; sealed cabin air | **Tissue oxygenation** (+ hunger/thirst/fatigue); high-g → `Vision_Clarity` |
| **Strider** (linked) | Outside in dust storm | **Power / hull / thermal** (no lungs) |

Strider demo stand-in: **5×10⁴ kg** empty, **1 m** step, **5×10² kg** payload, power in **kW** (full-class wiki mass ~1680 t → scale **≈ 1/34**). Vehicle mass is `Mass_Kilograms`; eat/drink stay grams. `Payload_Is_Trivial`: payload×10 ≤ empty.

Link: sealed double-door airlock + remote pilot (`Strider_Walk` / `Turn` / `Scan`). Human **never** steps onto storm tiles while piloting. Outside: **20 kPa Mars-thin** exterior (ADA lock; not Earth 70–85 kPa), cold, visibility ~0, aurora. EVA: ISS EMU-class **145 kg** worn (`Mass_Kilograms`, AP penalty; never Strength carry); suit loop **29.6 kPa / 100% O₂** healthy. Cabin ~101 kPa × 21% ≈ **21 kPa** O₂-partial; unsuited storm ≈ **4 kPa** — hypoxia.

## Goals

- **Ada first, SPARK labeled:** typed state + `Pre`/`Post`/`Global` + tests; FUTURE L2–L4 comments on life-critical packages.
- **Simulation-first:** world rules in Ada; graphics a thin swappable layer (ASCII → tiles → sprites).
- **Content-driven:** tiles/items/maps → JSON/TOML later.
- **Honest weight:** backpack = Σ (hull + content); Solid/Liquid/Gas/Plasma; integrity 0–100%.
- **Docs:** `docs/wiki/` only; Packages.md is inventory SoT.

## Package inventory

Mirror of [Packages.md](docs/wiki/Packages.md):

| Package | Role |
|---------|------|
| `Game_Grid` | Points, terrain, chunks, LOS |
| `Game_Actors` | Human O₂/needs/sleep/breathe · `G_Load`/`Vision_Clarity` · Robot · AP |
| `Game_Items` | Backpack; Sip/Bite; seal→access; drill/process; plasma |
| `Game_Dream_RSI` | Explore→Construct→Dream→Redeploy |
| `Game_Environment` | Bunker depth, airlock, storm, satellite, aurora |
| `Game_Atmosphere` | Tile air; O₂-partial; cabin vs exterior |
| `Game_Turn` | Turn / wall-minute clock; AP grant |
| `Game_Demo` | Walk, eat/drink, tick+ECLSS, sleep/dream, Strider, Glance_Wrist, Passenger_Panel |
| `Game_Passenger_Board` | OK/CAUTION/FAIL; g, MET, P, O₂/CO₂; vision-dim |
| `Game_ECLSS` | Cabin ECLSS tick (Ops rates); SPARK FUTURE |
| `Game_Suit` | EMU 145 kg; 29.6 kPa/100% O₂; Orlan alt |
| `Game_Strider` | Vehicle kg/kW; demo 5×10⁴ kg; Payload_Is_Trivial |
| `Game_Ops_Room` | 5×4 @ 1 m, ~44 m³ |
| `Game_Scenario` | Starts; outdoor role default **Strider** |

**Tests:** `make test` — core + ops scenario + demo (~95 demo asserts), zero warnings under `-gnatwa`.

## Architecture

```
┌─────────────────────────────────────────────┐
│  Front end (ASCII → 32px tiles → sprites)   │
├─────────────────────────────────────────────┤
│  docs/wiki/ (Packages.md = inventory SoT)   │
├─────────────────────────────────────────────┤
│  Ada sim (Ada-only now; SPARK prove later)  │
│  Grid · Actors · Items · Environment        │
│  Atmosphere · Turn · Suit · Strider · ECLSS │
│  Passenger_Board · Demo (Strider link)      │
└─────────────────────────────────────────────┘
```

## Build & test

**Prerequisites:** GNAT / gprbuild (Ada 2022)

```bash
make test    # tests + tests_ops_scenario + tests_demo
make play    # ops-room + Strider demo sequence
```

Clean with `make clean`. Flags: `-gnatwa -gnat2022`.

**Get current main** (do not use an old Downloads zip — those lag `make play` and suites):

```bash
git clone https://github.com/RobertBoettcherSF/rogue_engine.git
# or: git pull origin main
make test && make play
```

Wiki: [Packages](docs/wiki/Packages.md) · [Demo](docs/wiki/Demo.md) · [Passenger_Board](docs/wiki/Passenger_Board.md) · [Strider](docs/wiki/Strider.md) · [Physical_Data](docs/wiki/Physical_Data.md) · [SI_Units](docs/wiki/SI_Units.md) · [Proof](docs/wiki/Proof.md).

## Contributing

Land complete packages on `main`, extend tests, keep Packages.md and this README in sync (Packages is SoT). Prefer contracts on public APIs. No Trello.

## License

MIT — see [LICENSE](LICENSE).
