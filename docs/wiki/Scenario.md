# SPEC: Game_Scenario (flexible starts)

Status: **Spec ready** for ADA implementation. Engine stays generic; scenarios are data + thin Ada packages.

---

## Goal

Players must be able to start as **bunker + rover dust-storm ops** *or* **Titan-style flight-control / orbital-landing ops** (and later others) **without forking** grid, actors, items, environment, or Dream-RSI.

Titan flight-control is a **scenario**, not the engine identity.

---

## Package sketch: `Game_Scenario`

### Types (suggested)

- `Scenario_Id` — stable string/enum key (`Bunker_Rover_Storm`, `Titan_Flight_Control`, …)
- `Start_Site` — bunker depth / control-room grid / outdoor spawn
- `Control_Room_Layout` — console island position, headset ops furniture id
- `Linked_Outdoor_Role` — rover / lander / none
- `Atmosphere_Profile` — references Physical Data tables (bunker air vs storm vs Titan)
- `Dream_RSI_Enabled` — boolean; which actor logs Explore ticks

### Required operations

- `Load_Scenario (Id) → Scenario_Config` (from JSON/TOML later; hardcoded enums OK for v1)
- `Apply_Start (World, Config)` — place human + linked outdoor actor, set environment profile, seed airlock closed
- `Active_Scenario` query for UI / wiki

### Invariants

- Exactly one active scenario per run
- Airlock both-open still forbidden under every scenario that has an airlock
- Human vitality remains tissue O₂ + room air when scenario uses bunker cast; robot uses power/hull/thermal outdoors
- Weight / mass rules always on

---

## Scenario A — Bunker + rover (default)

| Field | Value |
|-------|-------|
| Cast | Human 4 floors down; rover outside |
| Link | Sealed double-door airlock |
| Outdoor | Earth dust storm, Mars-like hostility (see Physical_Data) |
| Ops | Center console island + headset |
| Dream-RSI | Rover Explore → bunker Construct/Dream → Redeploy |

## Scenario B — Titan-style flight control

| Field | Value |
|-------|-------|
| Cast | Operator in control room (may still be “human actor”); linked vehicle/lander role |
| Atmosphere | Titan surface / cruise profile from Physical_Data |
| Dream-RSI | Optional; exploration policy on approach/landing branches |
| Note | Same packages; different `Atmosphere_Profile` + start layout |

---

## Out of scope for first cut

- Full content browser UI
- Mod workshop
- More than two starter scenarios

---

## Done when

- [ ] `game_scenario.ads/.adb` + tests green on main
- [ ] At least two start configs selectable in tests
- [ ] Wiki Home links this page; Packages lists `Game_Scenario`
- [ ] Board card moves In progress → Done

Hand-off: Ops owns Physical_Data numbers; ADA implements contracts from this Spec.
